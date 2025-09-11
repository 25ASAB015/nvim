#!/usr/bin/env python3
"""
Script para extraer keybindings de archivos Lua y generar documentación automática.

Este script escanea todos los archivos .lua en el repositorio (excepto .git),
extrae los keybindings según los patrones utilizados en el repositorio y
genera/actualiza el archivo docs/keybindings.md siguiendo el formato existente.

Patrones de keybindings detectados:
- map() function calls
- vim.keymap.set() calls  
- custom_keys configurations (en lazy.lua)
"""

import os
import re
import glob
from typing import List, Dict, Tuple, Optional
from dataclasses import dataclass


@dataclass
class Keybinding:
    """Representa un keybinding extraído del código."""
    file_path: str
    modes: List[str]
    key: str
    action: str
    description: str
    context: str = ""
    line_number: int = 0


class KeybindingExtractor:
    """Extractor de keybindings desde archivos Lua."""
    
    def __init__(self, repo_root: str = "."):
        self.repo_root = repo_root
        self.keybindings: List[Keybinding] = []
        
        # Patrones regex para detectar keybindings (más flexibles)
        self.patterns = {
            # map('n', 'jj', '<Esc>', opts) - single mode with any quote style
            'map_function': re.compile(
                r"map\s*\(\s*['\"]([^'\"]+)['\"]\s*,\s*['\"]([^'\"]+)['\"]\s*,\s*(['\"][^'\"]*['\"]|[^,\)]+)\s*(?:,\s*([^)]*))?\)",
                re.MULTILINE
            ),
            # map({ 'v', 'x' }, 'p', '"_dP', opts) - multiple modes
            'map_function_multi': re.compile(
                r"map\s*\(\s*\{\s*([^}]+)\s*\}\s*,\s*['\"]([^'\"]+)['\"]\s*,\s*(['\"][^'\"]*['\"]|[^,\)]+)\s*(?:,\s*([^)]*))?\)",
                re.MULTILINE
            ),
            # vim.keymap.set patterns
            'keymap_set': re.compile(
                r"vim\.keymap\.set\s*\(\s*['\"]([^'\"]+)['\"]\s*,\s*['\"]([^'\"]+)['\"]\s*,\s*(['\"][^'\"]*['\"]|[^,\)]+)\s*(?:,\s*([^)]*))?\)",
                re.MULTILINE
            ),
            'keymap_set_multi': re.compile(
                r"vim\.keymap\.set\s*\(\s*\{\s*([^}]+)\s*\}\s*,\s*['\"]([^'\"]+)['\"]\s*,\s*(['\"][^'\"]*['\"]|[^,\)]+)\s*(?:,\s*([^)]*))?\)",
                re.MULTILINE
            ),
            # ['<localleader>l'] = function(plugin) ... end,
            'custom_keys': re.compile(
                r"\[(['\"][^'\"]+['\"])\]\s*=\s*function\s*\([^)]*\).*?end",
                re.MULTILINE | re.DOTALL
            ),
        }
        
        # Mapeo de modos abreviados a nombres completos
        self.mode_mapping = {
            'n': 'Normal',
            'i': 'Insert', 
            'v': 'Visual',
            'x': 'Block',  # Visual block mode is just "Block" not "Visual, Block"
            't': 'Terminal',
            'c': 'Command',
            'o': 'Operator'
        }

    def find_lua_files(self) -> List[str]:
        """Encuentra todos los archivos .lua en el repositorio, excluyendo .git."""
        lua_files = []
        for root, dirs, files in os.walk(self.repo_root):
            # Excluir directorio .git
            dirs[:] = [d for d in dirs if d != '.git']
            
            for file in files:
                if file.endswith('.lua'):
                    lua_files.append(os.path.join(root, file))
        
        return sorted(lua_files)

    def extract_description_from_options(self, options_str: str) -> str:
        """Extrae descripción del parámetro desc en las opciones."""
        if not options_str:
            return ""
        
        # Buscar desc = 'descripción'
        desc_match = re.search(r"desc\s*=\s*['\"]([^'\"]+)['\"]", options_str)
        if desc_match:
            return desc_match.group(1).strip()
        
        return ""

    def extract_description_from_comment(self, content: str, line_num: int) -> str:
        """Extrae descripción de comentarios cercanos al keybinding."""
        lines = content.split('\n')
        description = ""
        
        # Buscar comentario en la misma línea
        if line_num < len(lines):
            line = lines[line_num]
            comment_match = re.search(r'--\s*(.+)', line)
            if comment_match:
                desc = comment_match.group(1).strip()
                if not desc.startswith('═') and not desc.startswith('║'):
                    description = desc
        
        # Si no hay comentario en la misma línea, buscar en líneas anteriores
        if not description:
            for i in range(max(0, line_num - 2), line_num):
                if i < len(lines):
                    comment_match = re.search(r'--\s*(.+)', lines[i])
                    if comment_match:
                        desc = comment_match.group(1).strip()
                        if not desc.startswith('═') and not desc.startswith('║') and not desc.startswith('MODOS'):
                            description = desc
                            break
        
        return description

    def normalize_modes(self, modes_str: str) -> List[str]:
        """Normaliza la representación de modos."""
        # Limpiar y dividir modos
        modes_str = modes_str.replace("'", "").replace('"', '').replace(' ', '')
        modes = [m.strip() for m in modes_str.split(',') if m.strip()]
        
        # Convertir a nombres completos
        normalized = []
        seen = set()
        for mode in modes:
            if mode in self.mode_mapping:
                full_mode = self.mode_mapping[mode]
                if full_mode not in seen:
                    normalized.append(full_mode)
                    seen.add(full_mode)
            else:
                cap_mode = mode.capitalize()
                if cap_mode not in seen:
                    normalized.append(cap_mode)
                    seen.add(cap_mode)
        
        return normalized

    def format_key_combination(self, key: str) -> str:
        """Formatea las combinaciones de teclas para mostrar."""
        # Reemplazar notaciones especiales
        replacements = {
            '<C-': '<Ctrl-',
            '<M-': '<Alt-',
            '<S-': '<Shift-',
            '<CR>': 'Enter',
            '<Esc>': 'Escape',
            '<Tab>': 'Tab',
            '<Space>': 'Espacio'
        }
        
        formatted = key
        for old, new in replacements.items():
            formatted = formatted.replace(old, new)
        
        # Envolver en tags kbd
        if '<' in formatted and '>' in formatted:
            # Para combinaciones complejas como <Ctrl-d>
            formatted = f"<kbd>{formatted}</kbd>"
        else:
            # Para teclas simples, envolver cada carácter
            if len(formatted) == 1:
                formatted = f"<kbd>{formatted}</kbd>"
            else:
                formatted = f"<kbd>{formatted}</kbd>"
        
        return formatted

    def extract_keybindings_from_file(self, file_path: str) -> List[Keybinding]:
        """Extrae keybindings de un archivo específico."""
        keybindings = []
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
        except Exception as e:
            print(f"Error leyendo {file_path}: {e}")
            return keybindings
        
        lines = content.split('\n')
        
        # Extraer usando cada patrón
        for pattern_name, pattern in self.patterns.items():
            for match in pattern.finditer(content):
                line_num = content[:match.start()].count('\n')
                
                if pattern_name in ['map_function', 'keymap_set']:
                    modes_str, key, action, options = match.groups()
                    modes = self.normalize_modes(modes_str)
                    
                    # Limpiar acción (remover comillas si las tiene)
                    action = action.strip('\'"')
                    
                    # Extraer descripción de opciones primero
                    description = self.extract_description_from_options(options or "")
                    # Si no hay descripción en opciones, buscar en comentarios
                    if not description:
                        description = self.extract_description_from_comment(content, line_num)
                    
                elif pattern_name in ['map_function_multi', 'keymap_set_multi']:
                    modes_str, key, action, options = match.groups()
                    modes = self.normalize_modes(modes_str)
                    
                    # Limpiar acción (remover comillas si las tiene)
                    action = action.strip('\'"')
                    
                    # Extraer descripción de opciones primero
                    description = self.extract_description_from_options(options or "")
                    # Si no hay descripción en opciones, buscar en comentarios
                    if not description:
                        description = self.extract_description_from_comment(content, line_num)
                    
                elif pattern_name == 'custom_keys':
                    key = match.group(1).strip('\'"')
                    action = "Función personalizada"
                    modes = ["Custom"]
                    description = ""
                    
                    # Extraer descripción del contexto
                    context_start = max(0, line_num - 10)
                    context_lines = lines[context_start:line_num + 5]
                    context = '\n'.join(context_lines)
                    
                    if 'lazygit' in context:
                        description = "Abre lazygit para ver el log del plugin"
                    elif 'terminal' in context.lower():
                        description = "Abre una terminal en el directorio del plugin"
                else:
                    continue
                
                # Procesar acción para casos especiales
                processed_action = action
                if not action or action in ['<Nop>', '"_dP', '"_x', '"_D', '"_d']:
                    # Usar descripción si hay una disponible
                    if description:
                        processed_action = description
                    else:
                        # Generar descripción básica basada en la acción
                        if action == '<Nop>':
                            processed_action = "Placeholder (sin acción)"
                        elif action == '"_dP':
                            processed_action = "Pegar sin perder el clipboard"
                        elif action == '"_x':
                            processed_action = "Eliminar sin copiar al registro principal"
                        elif action == '"_D':
                            processed_action = "Eliminar hasta el final, sin copiar"
                        elif action == '"_d':
                            processed_action = "Eliminar selección, sin copiar"
                        else:
                            processed_action = action
                
                # Usar descripción como acción si está disponible y es más descriptiva
                if description and description != action:
                    processed_action = description
                
                keybinding = Keybinding(
                    file_path=file_path,
                    modes=modes,
                    key=key,
                    action=processed_action,
                    description=description,
                    line_number=line_num + 1
                )
                keybindings.append(keybinding)
        
        return keybindings

    def extract_all_keybindings(self) -> List[Keybinding]:
        """Extrae todos los keybindings del repositorio."""
        lua_files = self.find_lua_files()
        all_keybindings = []
        
        for file_path in lua_files:
            file_keybindings = self.extract_keybindings_from_file(file_path)
            all_keybindings.extend(file_keybindings)
        
        return all_keybindings

    def group_keybindings_by_file(self, keybindings: List[Keybinding]) -> Dict[str, List[Keybinding]]:
        """Agrupa keybindings por archivo."""
        grouped = {}
        for kb in keybindings:
            rel_path = os.path.relpath(kb.file_path, self.repo_root)
            if rel_path not in grouped:
                grouped[rel_path] = []
            grouped[rel_path].append(kb)
        
        return grouped

    def generate_markdown_table(self, keybindings: List[Keybinding]) -> str:
        """Genera tabla markdown para un grupo de keybindings."""
        if not keybindings:
            return ""
        
        # Determinar si usar contexto o notas
        use_context = any(kb.context for kb in keybindings)
        header_col = "Contexto/Notas" if use_context else "Notas/Duplicados"
        
        table = f"""| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | {header_col}                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
"""
        
        # Detectar duplicados
        key_counts = {}
        for kb in keybindings:
            key = kb.key
            if key not in key_counts:
                key_counts[key] = []
            key_counts[key].append(kb)
        
        for kb in keybindings:
            key_formatted = self.format_key_combination(kb.key)
            modes_str = ", ".join(kb.modes) if kb.modes else "N/A"
            
            # Determinar acción a mostrar
            action = kb.description if kb.description else kb.action
            if not action or action == kb.key:
                action = "⚠️ Sin descripción"
            
            # Determinar notas
            notes = ""
            if len(key_counts[kb.key]) > 1:
                # Verificar si son duplicados reales (misma tecla, diferentes modos)
                other_modes = [other.modes for other in key_counts[kb.key] if other != kb]
                if any(set(kb.modes) & set(modes) for modes in other_modes):
                    notes = "Duplicado"
                else:
                    notes = "Duplicado: acción distinta"
            
            if use_context and kb.context:
                notes = kb.context
            
            table += f"| {key_formatted:<37} | {action:<51} | {modes_str:<15} | {notes:<35} |\n"
        
        return table

    def generate_documentation(self, keybindings: List[Keybinding]) -> str:
        """Genera la documentación completa en markdown."""
        grouped = self.group_keybindings_by_file(keybindings)
        
        doc = ""
        
        # Procesar archivos en orden específico
        file_order = [
            'lua/core/keys.lua',
            'lua/core/autocmd.lua', 
            'lua/plugins/lazy.lua'
        ]
        
        processed_files = set()
        
        # Procesar archivos principales en orden
        for file_path in file_order:
            if file_path in grouped:
                file_keybindings = grouped[file_path]
                if file_keybindings:
                    doc += f"### {file_path}\n\n"
                    
                    # Agregar notas especiales por archivo
                    if 'lazy.lua' in file_path:
                        doc += "**Estos atajos solo están activos dentro de la interfaz del plugin Lazy.**\n\n"
                    
                    doc += self.generate_markdown_table(file_keybindings)
                    
                    # Agregar notas especiales
                    if 'keys.lua' in file_path:
                        doc += "\n#### Líder global/local: <kbd>Espacio</kbd>\n"
                        doc += "- Asignado como \"líder\" (mapleader y maplocalleader).\n"
                    
                    doc += "\n---\n\n"
                
                processed_files.add(file_path)
        
        # Procesar archivos restantes
        for file_path, file_keybindings in grouped.items():
            if file_path not in processed_files and file_keybindings:
                doc += f"### {file_path}\n\n"
                doc += self.generate_markdown_table(file_keybindings)
                doc += "\n---\n\n"
        
        # Agregar notas finales
        doc += "**Notas generales:**\n"
        doc += "- Todos los keybindings agrupados por archivo para facilitar la edición.\n"
        doc += "- Los duplicados se marcan y explican.\n"
        doc += "- Los keybindings contextuales se destacan indicando el contexto de activación.\n"
        doc += "- Todo está documentado en español.\n"
        
        # Contar keybindings sin descripción
        no_desc_count = sum(1 for kb in keybindings if not kb.description or kb.description == kb.key)
        if no_desc_count > 0:
            doc += f"\n⚠️ **Advertencia:** Se encontraron {no_desc_count} keybindings sin descripción. "
            doc += "Considera agregar comentarios descriptivos en el código fuente.\n"
        
        return doc

    def save_documentation(self, content: str, output_path: str = "docs/keybindings.md"):
        """Guarda la documentación en el archivo especificado."""
        output_path = os.path.join(self.repo_root, output_path)
        
        # Crear directorio si no existe
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        
        try:
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Documentación guardada en: {output_path}")
        except Exception as e:
            print(f"Error guardando documentación: {e}")


def main():
    """Función principal del script."""
    print("🔍 Extrayendo keybindings de archivos Lua...")
    
    # Inicializar extractor
    extractor = KeybindingExtractor()
    
    # Extraer keybindings
    keybindings = extractor.extract_all_keybindings()
    print(f"✅ Encontrados {len(keybindings)} keybindings")
    
    # Generar documentación
    documentation = extractor.generate_documentation(keybindings)
    
    # Guardar documentación
    extractor.save_documentation(documentation)
    
    print("🎉 Documentación de keybindings actualizada exitosamente!")


if __name__ == "__main__":
    main()
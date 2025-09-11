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
    
    def __init__(self, repo_root: Optional[str] = None):
        # Si no se especifica, usar la raíz del repo relativa a este archivo (../)
        if repo_root is None:
            script_dir = os.path.dirname(os.path.abspath(__file__))
            self.repo_root = os.path.abspath(os.path.join(script_dir, ".."))
        else:
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
            # field assignments that define a key, e.g., toggle_style_key = '<leader>ot'
            'assignment_key': re.compile(
                r"(?<![\w])([A-Za-z_][A-Za-z0-9_]*_key|key)\s*=\s*(['\"][^'\"]+['\"])",
                re.MULTILINE
            ),
        }
        
        # Mapeo de modos abreviados a nombres completos
        self.mode_mapping = {
            'n': 'Normal',
            'i': 'Insert', 
            'v': 'Visual',
            'x': 'Visual',
            's': 'Select',
            't': 'Terminal',
            'c': 'Command',
            'o': 'Operator'
        }

        # Chips de modos para vista compacta
        self.mode_chips = {
            'Normal': 'N',
            'Visual': 'V',
            'Select': 'S',
            'Insert': 'I',
            'Terminal': 'T',
            'Command': 'C',
            'Operator': 'O',
        }

        # Palabras clave para clasificación por categorías
        self.category_keywords: Dict[str, List[str]] = {
            'Navegación': [
                'mover', 'subir', 'bajar', 'ir', 'inicio', 'fin', 'salt', 'jump', 'linea', 'línea', 'split move'
            ],
            'Búsqueda': [
                'buscar', 'siguiente', 'anterior', 'search', 'find', 'match'
            ],
            'Edición': [
                'eliminar', 'pegar', 'copiar', 'unir', 'indent', 'formatear', 'replace', 'comment', 'swap'
            ],
            'Selección': [
                'visual', 'seleccion', 'selección', 'objeto', 'expand', 'shrink'
            ],
            'Ventanas/Buffers/Tabs': [
                'ventana', 'window', 'buffer', 'tab', 'split', 'pane'
            ],
            'Archivos/Proyecto': [
                'archivo', 'files', 'explorer', 'proyecto', 'project', 'recent'
            ],
            'Git': [
                'git', 'hunk', 'blame', 'diff', 'commit', 'push', 'pull'
            ],
            'LSP/Diagnóstico': [
                'lsp', 'diagn', 'hover', 'rename', 'code action', 'references', 'format'
            ],
            'UI/Tema': [
                'tema', 'theme', 'toggle', 'color', 'onedark', 'ui', 'resaltar'
            ],
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

    def modes_to_chips(self, modes: List[str]) -> str:
        """Convierte una lista de modos a chips compactos, p.ej. [N] [V]."""
        if not modes:
            return ""
        ordered = []
        seen = set()
        order = ['Normal', 'Visual', 'Select', 'Insert', 'Terminal', 'Command', 'Operator']
        for m in order:
            if m in modes and m not in seen:
                ordered.append(m)
                seen.add(m)
        chips = [f"[{self.mode_chips.get(m, m[0].upper())}]" for m in ordered]
        return " ".join(chips)

    def categorize_keybinding(self, kb: 'Keybinding') -> str:
        """Devuelve la categoría más probable para un keybinding."""
        text = f"{kb.description} {kb.action}".lower()
        # Prioridad por categorías definidas
        for category, keywords in self.category_keywords.items():
            for kw in keywords:
                if kw in text:
                    return category
        # Heurística por tecla líder
        if '<leader>' in kb.key.lower() or '<localleader>' in kb.key.lower():
            return 'Atajos con <leader>'
        # Fallback
        return 'Otros'

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
        def is_match_in_commented_line(text: str, start_index: int) -> bool:
            """Devuelve True si la coincidencia está en una línea comentada con -- antes del patrón."""
            line_start = text.rfind('\n', 0, start_index) + 1
            line_end = text.find('\n', start_index)
            if line_end == -1:
                line_end = len(text)
            line = text[line_start:line_end]
            comment_pos = line.find('--')
            if comment_pos == -1:
                return False
            # Si el comentario aparece antes del inicio relativo del patrón en la línea
            rel_index = start_index - line_start
            return comment_pos != -1 and comment_pos <= rel_index

        for pattern_name, pattern in self.patterns.items():
            for match in pattern.finditer(content):
                line_num = content[:match.start()].count('\n')
                # Ignorar si está comentado en la misma línea
                if is_match_in_commented_line(content, match.start()):
                    continue
                
                context_note = ""
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
                    context_note = "Clave personalizada de plugin"
                elif pattern_name == 'assignment_key':
                    # Campo *_key = "<...>"
                    _field, key = match.groups()
                    key = key.strip('\'"')
                    action = "Atajo de configuración del plugin"
                    modes = ["Normal"]
                    # Descripción por comentario cercano
                    description = self.extract_description_from_comment(content, line_num)

                    # Si es un archivo de plugins y el valor no tiene prefijos <...>,
                    # asumir que se usa con <leader> y anteponerlo para una mejor UX en docs.
                    try:
                        rel_path = os.path.relpath(file_path, self.repo_root)
                    except Exception:
                        rel_path = file_path
                    is_plugin_file = 'plugins' in rel_path or rel_path.startswith('plugin/')
                    lacks_brackets = ('<' not in key and '>' not in key)
                    is_simple_seq = bool(re.fullmatch(r"[A-Za-z0-9]+", key))
                    if is_plugin_file and lacks_brackets and is_simple_seq:
                        key = f"<leader>{key}"
                        # Anotar contexto para transparencia
                        context_note = "Prefijo asumido: <leader>"
                    else:
                        context_note = ""
                elif pattern_name == 'lazy_keys_entry':
                    # Entrada tipo { "<leader>x", ..., desc = "...", mode = "n" | {"n","v"} }
                    key, desc, mode_val = match.groups()
                    key = key.strip()
                    # Determinar modos
                    modes: List[str] = []
                    if mode_val:
                        mode_val = mode_val.strip()
                        if mode_val.startswith('{') and mode_val.endswith('}'):
                            inner = mode_val[1:-1]
                            modes = self.normalize_modes(inner)
                        else:
                            modes = self.normalize_modes(mode_val)
                    else:
                        modes = ["Normal"]
                    # Acción/descripcion
                    description = (desc or '').strip()
                    action = description or "Acción de plugin"
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
                    context=context_note,
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
        
        # Consolidar por tecla y acción para reducir filas repetidas
        # Estructura: { key: { action: { 'modes': set([...]), 'contexts': set([...]) } } }
        consolidated = {}
        for kb in keybindings:
            key = kb.key
            # Acción mostrada prioriza la descripción si existe
            action_display = kb.description if kb.description else kb.action
            if not action_display or action_display == kb.key:
                action_display = "⚠️ Sin descripción"

            if key not in consolidated:
                consolidated[key] = {}
            if action_display not in consolidated[key]:
                consolidated[key][action_display] = {
                    'modes': set(),
                    'contexts': set()
                }
            for m in kb.modes or ["N/A"]:
                consolidated[key][action_display]['modes'].add(m)
            if use_context and kb.context:
                consolidated[key][action_display]['contexts'].add(kb.context)

        # Orden consistente de modos para visualización
        mode_order = {m: i for i, m in enumerate([
            'Normal', 'Visual', 'Select', 'Insert', 'Terminal', 'Command', 'Operator'
        ])}

        def sort_modes(modes_set):
            return sorted(list(modes_set), key=lambda m: mode_order.get(m, 999))

        # Escribir filas consolidadas en orden por tecla
        for key in sorted(consolidated.keys(), key=lambda k: k.lower()):
            action_groups = consolidated[key]
            multiple_actions = len(action_groups) > 1

            for action_display, info in action_groups.items():
                key_formatted = self.format_key_combination(key)
                modes_sorted = sort_modes(info['modes'])
                modes_str = self.modes_to_chips(modes_sorted) if modes_sorted else ""

                # Notas: si hay múltiples acciones para la misma tecla, indicarlo
                notes = "Acción distinta por modo" if multiple_actions else ""
                if use_context and info['contexts']:
                    # Unir contextos únicos (acotado)
                    contexts = sorted(list(info['contexts']))
                    # Limitar longitud excesiva manteniendo información clave
                    ctx_str = "; ".join(contexts)
                    notes = ctx_str if ctx_str else notes

                table += f"| {key_formatted:<37} | {action_display:<51} | {modes_str:<15} | {notes:<35} |\n"
        
        return table

    def generate_markdown_table_grouped_by_key(self, keybindings: List[Keybinding]) -> str:
        """Genera una tabla compacta agrupada por tecla, listando acciones por modo."""
        if not keybindings:
            return ""

        # Mapear: key -> mode -> set(actions)
        per_key: Dict[str, Dict[str, set]] = {}
        for kb in keybindings:
            key = kb.key
            action_display = kb.description if kb.description else kb.action
            if not action_display or action_display == kb.key:
                action_display = "⚠️ Sin descripción"
            if key not in per_key:
                per_key[key] = {}
            for mode in kb.modes or ["N/A"]:
                per_key[key].setdefault(mode, set()).add(action_display)

        # Orden de modos
        mode_order = [
            'Normal', 'Visual', 'Select', 'Insert', 'Terminal', 'Command', 'Operator'
        ]
        order_index = {m: i for i, m in enumerate(mode_order)}

        # Construir tabla
        table = """| Tecla                               | Acciones por modo                                                                 | Notas |
| ------------------------------------- | ------------------------------------------------------------------------------------ | ----- |
"""

        for key in sorted(per_key.keys(), key=lambda k: k.lower()):
            mode_to_actions = per_key[key]
            # Ordenar modos y acciones
            parts: List[str] = []
            notes: List[str] = []
            for mode in sorted(mode_to_actions.keys(), key=lambda m: order_index.get(m, 999)):
                actions = sorted(list(mode_to_actions[mode]))
                if len(actions) > 1:
                    notes.append(f"Varias acciones en {mode}")
                action_str = "; ".join(actions)
                parts.append(f"{mode}: {action_str}")

            actions_by_mode_str = " · ".join(parts)
            notes_str = ", ".join(notes)

            table += f"| {self.format_key_combination(key):<37} | {actions_by_mode_str:<84} | {notes_str} |\n"

        return table

    def generate_documentation(self, keybindings: List[Keybinding]) -> str:
        """Genera la documentación completa en markdown."""
        grouped = self.group_keybindings_by_file(keybindings)

        # Encabezado enriquecido
        header = (
            "# [Roberto nvim](https://github.com/25ASAB015/nvim)\n\n"
            "[Atajos de teclado](https://github.com/25ASAB015/nvim/blob/main/docs/keybindings.md)\n\n"
            "Aquí están todos los atajos de teclado definidos para mi configuración de Neovim.\n\n"
            "## Atajos con Leader (Modo Normal)\n\n"
            "> Leader == <kbd>Espacio</kbd>\n\n"
        )

        # Índice (TOC)
        doc = header + "## Índice\n\n"
        doc += "- [Por archivo](#por-archivo)\n"
        doc += "- [Conflictos y solapamientos](#conflictos-y-solapamientos)\n"
        doc += "- [Notas y pendientes](#notas-y-pendientes)\n\n"

        # Por archivo
        doc += "## Por archivo\n\n"
        
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
                    doc += f"### [{file_path}]({file_path})\n\n"

                    # Agregar notas especiales por archivo
                    if 'lazy.lua' in file_path:
                        doc += "**Estos atajos solo están activos dentro de la interfaz del plugin Lazy.**\n\n"

                    # Vista principal: por categoría dentro de cada archivo
                    doc += self.generate_by_category_section(file_keybindings, heading_level='####')

                    # (Vista compacta por tecla removida para simplificar)

                    # Agregar notas especiales
                    if 'keys.lua' in file_path:
                        doc += "\n#### Líder global/local: <kbd>Espacio</kbd>\n"
                        doc += "- Asignado como \"líder\" (mapleader y maplocalleader).\n"

                    doc += "\n---\n\n"
                
                processed_files.add(file_path)
        
        # Procesar archivos restantes
        for file_path, file_keybindings in grouped.items():
            if file_path not in processed_files and file_keybindings:
                doc += f"### [{file_path}]({file_path})\n\n"
                doc += self.generate_by_category_section(file_keybindings, heading_level='####')
                doc += "\n---\n\n"

        # (Sección Árbol de <leader> removida para simplificar)

        # Conflictos y solapamientos
        doc += "## Conflictos y solapamientos\n\n"
        doc += self.generate_conflicts_section(keybindings)
        doc += "\n---\n\n"

        # Agregar notas finales y pendientes
        doc += "## Notas y pendientes\n\n"
        doc += "**Notas generales:**\n"
        doc += "- Todos los keybindings agrupados por archivo para facilitar la edición.\n"
        doc += "- Los duplicados se marcan y explican.\n"
        doc += "- Los keybindings contextuales se destacan indicando el contexto de activación.\n"
        doc += "- Todo está documentado en español.\n"

        # Contar keybindings sin descripción
        missing_desc = [
            kb for kb in keybindings if not kb.description or kb.description == kb.key
        ]
        no_desc_count = len(missing_desc)
        if no_desc_count > 0:
            doc += f"\n⚠️ **Advertencia:** Se encontraron {no_desc_count} keybindings sin descripción. "
            doc += "Considera agregar comentarios descriptivos en el código fuente.\n"
            # Listado detallado para investigación
            doc += "\n**Keybindings sin descripción:**\n"
            # Ordenar por archivo y línea para facilitar navegación
            missing_desc.sort(key=lambda kb: (os.path.relpath(kb.file_path, self.repo_root), kb.line_number))
            for kb in missing_desc:
                rel_path = os.path.relpath(kb.file_path, self.repo_root)
                key_fmt = self.format_key_combination(kb.key)
                modes_str = self.modes_to_chips(kb.modes) if kb.modes else ""
                # Enlace relativo a archivo con ancla de línea (GitHub/Git viewers)
                doc += f"- [{rel_path}:L{kb.line_number}]({rel_path}#L{kb.line_number}) — Tecla: {key_fmt} — Modos: {modes_str}\n"

        return doc

    def generate_by_category_section(self, keybindings: List[Keybinding], heading_level: str = '###') -> str:
        """Construye sección agrupada por categorías funcionales.
        heading_level controla el nivel de encabezado para cada categoría (###, ####, ...).
        """
        # Agrupar por categoría
        categories: Dict[str, List[Keybinding]] = {}
        for kb in keybindings:
            cat = self.categorize_keybinding(kb)
            categories.setdefault(cat, []).append(kb)

        # Orden fijo de categorías
        cat_order = [
            'Esenciales', 'Navegación', 'Búsqueda', 'Selección', 'Edición',
            'Ventanas/Buffers/Tabs', 'Archivos/Proyecto', 'Git', 'LSP/Diagnóstico',
            'UI/Tema', 'Atajos con <leader>', 'Otros'
        ]

        # Generar tablas por categoría (reutilizamos consolidación y chips)
        out = []
        for cat in cat_order:
            if cat in categories:
                out.append(f"{heading_level} {cat}\n\n")
                out.append(self.generate_markdown_table(categories[cat]))
                out.append("\n")
        return "".join(out)

    def generate_conflicts_section(self, keybindings: List[Keybinding]) -> str:
        """Lista teclas con múltiples acciones en el mismo modo u orígenes distintos."""
        # key -> mode -> list of (action_display, file, line)
        conflicts: Dict[str, Dict[str, List[Tuple[str, str, int]]]] = {}
        for kb in keybindings:
            action_display = kb.description if kb.description else kb.action
            if not action_display or action_display == kb.key:
                action_display = "⚠️ Sin descripción"
            rel_path = os.path.relpath(kb.file_path, self.repo_root)
            for mode in kb.modes or ["N/A"]:
                conflicts.setdefault(kb.key, {}).setdefault(mode, []).append(
                    (action_display, rel_path, kb.line_number)
                )

        lines = []
        for key in sorted(conflicts.keys(), key=lambda k: k.lower()):
            has_conflict = False
            entries = conflicts[key]
            # Detectar conflicto si un modo tiene >1 acción
            for mode, lst in entries.items():
                actions = {a for a, _, _ in lst}
                if len(actions) > 1:
                    has_conflict = True
                    break
            if not has_conflict:
                continue
            lines.append(f"- Tecla {self.format_key_combination(key)}:")
            for mode in sorted(entries.keys()):
                lst = entries[mode]
                actions_map: Dict[str, List[Tuple[str, int]]] = {}
                for action_display, rel_path, line in lst:
                    actions_map.setdefault(action_display, []).append((rel_path, line))
                if len(actions_map) <= 1:
                    continue
                mode_chip = self.modes_to_chips([mode]) if mode != 'N/A' else ''
                lines.append(f"  - {mode if not mode_chip else mode_chip}: ")
                for action_display, locs in actions_map.items():
                    links = ", ".join([f"[{p}:L{ln}]({p}#L{ln})" for p, ln in locs])
                    lines.append(f"    - {action_display} — {links}")
        return "\n".join(lines) if lines else "No se detectaron conflictos relevantes."

    def generate_essentials_section(self, keybindings: List[Keybinding]) -> str:
        """Selecciona y muestra un conjunto de atajos esenciales a modo de cheat sheet."""
        # Puntuación heurística
        scores: List[Tuple[int, Keybinding]] = []
        for kb in keybindings:
            text = f"{kb.description} {kb.action}".lower()
            score = 0
            # Bonus por teclas comunes
            common_keys = ['jj', 'escape', 'j', 'k', 'n', 'N', 'p', 'x', 'X', '<C-d>', '<C-u>', 'gl', 'gh']
            if any(ck.lower() in kb.key.lower() for ck in common_keys):
                score += 3
            # Bonus por navegación/búsqueda/edición básicas
            for kw in ['buscar', 'siguiente', 'anterior', 'unir', 'pegar', 'eliminar', 'indent', 'escape']:
                if kw in text:
                    score += 2
            # Penalizar acciones de plugin menos generales
            if 'plugin' in text or 'lazygit' in text:
                score -= 2
            # Preferir modos Normal/Visual
            if 'Normal' in kb.modes:
                score += 1
            if 'Visual' in kb.modes:
                score += 1
            scores.append((score, kb))

        # Top únicos por tecla+acción
        scores.sort(key=lambda t: (-t[0], t[1].key.lower()))
        seen = set()
        selected: List[Keybinding] = []
        for _, kb in scores:
            key = kb.key
            action_display = kb.description if kb.description else kb.action
            if not action_display:
                continue
            sig = (key, action_display)
            if sig in seen:
                continue
            seen.add(sig)
            selected.append(kb)
            if len(selected) >= 20:
                break

        # Render como lista simple
        lines = []
        for kb in selected:
            rel_path = os.path.relpath(kb.file_path, self.repo_root)
            action_display = kb.description if kb.description else kb.action
            chips = self.modes_to_chips(kb.modes)
            lines.append(f"- {self.format_key_combination(kb.key)} {chips} — {action_display}")
        return "\n".join(lines) if lines else "(Sin elementos esenciales detectados)"

    def generate_leader_tree_section(self, keybindings: List[Keybinding]) -> str:
        """Construye un árbol con prefijo <leader> y <localleader>."""
        # Extraer solo leader keys
        leaders = [kb for kb in keybindings if '<leader>' in kb.key.lower() or '<localleader>' in kb.key.lower()]
        if not leaders:
            return "(No se detectaron atajos con <leader>)"

        # Árbol simple: prefix -> next char/segment -> acciones
        tree: Dict[str, Dict[str, List[Keybinding]]] = {}
        for kb in leaders:
            key = kb.key
            if key.lower().startswith('<localleader>'):
                root = '<localleader>'
                rest = key[len('<localleader>'):]
            else:
                root = '<leader>'
                rest = key[len('<leader>'):]
            head = rest[:1] if rest else ''
            branch = rest[1:] if len(rest) > 1 else ''
            node_key = head or '(sin subprefijo)'
            tree.setdefault(root, {}).setdefault(node_key, []).append(kb)

        # Render en bloque colapsable por root
        out = []
        for root in ['<leader>', '<localleader>']:
            if root not in tree:
                continue
            out.append(f"<details>\n<summary>{root}</summary>\n\n")
            for node_key in sorted(tree[root].keys()):
                out.append(f"- {root}{node_key}\n")
                kbs = tree[root][node_key]
                # listar acciones bajo este nodo
                for kb in kbs:
                    action_display = kb.description if kb.description else kb.action
                    chips = self.modes_to_chips(kb.modes)
                    out.append(f"  - {self.format_key_combination(kb.key)} {chips} — {action_display}\n")
            out.append("\n</details>\n\n")
        return "".join(out)

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
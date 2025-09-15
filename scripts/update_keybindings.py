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
        
        # Extensión: entradas estilo Snacks (tablas keys y mapeos con índice entre corchetes)
        try:
            snacks_kbs = self.extract_snacks_style_keybindings(file_path, content)
            keybindings.extend(snacks_kbs)
        except Exception as e:
            print(f"Aviso: no se pudieron extraer Snacks keys en {file_path}: {e}")

        # Extensión: which-key tables (which_key.add({...}) / local <name> = { mode=..., { '<key>', ... } })
        try:
            wk_kbs = self.extract_which_key_style_keybindings(file_path, content)
            keybindings.extend(wk_kbs)
        except Exception as e:
            print(f"Aviso: no se pudieron extraer which-key keys en {file_path}: {e}")

        # Extensión: defaults derivados de ejemplos cuando add_default_keybindings = true
        try:
            ex_kbs = self.extract_exercism_default_keybindings(file_path, content)
            keybindings.extend(ex_kbs)
        except Exception as e:
            print(f"Aviso: no se pudieron extraer defaults por ejemplos en {file_path}: {e}")

        # Extensión: defaults para PickMe (detecta add_keymap(...) incluso si está comentado)
        try:
            pickme_kbs = self.extract_pickme_default_keybindings(file_path, content)
            keybindings.extend(pickme_kbs)
        except Exception as e:
            print(f"Aviso: no se pudieron extraer defaults de PickMe en {file_path}: {e}")

        # Extensión: defaults para Nerdy (si add_default_keybindings = true)
        try:
            nerdy_kbs = self.extract_nerdy_default_keybindings(file_path, content)
            keybindings.extend(nerdy_kbs)
        except Exception as e:
            print(f"Aviso: no se pudieron extraer defaults de Nerdy en {file_path}: {e}")

        return keybindings

    # =====================
    #  Snacks keys parsing
    # =====================
    def _find_matching_paren(self, text: str, start_index: int) -> int:
        """Devuelve el índice de la ')' que cierra el bloque iniciado en start_index (posición del '(').
        Ignora paréntesis dentro de cadenas simples o dobles. Retorna -1 si no encuentra cierre.
        """
        depth = 0
        in_string: Optional[str] = None
        i = start_index
        while i < len(text):
            ch = text[i]
            if in_string:
                if ch == in_string:
                    if i > 0 and text[i - 1] == '\\':
                        i += 1
                        continue
                    in_string = None
                i += 1
                continue
            if ch in ('"', "'"):
                in_string = ch
                i += 1
                continue
            if ch == '(':
                depth += 1
            elif ch == ')':
                depth -= 1
                if depth == 0:
                    return i
            i += 1
        return -1
    def _find_matching_brace(self, text: str, start_index: int) -> int:
        """Devuelve el índice de la '}' que cierra el bloque iniciado en start_index (que debe estar en '{').
        Ignora llaves dentro de cadenas simples o dobles. Retorna -1 si no encuentra cierre.
        """
        depth = 0
        in_string: Optional[str] = None
        i = start_index
        while i < len(text):
            ch = text[i]
            if in_string:
                if ch == in_string:
                    # comprobar escape simple \
                    if i > 0 and text[i - 1] == '\\':
                        i += 1
                        continue
                    in_string = None
                i += 1
                continue
            if ch in ('"', "'"):
                in_string = ch
                i += 1
                continue
            if ch == '{':
                depth += 1
            elif ch == '}':
                depth -= 1
                if depth == 0:
                    return i
            i += 1
        return -1

    def _parse_modes_from_inner(self, inner: str) -> List[str]:
        """Extrae modos desde una tabla interna `mode = ...` dentro de una entrada de keys."""
        # Tabla de modos: mode = { 'n', 'x' }
        m_tbl = re.search(r"mode\s*=\s*\{([^}]*)\}", inner, re.MULTILINE | re.DOTALL)
        if m_tbl:
            inner_modes = m_tbl.group(1)
            return self.normalize_modes(inner_modes)
        # Modo simple: mode = 'n'
        m_str = re.search(r"mode\s*=\s*(['\"][^'\"]+['\"])", inner)
        if m_str:
            return self.normalize_modes(m_str.group(1))
        return ["Normal"]

    def _parse_desc_from_inner(self, inner: str) -> str:
        m_desc = re.search(r"desc\s*=\s*['\"]([^'\"]+)['\"]", inner)
        if m_desc:
            return m_desc.group(1).strip()
        return ""

    def extract_snacks_style_keybindings(self, file_path: str, content: str) -> List[Keybinding]:
        """Extrae keybindings de bloques estilo Snacks:
        - keys = { ['nombre'] = { '<tecla>', ..., desc = '...', mode = 'n'|{'n','x'} } }
        - Bloques indexados por clave entre corchetes con descripción (p.ej., scope.jump['[a'] = { desc = '...' })
        """
        keybindings: List[Keybinding] = []

        # Buscar cualquier entrada del tipo ['algo'] = { ... }
        entry_start_re = re.compile(r"\[\s*(['\"][^'\"]+['\"])\s*\]\s*=\s*\{", re.MULTILINE)
        for m in entry_start_re.finditer(content):
            table_key_raw = m.group(1).strip("'\"")
            inner_start = m.end()  # posición justo después de '{'
            inner_end = self._find_matching_brace(content, inner_start - 1)
            if inner_end == -1:
                continue
            inner = content[inner_start:inner_end]

            # Determinar la tecla efectiva
            # Buscar cadenas candidatas dentro de la tabla y elegir la que parezca una tecla
            str_literals = re.findall(r"['\"]([^'\"]+)['\"]", inner)
            key_combo = None
            for lit in str_literals:
                lit_strip = lit.strip()
                if (
                    lit_strip.startswith('<') or
                    '<leader>' in lit_strip.lower() or '<localleader>' in lit_strip.lower() or
                    re.fullmatch(r"[A-Za-z0-9]{1,3}", lit_strip) is not None
                ):
                    key_combo = lit_strip
                    break
            if not key_combo:
                # Usar la clave del índice como fallback (p.ej. '[a', ']a')
                key_combo = table_key_raw

            modes = self._parse_modes_from_inner(inner)
            description = self._parse_desc_from_inner(inner)

            # Número de línea aproximado
            line_number = content[:m.start()].count('\n') + 1

            # Si no hay descripción, intentar comentario cercano
            if not description:
                description = self.extract_description_from_comment(content, max(0, line_number - 1))

            # Filtro básico de plausibilidad para evitar falsos positivos
            plausible_key = key_combo.startswith('<') or len(key_combo) <= 5
            if not description and not plausible_key:
                continue

            kb = Keybinding(
                file_path=file_path,
                modes=modes,
                key=key_combo,
                action=description or "Acción de plugin",
                description=description,
                context="Snacks keys",
                line_number=line_number,
            )
            keybindings.append(kb)

        return keybindings

    # ========================
    #  which-key.lua parsing
    # ========================
    def _parse_mode_from_table_header(self, table_inner: str) -> List[str]:
        """Extrae el/los modos definidos en la cabecera de una tabla which-key: mode = 'n' | {'n','v'}.
        Si no se encuentra, retorna ["Normal"].
        """
        # Tabla de modos: mode = { 'n', 'x' }
        m_tbl = re.search(r"mode\s*=\s*\{([^}]*)\}", table_inner, re.MULTILINE | re.DOTALL)
        if m_tbl:
            inner_modes = m_tbl.group(1)
            modes = self.normalize_modes(inner_modes)
            return modes if modes else ["Normal"]
        # Modo simple: mode = 'n'
        m_str = re.search(r"mode\s*=\s*(['\"][^'\"]+['\"])", table_inner)
        if m_str:
            modes = self.normalize_modes(m_str.group(1))
            return modes if modes else ["Normal"]
        return ["Normal"]

    def _iter_top_level_entries(self, inner: str) -> List[str]:
        """Devuelve una lista de strings, cada uno correspondiente a una entrada top-level
        del tipo { ... } dentro de la tabla principal which-key (ignorando campos tipo mode=...).
        Usa un pequeño parser por llaves a nivel de la tabla.
        """
        entries: List[str] = []
        i = 0
        length = len(inner)
        in_string: Optional[str] = None
        depth = 0
        start_idx: Optional[int] = None
        while i < length:
            ch = inner[i]
            if in_string is not None:
                if ch == in_string:
                    # comprobar escape
                    if i > 0 and inner[i - 1] == '\\':
                        i += 1
                        continue
                    in_string = None
                i += 1
                continue
            if ch in ('"', "'"):
                in_string = ch
                i += 1
                continue
            if ch == '{':
                if depth == 0:
                    start_idx = i
                depth += 1
            elif ch == '}':
                depth -= 1
                if depth == 0 and start_idx is not None:
                    entry = inner[start_idx:i + 1]
                    # filtrar objetos que son asignaciones con clave (p.ej., foo = {...});
                    # nos interesan los literales de entrada que empiezan por '{' y no contienen '=' antes de la primera coma
                    entries.append(entry)
                    start_idx = None
            i += 1
        return entries

    def _parse_entry_kb(self, file_path: str, modes_default: List[str], entry: str, content_for_comments: str, line_offset: int) -> Optional['Keybinding']:
        """Intenta extraer un Keybinding desde una entrada { '<key>', ... } de which-key.
        Retorna None si no es válida.
        """
        # Debe comenzar con '{'
        if not entry.strip().startswith('{'):
            return None
        # Buscar primera cadena: la tecla
        str_literals = re.findall(r"['\"]([^'\"]+)['\"]", entry)
        if not str_literals:
            return None
        key = str_literals[0].strip()
        # Filtrar claves genéricas o no válidas
        if key.lower() in ('<leader>', '<auto>'):
            return None

        # Detectar si es un grupo (group = '...')
        m_group = re.search(r"group\s*=\s*['\"]([^'\"]+)['\"]", entry)
        m_desc = re.search(r"desc\s*=\s*['\"]([^'\"]+)['\"]", entry)
        # Modo por entrada (override)
        entry_modes: Optional[List[str]] = None
        m_entry_mode_tbl = re.search(r"mode\s*=\s*\{([^}]*)\}", entry)
        if m_entry_mode_tbl:
            entry_modes = self.normalize_modes(m_entry_mode_tbl.group(1))
        else:
            m_entry_mode_str = re.search(r"mode\s*=\s*(['\"][^'\"]+['\"])", entry)
            if m_entry_mode_str:
                entry_modes = self.normalize_modes(m_entry_mode_str.group(1))

        modes = entry_modes if entry_modes else modes_default

        description = ""
        if m_desc:
            description = m_desc.group(1).strip()
        elif m_group:
            description = m_group.group(1).strip()
        else:
            # Comentario cercano si no hay desc
            # Calcular número de línea aproximado
            line_number = content_for_comments[:line_offset].count('\n') + entry[:entry.find('{')].count('\n') + 1
            description = self.extract_description_from_comment(content_for_comments, max(0, line_number - 1))

        # Intentar detectar acción: segundo literal tipo comando ':...' o '<...>' si no hay desc/grupo
        action = description or "Acción de which-key"
        if len(str_literals) >= 2:
            second = str_literals[1].strip()
            # Si hay group, el segundo literal suele ser el valor del grupo; ignorar como acción
            if not m_group:
                if second.startswith(':') or '<' in second or second.endswith('<cr>') or re.match(r'^:[A-Za-z]', second):
                    action = second

        # Número de línea aproximado (inicio de la entrada dentro del archivo)
        # Aproximación del número de línea: inicio del bloque donde vive la entrada
        abs_line_number = content_for_comments[:line_offset].count('\n') + 1

        # Contexto: marcar explícitamente si es encabezado de grupo
        context_value = "which-key-group" if m_group else "which-key"

        return Keybinding(
            file_path=file_path,
            modes=modes,
            key=key,
            action=action if action else (description or "Acción de which-key"),
            description=description,
            context=context_value,
            line_number=abs_line_number,
        )

    def extract_which_key_style_keybindings(self, file_path: str, content: str) -> List['Keybinding']:
        """Extrae keybindings definidos en tablas which-key como:
        local name = { mode = 'n', { '<key>', ':cmd', desc = '...' }, { '<key2>', group = '...' } }
        y entradas añadidas con table.insert(name, { ... }).
        """
        # Restringir a archivos which-key.lua
        try:
            base = os.path.basename(file_path)
        except Exception:
            base = file_path
        if not base.endswith('which-key.lua'):
            return []

        results: List[Keybinding] = []

        # Determinar cuáles tablas parsear: aquellas pasadas a which_key.add(<name>)
        allowed_names: set = set()
        for m in re.finditer(r"which_key\.add\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)", content):
            allowed_names.add(m.group(1))

        # Mapear nombre de tabla -> modos
        var_modes: Dict[str, List[str]] = {}

        # Capturar definiciones: (local )?<name> = { ... }
        assign_re = re.compile(r"(?:local\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*\{", re.MULTILINE)
        for m in assign_re.finditer(content):
            var_name = m.group(1)
            if allowed_names and var_name not in allowed_names:
                continue
            start = m.end() - 1  # posición del '{'
            end = self._find_matching_brace(content, start)
            if end == -1:
                continue
            inner = content[start + 1:end]
            modes = self._parse_mode_from_table_header(inner)
            var_modes[var_name] = modes

            # Iterar entradas top-level dentro de la tabla
            entries = self._iter_top_level_entries(inner)
            # Calcular offset para líneas
            line_offset = m.end()
            for entry in entries:
                # Saltar si parece una asignación de campo (p.ej., mode = 'n')
                if re.match(r"^\s*\{\s*['\"]", entry) is None:
                    continue
                kb = self._parse_entry_kb(file_path, modes, entry, content, line_offset)
                if kb:
                    results.append(kb)

        # Capturar table.insert(name, { ... })
        insert_re = re.compile(r"table\.insert\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*,\s*\{", re.MULTILINE)
        for m in insert_re.finditer(content):
            var_name = m.group(1)
            if allowed_names and var_name not in allowed_names:
                continue
            start = m.end() - 1
            end = self._find_matching_brace(content, start)
            if end == -1:
                continue
            inner_entry = content[start:end + 1]
            modes = var_modes.get(var_name, ["Normal"])
            kb = self._parse_entry_kb(file_path, modes, inner_entry, content, m.start())
            if kb:
                results.append(kb)

        # Heurística adicional: detectar mapeos numéricos con string.format('<leader>..%d', i)
        numeric_insert_re = re.compile(
            r"table\.insert\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*,\s*\{\s*string\.format\(\s*(['\"][^'\"]+['\"])",
            re.MULTILINE,
        )
        seen_keys = {(kb.key, tuple(kb.modes)) for kb in results}
        for m in numeric_insert_re.finditer(content):
            var_name = m.group(1)
            if allowed_names and var_name not in allowed_names:
                continue
            key_lit = m.group(2).strip('"\'')
            if '%d' not in key_lit:
                continue
            modes = var_modes.get(var_name, ["Normal"])
            sig = (key_lit, tuple(modes))
            if sig in seen_keys:
                continue
            results.append(Keybinding(
                file_path=file_path,
                modes=modes,
                key=key_lit,
                action="Numerical mappings",
                description="Numerical mappings",
                context="which-key",
                line_number=content[:m.start()].count('\n') + 1,
            ))
            seen_keys.add(sig)

        return results

        # Helper function used in _parse_entry_kb; placed here to avoid top-level clutter
    

    def extract_exercism_default_keybindings(self, file_path: str, content: str) -> List['Keybinding']:
        """Detecta `add_default_keybindings = true` en cualquier archivo Lua.

        - Si hay un bloque de ejemplo (aunque esté comentado) con entradas del tipo
          { '<tecla>', ':Comando<CR>', 'Descripción' }, se agregan como defaults.
        - Si no hay ejemplo y el archivo parece de Exercism, se usa un fallback conocido.
        """
        m_flag = re.search(r"add_default_keybindings\s*=\s*true", content)
        if not m_flag:
            return []

        flag_line = content[: m_flag.start()].count('\n') + 1

        # Ventana acotada tras la bandera para buscar ejemplos
        lines = content.split('\n')
        start_line_idx = max(0, flag_line - 1)
        end_line_idx = min(len(lines), start_line_idx + 200)
        window = '\n'.join(lines[start_line_idx:end_line_idx])

        example_items: List[Tuple[str, str, str]] = []
        triple_re = re.compile(
            r"\{\s*['\"]([^'\"]+)['\"]\s*,\s*['\"]([^'\"]+)['\"]\s*,\s*['\"]([^'\"]+)['\"]\s*\}\s*,?",
            re.MULTILINE,
        )
        for m in triple_re.finditer(window):
            key = m.group(1).strip()
            action_cmd = m.group(2).strip()
            desc = m.group(3).strip()
            if not key or not desc:
                continue
            example_items.append((key, action_cmd, desc))

        base = os.path.basename(file_path)
        looks_like_exercism = base.endswith('exercism.lua') or 'exercism' in content.lower()
        if not example_items and looks_like_exercism:
            example_items = [
                ("<leader>exa", ":Exercism languages<CR>", "All Exercism Languages"),
                ("<leader>exl", ":Exercism list<CR>", "List Default Language Exercises"),
                ("<leader>exr", ":Exercism recents<CR>", "Recent Exercises"),
                ("<leader>ext", ":Exercism test<CR>", "Test Exercise"),
                ("<leader>exs", ":Exercism submit<CR>", "Submit Exercise"),
            ]

        if not example_items:
            return []

        kbs: List[Keybinding] = []
        context_note = "Exercism defaults (auto)" if looks_like_exercism else "Defaults (auto)"
        line_offset = 0
        for key, action_cmd, desc in example_items:
            kbs.append(
                Keybinding(
                    file_path=file_path,
                    modes=["Normal"],
                    key=key,
                    action=action_cmd,
                    description=desc,
                    context=context_note,
                    line_number=flag_line + line_offset,
                )
            )
            line_offset += 1

        return kbs


    def extract_pickme_default_keybindings(self, file_path: str, content: str) -> List['Keybinding']:
        """Detecta `add_default_keybindings = true` y extrae ejemplos de PickMe del tipo
        add_keymap('<key>', ':PickMe ...<cr>', 'Descripción') aunque estén comentados.
        """
        # Requiere la bandera
        if re.search(r"add_default_keybindings\s*=\s*true", content) is None:
            return []

        # Remover prefijos de comentario al inicio de líneas para permitir detectar llamadas comentadas
        search_text = re.sub(r"(?m)^\s*--\s*", "", content)

        # Buscar posiciones de 'add_keymap(' y extraer con emparejado de paréntesis
        add_pos_re = re.compile(r"add_keymap\s*\(")
        # Literal de string robusto: '...' o "..." con escapes
        str_lit_re = re.compile(r"'(?:[^'\\]|\\.)*'|\"(?:[^\"\\]|\\.)*\"")

        def unquote(value: str) -> str:
            """Quita comillas de un literal y desescapa comillas/backslashes básicos."""
            value = value.strip()
            if len(value) >= 2 and value[0] in ("'", '"') and value[-1] == value[0]:
                quote = value[0]
                inner = value[1:-1]
                inner = inner.replace('\\\\', '\\')
                if quote == '"':
                    inner = inner.replace('\\"', '"')
                else:
                    inner = inner.replace("\\'", "'")
                return inner
            return value

        kbs: List[Keybinding] = []
        for m in re.finditer(r"add_keymap\s*\(", search_text):
            open_idx = m.end() - 1  # posición del '('
            close_idx = self._find_matching_paren(search_text, open_idx)
            if close_idx == -1:
                continue
            inner_args = search_text[open_idx + 1:close_idx]
            # Quitar prefijos de comentario intra-llamada por si cada argumento está comentado en su línea
            inner_clean = re.sub(r"(?m)^\s*--\s*", "", inner_args)
            lits = str_lit_re.findall(inner_clean)
            if len(lits) < 3:
                continue
            key = unquote(lits[0])
            action_cmd = unquote(lits[1])
            desc = unquote(lits[2])
            # Filtro rápido: asegurarnos de que parece un comando de PickMe o una acción razonable
            if not key or not desc:
                continue
            # Número de línea aproximado
            line_number = search_text[: m.start()].count('\n') + 1
            kbs.append(
                Keybinding(
                    file_path=file_path,
                    modes=["Normal"],
                    key=key,
                    action=action_cmd or desc,
                    description=desc,
                    context="PickMe defaults (auto)",
                    line_number=line_number,
                )
            )

        return kbs

    def extract_nerdy_default_keybindings(self, file_path: str, content: str) -> List['Keybinding']:
        """Detecta `add_default_keybindings = true` en nerdy.lua y agrega atajos por defecto.

        Por convención de 2kabhishek/nerdy.nvim, cuando está activo:
        - <leader>in -> :Nerdy list<CR>
        - <leader>iN -> :Nerdy recents<CR>
        """
        # Verificar bandera
        if re.search(r"add_default_keybindings\s*=\s*true", content) is None:
            return []

        # Asegurar que el archivo es el de nerdy o contiene referencia clara
        base = os.path.basename(file_path)
        looks_like_nerdy = base.endswith('nerdy.lua') or 'require(' in content and 'nerdy' in content
        if not looks_like_nerdy:
            return []

        # Construir keybindings por defecto
        kbs: List[Keybinding] = []
        flag_line = content[: re.search(r"add_default_keybindings\s*=\s*true", content).start()].count('\n') + 1
        defaults = [
            ("<leader>in", ":Nerdy list<CR>", "Nerdy: List Icons"),
            ("<leader>iN", ":Nerdy recents<CR>", "Nerdy: Recent Icons"),
        ]
        line_offset = 0
        for key, action_cmd, desc in defaults:
            kbs.append(
                Keybinding(
                    file_path=file_path,
                    modes=["Normal"],
                    key=key,
                    action=action_cmd,
                    description=desc,
                    context="Nerdy defaults (auto)",
                    line_number=flag_line + line_offset,
                )
            )
            line_offset += 1

        return kbs

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
            'lua/plugins/lazy.lua',
            'lua/plugins/ui/which-key.lua'
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

                    # Vista principal
                    if 'which-key.lua' in file_path:
                        # Para which-key, render en formato "pretty" por grupos y modos
                        doc += self.generate_which_key_pretty_sections(file_keybindings)
                    else:
                        # Por categoría (comportamiento estándar)
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
                if 'which-key.lua' in file_path:
                    doc += self.generate_which_key_pretty_sections(file_keybindings)
                else:
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

    def generate_which_key_group_section(self, keybindings: List[Keybinding], heading_level: str = '####') -> str:
        """Agrupa which-key por modo y, dentro de cada modo, por grupos (group = ...).
        - Para cada modo presente (Normal, Visual, Insert, ...):
          - Se crean secciones por cada grupo detectado (índice visual), aunque estén vacías.
          - Las entradas sin grupo van en "Otros (Modo)".
        """
        if not keybindings:
            return ""

        # Orden de modos fijo
        mode_order = ['Normal', 'Visual', 'Select', 'Insert', 'Terminal', 'Command', 'Operator']

        # Construir mapa modo -> keybindings en ese modo
        per_mode: Dict[str, List[Keybinding]] = {m: [] for m in mode_order}
        for kb in keybindings:
            modes = kb.modes if kb.modes else ['Normal']
            for m in modes:
                if m in per_mode:
                    per_mode[m].append(kb)

        out: List[str] = []

        for mode in mode_order:
            mode_kbs = per_mode.get(mode, [])
            if not mode_kbs:
                continue

            # 1) Detectar grupos de este modo: key -> nombre
            group_prefix_to_name: Dict[str, str] = {}
            for kb in mode_kbs:
                if kb.context == 'which-key-group' and kb.key.lower().startswith('<leader>') and len(kb.key) == len('<leader>') + 1:
                    group_name = kb.description or kb.action
                    if group_name:
                        group_prefix_to_name[kb.key] = group_name

            # 2) Asignar a grupos u "otros" (sólo entradas de este modo)
            grouped: Dict[str, List[Keybinding]] = {name: [] for name in group_prefix_to_name.values()}
            others: List[Keybinding] = []

            def prefix_order(p: str) -> str:
                rest = p[len('<leader>'):] if p.lower().startswith('<leader>') else p
                return rest

            ordered_prefixes = sorted(group_prefix_to_name.keys(), key=prefix_order)

            for kb in mode_kbs:
                # Saltar encabezados de grupo
                if kb.context == 'which-key-group' and kb.key in group_prefix_to_name:
                    continue
                placed = False
                for prefix in ordered_prefixes:
                    if kb.key.lower().startswith(prefix.lower()):
                        grouped[group_prefix_to_name[prefix]].append(kb)
                        placed = True
                        break
                if not placed:
                    others.append(kb)

            # 3) Render grupos de este modo
            for prefix in ordered_prefixes:
                group_name = group_prefix_to_name[prefix]
                items = grouped.get(group_name, [])
                out.append(f"{heading_level} {group_name}\n\n")
                out.append(self.generate_markdown_table(items))
                out.append("\n")

            # 4) Otros (Modo)
            out.append(f"{heading_level} Otros ({mode})\n\n")
            out.append(self.generate_markdown_table(others))
            out.append("\n")

        return "".join(out)

    # ========================
    # Pretty which-key renderer
    # ========================
    def generate_which_key_pretty_sections(self, keybindings: List[Keybinding]) -> str:
        """Genera la documentación de which-key con el formato deseado:
        - "Leader Bindings (Normal Mode)" con grupos tipo "a - AI" y tabla Keybinding/Action
        - "Leader Bindings (Visual Mode)" similar
        - "Non Leader Bindings" para claves sin <leader>
        """
        if not keybindings:
            return ""

        # Helpers
        def get_group_map(kbs: List[Keybinding]) -> Dict[str, str]:
            groups: Dict[str, str] = {}
            for kb in kbs:
                if kb.context == 'which-key-group' and kb.key.lower().startswith('<leader>') and len(kb.key) == len('<leader>') + 1:
                    lead_char = kb.key[len('<leader>'):]  # una sola letra
                    groups[lead_char] = kb.description or kb.action
            return groups

        def format_leader_sequence(key: str) -> str:
            # Espera prefijo <leader>
            rest = key[len('<leader>'):] if key.lower().startswith('<leader>') else key
            # Placeholder numérico
            if '%d' in rest:
                head = rest.replace('%d', '').strip()
                rest_fmt = f"{head} 1..9".strip()
            else:
                # separa por caracteres individuales
                rest_fmt = " ".join(list(rest))
            return f"<kbd>Leader</kbd> <kbd> {rest_fmt} </kbd>"

        def table_rows_for_group(kbs: List[Keybinding], prefix: str) -> str:
            rows = []
            for kb in sorted(kbs, key=lambda x: x.key.lower()):
                if kb.context == 'which-key-group':
                    continue
                if not kb.key.lower().startswith(prefix.lower()):
                    continue
                key_disp = format_leader_sequence(kb.key)
                action_disp = kb.description or kb.action or "(sin acción)"
                rows.append(f"| {key_disp:<34} | {action_disp} |")
            return "\n".join(rows)

        def render_leader_mode(mode_name: str, kbs: List[Keybinding]) -> str:
            out: List[str] = []
            if not kbs:
                return ""
            # Título de modo
            if mode_name == 'Normal':
                out.append("## Leader Bindings (Normal Mode)\n\n")
                out.append("> Leader == <kbd>Space</kbd>\n\n")
            elif mode_name == 'Visual':
                out.append("## Leader Bindings (Visual Mode)\n\n")
            else:
                out.append(f"## Leader Bindings ({mode_name} Mode)\n\n")

            group_map = get_group_map(kbs)
            for lead_char in sorted(group_map.keys()):
                group_name = group_map[lead_char]
                out.append(f"### {lead_char} - {group_name}\n\n")
                out.append("| Keybinding                         | Action         |\n")
                out.append("| ---------------------------------- | -------------- |\n")
                rows = table_rows_for_group(kbs, f"<leader>{lead_char}")
                out.append(rows + "\n\n" if rows else "\n")
            return "".join(out)

        def render_non_leader(kbs: List[Keybinding]) -> str:
            non_leader = [kb for kb in kbs if not kb.key.lower().startswith('<leader>')]
            if not non_leader:
                return ""
            out: List[str] = []
            out.append("## Non Leader Bindings\n\n")
            out.append("| Keybinding                         | Action                 |\n")
            out.append("| ---------------------------------- | ---------------------- |\n")
            for kb in sorted(non_leader, key=lambda x: x.key.lower()):
                key_fmt = self.format_key_combination(kb.key)
                action_disp = kb.description or kb.action or "(sin acción)"
                out.append(f"| {key_fmt:<34} | {action_disp:<22} |\n")
            out.append("\n")
            return "".join(out)

        # Agrupar por modo
        mode_to_kbs: Dict[str, List[Keybinding]] = {}
        for kb in keybindings:
            modes = kb.modes if kb.modes else ['Normal']
            for m in modes:
                mode_to_kbs.setdefault(m, []).append(kb)

        out: List[str] = []
        # Render Normal, Visual en ese orden
        for mode in ['Normal', 'Visual']:
            out.append(render_leader_mode(mode, mode_to_kbs.get(mode, [])))
        # Render otros modos si existiesen
        for mode in sorted([m for m in mode_to_kbs.keys() if m not in ['Normal', 'Visual']]):
            out.append(render_leader_mode(mode, mode_to_kbs.get(mode, [])))

        # Non leader (de este archivo)
        all_kbs = keybindings
        out.append(render_non_leader(all_kbs))

        return "".join(out)

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
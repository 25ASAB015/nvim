# [Roberto nvim](https://github.com/25ASAB015/nvim)

[Atajos de teclado](https://github.com/25ASAB015/nvim/blob/main/docs/keybindings.md)

Aquí están todos los atajos de teclado definidos para mi configuración de Neovim.

## Atajos con Leader (Modo Normal)

> Leader == <kbd>Espacio</kbd>

## Índice

- [Por archivo](#por-archivo)
- [Conflictos y solapamientos](#conflictos-y-solapamientos)
- [Notas y pendientes](#notas-y-pendientes)

## Por archivo

### [lua/core/keys.lua](lua/core/keys.lua)

#### Navegación

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Notas/Duplicados                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd>gh</kbd>                         | Inicio de línea                                     | [N] [V]         |                                     |
| <kbd>gl</kbd>                         | Fin de línea                                        | [N] [V]         |                                     |
| <kbd>J</kbd>                          | Unir líneas y centrar cursor                        | [N]             | Acción distinta por modo            |
| <kbd>J</kbd>                          | Mover bloques de texto seleccionados arriba y abajo en visual | [V]             | Acción distinta por modo            |
| <kbd>j</kbd>                          | Bajar línea real                                    | [N]             |                                     |
| <kbd>k</kbd>                          | Subir línea real                                    | [N]             |                                     |
| <kbd>K</kbd>                          | Mover bloques de texto seleccionados arriba y abajo en visual | [V]             |                                     |
| <kbd>p</kbd>                          | Pegar sobre texto visual seleccionado sin sobreescribir el registro ("paste sin perder el clipboard") | [V]             |                                     |
| <kbd>X</kbd>                          | Eliminar hasta el final, sin copiar                 | [N]             |                                     |

#### Búsqueda

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Notas/Duplicados                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd>n</kbd>                          | Buscar siguiente y centrar                          | [N]             | Acción distinta por modo            |
| <kbd>n</kbd>                          | Siguiente resultado                                 | [N] [V] [O]     | Acción distinta por modo            |
| <kbd>N</kbd>                          | Buscar anterior y centrar                           | [N]             | Acción distinta por modo            |
| <kbd>N</kbd>                          | Anterior resultado                                  | [N] [V] [O]     | Acción distinta por modo            |

#### Edición

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Notas/Duplicados                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><</kbd>                          | Indentado persistente en modo visual                | [V]             |                                     |
| <kbd>></kbd>                          | Indentado persistente en modo visual                | [V]             |                                     |
| <kbd>x</kbd>                          | Eliminar texto en visual sin copiar al registro principal | [V]             |                                     |
| <kbd>X</kbd>                          | Eliminar selección, sin copiar                      | [V]             |                                     |

#### Otros

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Notas/Duplicados                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd>,</kbd>                          | Punto de interrupción de undo tras ciertos caracteres en insert | [I]             |                                     |
| <kbd>-</kbd>                          | Placeholder para decremento                         | [N] [V]         |                                     |
| <kbd>.</kbd>                          | Punto de interrupción de undo tras ciertos caracteres en insert | [I]             |                                     |
| <kbd>;</kbd>                          | ;<C-g>u                                             | [I]             |                                     |
| <kbd><Ctrl-d></kbd>                   | Half-page down y centrar                            | [N]             |                                     |
| <kbd><Ctrl-u></kbd>                   | Half-page up y centrar                              | [N]             |                                     |
| <kbd>Escape</kbd>                     | Escape y limpia búsqueda                            | [N] [I]         |                                     |
| <kbd>=</kbd>                          | Placeholder para incremento                         | [N] [V]         |                                     |
| <kbd>jj</kbd>                         | Rápido escape en Insert Mode                        | [I]             |                                     |
| <kbd>JJ</kbd>                         | Escape en Terminal Mode                             | [T]             |                                     |


#### Líder global/local: <kbd>Espacio</kbd>
- Asignado como "líder" (mapleader y maplocalleader).

---

### [lua/core/autocmd.lua](lua/core/autocmd.lua)

#### Otros

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Notas/Duplicados                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd>q</kbd>                          | <cmd>close<cr>                                      | [N]             |                                     |


---

### [lua/plugins/lazy.lua](lua/plugins/lazy.lua)

**Estos atajos solo están activos dentro de la interfaz del plugin Lazy.**

#### Git

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><localleader>l</kbd>             | Abre lazygit para ver el log del plugin             |                 | Clave personalizada de plugin       |
| <kbd><localleader>t</kbd>             | Abre lazygit para ver el log del plugin             |                 | Clave personalizada de plugin       |


---

### [lua/plugins/ui/onedark.lua](lua/plugins/ui/onedark.lua)

#### UI/Tema

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Notas/Duplicados                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><leader>ot</kbd>                 | Tecla para alternar entre los diferentes estilos del tema | [N]             |                                     |


---

## Conflictos y solapamientos

- Tecla <kbd>n</kbd>:
  - [N]: 
    - Buscar siguiente y centrar — [lua/core/keys.lua:L57](lua/core/keys.lua#L57)
    - Siguiente resultado — [lua/core/keys.lua:L72](lua/core/keys.lua#L72)
- Tecla <kbd>N</kbd>:
  - [N]: 
    - Buscar anterior y centrar — [lua/core/keys.lua:L58](lua/core/keys.lua#L58)
    - Anterior resultado — [lua/core/keys.lua:L75](lua/core/keys.lua#L75)
---

## Notas y pendientes

**Notas generales:**
- Todos los keybindings agrupados por archivo para facilitar la edición.
- Los duplicados se marcan y explican.
- Los keybindings contextuales se destacan indicando el contexto de activación.
- Todo está documentado en español.

⚠️ **Advertencia:** Se encontraron 2 keybindings sin descripción. Considera agregar comentarios descriptivos en el código fuente.

**Keybindings sin descripción:**
- [lua/core/autocmd.lua:L86](lua/core/autocmd.lua#L86) — Tecla: <kbd>q</kbd> — Modos: [N]
- [lua/core/keys.lua:L86](lua/core/keys.lua#L86) — Tecla: <kbd>;</kbd> — Modos: [I]

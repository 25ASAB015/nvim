### lua/core/keys.lua

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Notas/Duplicados                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd>jj</kbd>                         | Rápido escape en Insert Mode                        | Insert          |                                     |
| <kbd>JJ</kbd>                         | Escape en Terminal Mode                             | Terminal        |                                     |
| <kbd>X</kbd>                          | Eliminar hasta el final, sin copiar                 | Normal          | Duplicado: acción distinta          |
| <kbd>J</kbd>                          | Unir líneas y centrar cursor                        | Normal          | Duplicado: acción distinta          |
| <kbd><Ctrl-d></kbd>                   | Half-page down y centrar                            | Normal          |                                     |
| <kbd><Ctrl-u></kbd>                   | Half-page up y centrar                              | Normal          |                                     |
| <kbd>n</kbd>                          | Buscar siguiente y centrar                          | Normal          | Duplicado                           |
| <kbd>N</kbd>                          | Buscar anterior y centrar                           | Normal          | Duplicado                           |
| <kbd>j</kbd>                          | Bajar línea real                                    | Normal          |                                     |
| <kbd>k</kbd>                          | Subir línea real                                    | Normal          |                                     |
| <kbd>n</kbd>                          | Siguiente resultado                                 | Normal          | Duplicado                           |
| <kbd>n</kbd>                          | Siguiente resultado                                 | Block           | Duplicado: acción distinta          |
| <kbd>n</kbd>                          | Siguiente resultado                                 | Operator        | Duplicado: acción distinta          |
| <kbd>N</kbd>                          | Anterior resultado                                  | Normal          | Duplicado                           |
| <kbd>N</kbd>                          | Anterior resultado                                  | Block           | Duplicado: acción distinta          |
| <kbd>N</kbd>                          | Anterior resultado                                  | Operator        | Duplicado: acción distinta          |
| <kbd><</kbd>                          | Indentado persistente en modo visual                | Visual          |                                     |
| <kbd>></kbd>                          | Indentado persistente en modo visual                | Visual          |                                     |
| <kbd>,</kbd>                          | Punto de interrupción de undo tras ciertos caracteres en insert | Insert          |                                     |
| <kbd>.</kbd>                          | Punto de interrupción de undo tras ciertos caracteres en insert | Insert          |                                     |
| <kbd>;</kbd>                          | ;<C-g>u                                             | Insert          |                                     |
| <kbd>p</kbd>                          | Pegar sobre texto visual seleccionado sin sobreescribir el registro ("paste sin perder el clipboard") | Visual, Block   |                                     |
| <kbd>x</kbd>                          | Eliminar texto en visual sin copiar al registro principal | Visual, Block   |                                     |
| <kbd>X</kbd>                          | Eliminar selección, sin copiar                      | Visual, Block   | Duplicado: acción distinta          |
| <kbd>-</kbd>                          | Placeholder para decremento                         | Normal, Visual, Block |                                     |
| <kbd>=</kbd>                          | Placeholder para incremento                         | Normal, Visual, Block |                                     |
| <kbd>gl</kbd>                         | Fin de línea                                        | Normal, Visual, Block |                                     |
| <kbd>gh</kbd>                         | Inicio de línea                                     | Normal, Visual, Block |                                     |
| <kbd>J</kbd>                          | Mover bloques de texto seleccionados arriba y abajo en visual | Visual, Block   | Duplicado: acción distinta          |
| <kbd>K</kbd>                          | Mover bloques de texto seleccionados arriba y abajo en visual | Visual, Block   |                                     |
| <kbd>Escape</kbd>                     | Escape y limpia búsqueda                            | Insert, Normal  |                                     |

#### Líder global/local: <kbd>Espacio</kbd>
- Asignado como "líder" (mapleader y maplocalleader).

---

### lua/core/autocmd.lua

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Notas/Duplicados                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd>q</kbd>                          | <cmd>close<cr>                                      | Normal          |                                     |

---

### lua/plugins/lazy.lua

**Estos atajos solo están activos dentro de la interfaz del plugin Lazy.**

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Notas/Duplicados                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><localleader>l</kbd>             | Abre lazygit para ver el log del plugin             | Custom          |                                     |
| <kbd><localleader>t</kbd>             | Abre lazygit para ver el log del plugin             | Custom          |                                     |

---

### lua/plugins/ui/onedark.lua

**Estos atajos están activos cuando el plugin OneDark está cargado.**

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Notas/Duplicados                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd>'</kbd>                          | Alternar entre estilos del tema OneDark             | Normal          |                                     |

---

**Notas generales:**
- Todos los keybindings agrupados por archivo para facilitar la edición.
- Los duplicados se marcan y explican.
- Los keybindings contextuales se destacan indicando el contexto de activación.
- Todo está documentado en español.

⚠️ **Advertencia:** Se encontraron 2 keybindings sin descripción. Considera agregar comentarios descriptivos en el código fuente.

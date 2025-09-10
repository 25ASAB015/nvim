### lua/core/keys.lua

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Notas/Duplicados                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd>jj</kbd>                         | Rápido escape en Insert Mode                        | Insert          |                                     |
| <kbd>JJ</kbd>                         | Escape en Terminal Mode                             | Terminal        |                                     |
| <kbd>J</kbd>                          | Unir líneas y centrar cursor                        | Normal          |                                     |
| <kbd><Ctrl-d></kbd>                   | Half-page down y centrar                            | Normal          |                                     |
| <kbd><Ctrl-u></kbd>                   | Half-page up y centrar                              | Normal          |                                     |
| <kbd>n</kbd>                          | Buscar siguiente y centrar                          | Normal          |                                     |
| <kbd>N</kbd>                          | Buscar anterior y centrar                           | Normal          |                                     |
| <kbd><</kbd>                          | Indentado persistente en modo visual                | Visual          |                                     |
| <kbd>></kbd>                          | Indentado persistente en modo visual                | Visual          |                                     |
| <kbd>,</kbd>                          | Punto de interrupción de undo tras ciertos caracteres en insert | Insert          |                                     |
| <kbd>.</kbd>                          | Punto de interrupción de undo tras ciertos caracteres en insert | Insert          |                                     |
| <kbd>;</kbd>                          | Punto de interrupción de undo tras ciertos caracteres en insert | Insert          |                                     |
| <kbd>-</kbd>                          | Placeholder para decremento                         | Normal, Visual, Visual, Block |                                     |
| <kbd>=</kbd>                          | Placeholder para incremento                         | Normal, Visual, Visual, Block |                                     |
| <kbd>gl</kbd>                         | Placeholder para incremento                         | Normal, Visual, Visual, Block |                                     |
| <kbd>gh</kbd>                         | Salto rápido a inicio/fin de línea                  | Normal, Visual, Visual, Block |                                     |
| <kbd>Escape</kbd>                     | Limpia el highlight de búsqueda y ajusta pantalla   | Insert, Normal  |                                     |

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
| <kbd><localleader>l</kbd>             | Atajos de teclado personalizados en la interfaz de Lazy | Custom          |                                     |
| <kbd><localleader>t</kbd>             | 't': Abre una terminal en el directorio del plugin  | Custom          |                                     |

---

**Notas generales:**
- Todos los keybindings agrupados por archivo para facilitar la edición.
- Los duplicados se marcan y explican.
- Los keybindings contextuales se destacan indicando el contexto de activación.
- Todo está documentado en español.

⚠️ **Advertencia:** Se encontraron 1 keybindings sin descripción. Considera agregar comentarios descriptivos en el código fuente.

### lua/core/keys.lua

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Notas/Duplicados                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd>jj</kbd>                         | Escape rápido                                       | Insert          |                                    |
| <kbd>JJ</kbd>                         | Escape rápido en terminal                           | Terminal        |                                    |
| <kbd>p</kbd>                          | Pegar sin perder el clipboard                       | Visual, Block   |                                    |
| <kbd>x</kbd>                          | Eliminar sin copiar al registro principal           | Visual, Block   |                                    |
| <kbd>X</kbd>                          | Eliminar hasta el final, sin copiar                 | Normal          |                                    |
| <kbd>X</kbd>                          | Eliminar selección, sin copiar                      | Visual, Block   | Duplicado                         |
| <kbd>-</kbd>                          | Placeholder para decremento                         | Normal, Visual, Block |                                 |
| <kbd>=</kbd>                          | Placeholder para incremento                         | Normal, Visual, Block |                                 |
| <kbd>gl</kbd>                         | Ir al fin de línea                                  | Normal, Visual, Block |                                 |
| <kbd>gh</kbd>                         | Ir al inicio de línea                               | Normal, Visual, Block |                                 |
| <kbd>J</kbd>                          | Unir líneas y centrar cursor                        | Normal          |                                    |
| <kbd>J</kbd>                          | Mover bloque abajo                                  | Visual, Block   | Duplicado: acción distinta         |
| <kbd>K</kbd>                          | Mover bloque arriba                                 | Visual, Block   |                                    |
| <kbd><C-d></kbd>                      | Half-page down y centrar                            | Normal          |                                    |
| <kbd><C-u></kbd>                      | Half-page up y centrar                              | Normal          |                                    |
| <kbd>n</kbd>                          | Buscar siguiente y centrar                          | Normal          |                                    |
| <kbd>N</kbd>                          | Buscar anterior y centrar                           | Normal          |                                    |
| <kbd>j</kbd>                          | Bajar línea real si no hay conteo                   | Normal          |                                    |
| <kbd>k</kbd>                          | Subir línea real si no hay conteo                   | Normal          |                                    |
| <kbd><Esc></kbd>                      | Escape y limpia búsqueda                            | Insert, Normal  |                                    |
| <kbd>n</kbd>                          | Siguiente resultado según dirección búsqueda        | Normal, Block, Operator |                             |
| <kbd>N</kbd>                          | Anterior resultado según dirección búsqueda         | Normal, Block, Operator |                             |
| <kbd><</kbd>                          | Indentar y mantener selección                       | Visual          |                                    |
| <kbd>></kbd>                          | Indentar y mantener selección                       | Visual          |                                    |
| <kbd>,</kbd>                          | Punto de interrupción undo tras coma                | Insert          |                                    |
| <kbd>.</kbd>                          | Punto de interrupción undo tras punto               | Insert          |                                    |
| <kbd>;</kbd>                          | Punto de interrupción undo tras punto y coma        | Insert          |                                    |

#### Líder global/local: <kbd>Espacio</kbd>
- Asignado como "líder" (mapleader y maplocalleader).

---

### lua/plugins/lazy.lua

**Estos atajos solo están activos dentro de la interfaz del plugin Lazy.**

| Combinación de teclas                | Acción (Español)                                   | Contexto/Notas                      |
| ------------------------------------ | -------------------------------------------------- | ----------------------------------- |
| <kbd>LocalLeader</kbd> <kbd>l</kbd> | Abre lazygit para ver el log del plugin            | Solo interfaz Lazy, depende del plugin seleccionado |
| <kbd>LocalLeader</kbd> <kbd>t</kbd> | Abre una terminal en el directorio del plugin      | Solo interfaz Lazy, depende del plugin seleccionado |

---

**Notas generales:**
- Todos los keybindings agrupados por archivo para facilitar la edición.
- Los duplicados se marcan y explican.
- Los keybindings contextuales se destacan indicando el contexto de activación.
- Todo está documentado en español.
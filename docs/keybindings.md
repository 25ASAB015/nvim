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

### [lua/plugins/ui/which-key.lua](lua/plugins/ui/which-key.lua)

## Leader Bindings (Normal Mode)

> Leader == <kbd>Space</kbd>

### a -  AI

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |

### c -  Code

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |

### e -  Edit

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |
| <kbd>Leader</kbd> <kbd> e a </kbd> | Alternate File |
| <kbd>Leader</kbd> <kbd> e c a </kbd> | Shell Aliases |
| <kbd>Leader</kbd> <kbd> e c A </kbd> | Alacritty Config |
| <kbd>Leader</kbd> <kbd> e c b </kbd> | Bash Config |
| <kbd>Leader</kbd> <kbd> e c e </kbd> | Environment Config |
| <kbd>Leader</kbd> <kbd> e c f </kbd> | Shell Functions |
| <kbd>Leader</kbd> <kbd> e c g </kbd> | Git Config |
| <kbd>Leader</kbd> <kbd> e c k </kbd> | Kitty Config |
| <kbd>Leader</kbd> <kbd> e c l </kbd> | Local Env |
| <kbd>Leader</kbd> <kbd> e c n </kbd> | Neovim Init |
| <kbd>Leader</kbd> <kbd> e c p </kbd> | Plugin List |
| <kbd>Leader</kbd> <kbd> e c q </kbd> | Qutebrowser Config |
| <kbd>Leader</kbd> <kbd> e c t </kbd> | Tmux Config |
| <kbd>Leader</kbd> <kbd> e c v </kbd> | Vim Config |
| <kbd>Leader</kbd> <kbd> e c z </kbd> | Zsh Config |
| <kbd>Leader</kbd> <kbd> e c Z </kbd> | Zsh Prompt Config |
| <kbd>Leader</kbd> <kbd> e E </kbd> | File Explorer |
| <kbd>Leader</kbd> <kbd> e f </kbd> | File Under Cursor |
| <kbd>Leader</kbd> <kbd> e m </kbd> | Readme |
| <kbd>Leader</kbd> <kbd> e n </kbd> | New File |
| <kbd>Leader</kbd> <kbd> e t </kbd> | Explore Tree |

### f -  Find

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |
| <kbd>Leader</kbd> <kbd> f 1..9 </kbd> | Numerical mappings |

### g -  Git

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |
| <kbd>Leader</kbd> <kbd> g C </kbd> | Co-Authors |

### i -  Insert

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |

### j -  Jump

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |

### l -  LSP

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |

### m -  Marks

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |

### n -  Notes

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |

### o -  Options

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |

### p -  Packages

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |

### q -  Quit

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |
| <kbd>Leader</kbd> <kbd> q a </kbd> | Quit All |
| <kbd>Leader</kbd> <kbd> q b </kbd> | Close Buffer |
| <kbd>Leader</kbd> <kbd> q d </kbd> | Delete Buffer |
| <kbd>Leader</kbd> <kbd> q f </kbd> | Force Quit |
| <kbd>Leader</kbd> <kbd> q o </kbd> | Close Others |
| <kbd>Leader</kbd> <kbd> q q </kbd> | Quit |
| <kbd>Leader</kbd> <kbd> q s </kbd> | Close Split |
| <kbd>Leader</kbd> <kbd> q w </kbd> | Write and Quit |

### r -  Refactor

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |

### s -  Split

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |

### t -  Terminal

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |
| <kbd>Leader</kbd> <kbd> t ` </kbd> | Horizontal Terminal |
| <kbd>Leader</kbd> <kbd> t c </kbd> | Rails Console |
| <kbd>Leader</kbd> <kbd> t d </kbd> | Exe Launcher |
| <kbd>Leader</kbd> <kbd> t n </kbd> | Node |
| <kbd>Leader</kbd> <kbd> t p </kbd> | Python |
| <kbd>Leader</kbd> <kbd> t r </kbd> | Ruby |
| <kbd>Leader</kbd> <kbd> t s </kbd> | Horizontal Terminal |
| <kbd>Leader</kbd> <kbd> t t </kbd> | Terminal |
| <kbd>Leader</kbd> <kbd> t v </kbd> | Vertical Terminal |
| <kbd>Leader</kbd> <kbd> t w </kbd> | Exe Launcher, Wait |

### w -  Writing

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |

### y -  Yank

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |
| <kbd>Leader</kbd> <kbd> y a </kbd> | Copy Whole File |
| <kbd>Leader</kbd> <kbd> y f </kbd> | File Name |
| <kbd>Leader</kbd> <kbd> y g </kbd> | Copy Git URL |
| <kbd>Leader</kbd> <kbd> y L </kbd> | Absolute Path with Line |
| <kbd>Leader</kbd> <kbd> y l </kbd> | Relative Path with Line |
| <kbd>Leader</kbd> <kbd> y P </kbd> | Absolute Path |
| <kbd>Leader</kbd> <kbd> y p </kbd> | Relative Path |

## Leader Bindings (Visual Mode)

### a -  AI

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |

### c -  Code

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |

### g -  Git

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |

### j -  Jump

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |

### l -  LSP

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |

### y -  Yank

| Keybinding                         | Action         |
| ---------------------------------- | -------------- |
| <kbd>Leader</kbd> <kbd> y g </kbd> | Copy Git URL |


---

### [lua/plugins/tools/exercism.lua](lua/plugins/tools/exercism.lua)

#### Archivos/Proyecto

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><leader>exr</kbd>                | Recent Exercises                                    | [N]             | Exercism defaults (auto)            |

#### Atajos con <leader>

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><leader>exa</kbd>                | All Exercism Languages                              | [N]             | Exercism defaults (auto)            |
| <kbd><leader>exl</kbd>                | List Default Language Exercises                     | [N]             | Exercism defaults (auto)            |
| <kbd><leader>exs</kbd>                | Submit Exercise                                     | [N]             | Exercism defaults (auto)            |
| <kbd><leader>ext</kbd>                | Test Exercise                                       | [N]             | Exercism defaults (auto)            |


---

### [lua/plugins/tools/nerdy.lua](lua/plugins/tools/nerdy.lua)

#### Archivos/Proyecto

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><leader>iN</kbd>                 | Nerdy: Recent Icons                                 | [N]             | Nerdy defaults (auto)               |

#### Atajos con <leader>

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><leader>in</kbd>                 | Nerdy: List Icons                                   | [N]             | Nerdy defaults (auto)               |


---

### [lua/plugins/tools/octohub.lua](lua/plugins/tools/octohub.lua)

#### Git

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><leader>gop</kbd>                | Open GitHub Profile                                 | [N]             | Defaults (auto)                     |
| <kbd><leader>goU</kbd>                | Repos by Pushed                                     | [N]             | Defaults (auto)                     |

#### Atajos con <leader>

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><leader>goA</kbd>                | Archived Repos                                      | [N]             | Defaults (auto)                     |
| <kbd><leader>goa</kbd>                | Activity Stats                                      | [N]             | Defaults (auto)                     |
| <kbd><leader>gob</kbd>                | Repos by Size                                       | [N]             | Defaults (auto)                     |
| <kbd><leader>goc</kbd>                | Repos by Created                                    | [N]             | Defaults (auto)                     |
| <kbd><leader>gof</kbd>                | Repos by Forks                                      | [N]             | Defaults (auto)                     |
| <kbd><leader>goF</kbd>                | Forked Repos                                        | [N]             | Defaults (auto)                     |
| <kbd><leader>gog</kbd>                | Contribution Graph                                  | [N]             | Defaults (auto)                     |
| <kbd><leader>goi</kbd>                | Repos by Issues                                     | [N]             | Defaults (auto)                     |
| <kbd><leader>gol</kbd>                | Repos by Language                                   | [N]             | Defaults (auto)                     |
| <kbd><leader>goL</kbd>                | Filter by Language                                  | [N]             | Defaults (auto)                     |
| <kbd><leader>goo</kbd>                | All Repos                                           | [N]             | Defaults (auto)                     |
| <kbd><leader>goP</kbd>                | Private Repos                                       | [N]             | Defaults (auto)                     |
| <kbd><leader>gor</kbd>                | Repo Stats                                          | [N]             | Defaults (auto)                     |
| <kbd><leader>gos</kbd>                | Repos by Stars                                      | [N]             | Defaults (auto)                     |
| <kbd><leader>goS</kbd>                | Starred Repos                                       | [N]             | Defaults (auto)                     |
| <kbd><leader>goT</kbd>                | Template Repos                                      | [N]             | Defaults (auto)                     |
| <kbd><leader>got</kbd>                | All Stats                                           | [N]             | Defaults (auto)                     |
| <kbd><leader>gou</kbd>                | Repos by Updated                                    | [N]             | Defaults (auto)                     |
| <kbd><leader>gow</kbd>                | Open Repo in Browser                                | [N]             | Defaults (auto)                     |


---

### [lua/plugins/tools/pickme.lua](lua/plugins/tools/pickme.lua)

#### Navegación

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><leader>ecc</kbd>                | Neovim Configs                                      | [N]             | PickMe defaults (auto)              |
| <kbd><leader>ecL</kbd>                | Neovim Logs                                         | [N]             | PickMe defaults (auto)              |
| <kbd><leader>ecP</kbd>                | Neovim Plugins                                      | [N]             | PickMe defaults (auto)              |
| <kbd><leader>ed</kbd>                 | Directorios en $HOME -> abrir nueva instancia de Neovim en el directorio seleccionado | [N]             |                                     |
| <kbd><leader>fa</kbd>                 | Find Files                                          | [N]             | PickMe defaults (auto)              |
| <kbd><leader>fd</kbd>                 | Project Dirs                                        | [N]             | PickMe defaults (auto)              |
| <kbd><leader>ff</kbd>                 | Find Git Files                                      | [N]             | PickMe defaults (auto)              |
| <kbd><leader>ld</kbd>                 | LSP Definitions                                     | [N]             | PickMe defaults (auto)              |
| <kbd><leader>lt</kbd>                 | Type Definitions                                    | [N]             | PickMe defaults (auto)              |
| <kbd><leader>oj</kbd>                 | Jump List                                           | [N]             | PickMe defaults (auto)              |
| <kbd><leader>ot</kbd>                 | Treesitter Find                                     | [N]             | PickMe defaults (auto)              |

#### Búsqueda

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><leader>/</kbd>                  | Search History                                      | [N]             | PickMe defaults (auto)              |
| <kbd><leader>eh</kbd>                 | Personalizado: buscar archivos en cualquier parte de $HOME por nombre | [N]             |                                     |
| <kbd><leader>ol</kbd>                 | Search for Plugin Spec                              | [N]             | PickMe defaults (auto)              |
| <kbd><leader>os</kbd>                 | Search History                                      | [N]             | PickMe defaults (auto)              |

#### Ventanas/Buffers/Tabs

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><leader>,</kbd>                  | Buffers                                             | [N]             | PickMe defaults (auto)              |
| <kbd><leader>fb</kbd>                 | Buffers                                             | [N]             | PickMe defaults (auto)              |
| <kbd><leader>fo</kbd>                 | Grep Open Buffers                                   | [N]             | PickMe defaults (auto)              |
| <kbd><leader>fs</kbd>                 | Buffer Lines                                        | [N]             | PickMe defaults (auto)              |
| <kbd><leader>ll</kbd>                 | Buffer Diagnostics                                  | [N]             | PickMe defaults (auto)              |

#### Archivos/Proyecto

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><Ctrl-f></kbd>                   | Files                                               | [N]             | PickMe defaults (auto)              |
| <kbd><leader><space></kbd>            | Files                                               | [N]             | PickMe defaults (auto)              |
| <kbd><leader>fm</kbd>                 | Modified Files                                      | [N]             | PickMe defaults (auto)              |
| <kbd><leader>fr</kbd>                 | Recent Files                                        | [N]             | PickMe defaults (auto)              |

#### Git

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><leader>fc</kbd>                 | File Commits                                        | [N]             | PickMe defaults (auto)              |
| <kbd><leader>gc</kbd>                 | Git Commits                                         | [N]             | PickMe defaults (auto)              |
| <kbd><leader>gL</kbd>                 | Git Log                                             | [N]             | PickMe defaults (auto)              |
| <kbd><leader>gl</kbd>                 | Git Log Line                                        | [N]             | PickMe defaults (auto)              |
| <kbd><leader>gS</kbd>                 | Git Stash                                           | [N]             | PickMe defaults (auto)              |
| <kbd><leader>gs</kbd>                 | Git Branches                                        | [N]             | PickMe defaults (auto)              |

#### LSP/Diagnóstico

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><leader>lD</kbd>                 | LSP Declarations                                    | [N]             | PickMe defaults (auto)              |
| <kbd><leader>lF</kbd>                 | References                                          | [N]             | PickMe defaults (auto)              |
| <kbd><leader>li</kbd>                 | LSP Implementations                                 | [N]             | PickMe defaults (auto)              |
| <kbd><leader>lL</kbd>                 | Diagnostics                                         | [N]             | PickMe defaults (auto)              |
| <kbd><leader>lS</kbd>                 | Workspace Symbols                                   | [N]             | PickMe defaults (auto)              |
| <kbd><leader>ls</kbd>                 | Document Symbols                                    | [N]             | PickMe defaults (auto)              |

#### UI/Tema

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><leader>fq</kbd>                 | Quickfix List                                       | [N]             | PickMe defaults (auto)              |
| <kbd><leader>oC</kbd>                 | Colorschemes                                        | [N]             | PickMe defaults (auto)              |

#### Atajos con <leader>

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><leader>:</kbd>                  | Command History                                     | [N]             | PickMe defaults (auto)              |
| <kbd><leader>fg</kbd>                 | Grep                                                | [N]             | PickMe defaults (auto)              |
| <kbd><leader>fl</kbd>                 | Location List                                       | [N]             | PickMe defaults (auto)              |
| <kbd><leader>fp</kbd>                 | Previous Picker                                     | [N]             | PickMe defaults (auto)              |
| <kbd><leader>ft</kbd>                 | All Pickers                                         | [N]             | PickMe defaults (auto)              |
| <kbd><leader>fu</kbd>                 | Undo History                                        | [N]             | PickMe defaults (auto)              |
| <kbd><leader>fw</kbd>                 | Word Grep                                           | [N]             | PickMe defaults (auto)              |
| <kbd><leader>fz</kbd>                 | Zoxide                                              | [N]             | PickMe defaults (auto)              |
| <kbd><leader>ii</kbd>                 | Icons                                               | [N]             | PickMe defaults (auto)              |
| <kbd><leader>ir</kbd>                 | Registers                                           | [N]             | PickMe defaults (auto)              |
| <kbd><leader>is</kbd>                 | Spell Suggestions                                   | [N]             | PickMe defaults (auto)              |
| <kbd><leader>iv</kbd>                 | Clipboard                                           | [N]             | PickMe defaults (auto)              |
| <kbd><leader>oa</kbd>                 | Autocmds                                            | [N]             | PickMe defaults (auto)              |
| <kbd><leader>oc</kbd>                 | Command History                                     | [N]             | PickMe defaults (auto)              |
| <kbd><leader>od</kbd>                 | Docs                                                | [N]             | PickMe defaults (auto)              |
| <kbd><leader>of</kbd>                 | Marks                                               | [N]             | PickMe defaults (auto)              |
| <kbd><leader>og</kbd>                 | Commands                                            | [N]             | PickMe defaults (auto)              |
| <kbd><leader>oh</kbd>                 | Highlights                                          | [N]             | PickMe defaults (auto)              |
| <kbd><leader>ok</kbd>                 | Keymaps                                             | [N]             | PickMe defaults (auto)              |
| <kbd><leader>om</kbd>                 | Man Pages                                           | [N]             | PickMe defaults (auto)              |
| <kbd><leader>on</kbd>                 | Notifications                                       | [N]             | PickMe defaults (auto)              |
| <kbd><leader>oo</kbd>                 | Options                                             | [N]             | PickMe defaults (auto)              |


---

### [lua/plugins/tools/tdo.lua](lua/plugins/tools/tdo.lua)

#### Navegación

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><leader>ng</kbd>                 | Find Notes                                          | [N]             | Defaults (auto)                     |

#### Archivos/Proyecto

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><leader>nf</kbd>                 | All Notes                                           | [N]             | Defaults (auto)                     |

#### UI/Tema

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><leader>nx</kbd>                 | Toggle Todo                                         | [N]             | Defaults (auto)                     |

#### Atajos con <leader>

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><leader>nc</kbd>                 | Create Note                                         | [N]             | Defaults (auto)                     |
| <kbd><leader>nt</kbd>                 | Incomplete Todos                                    | [N]             | Defaults (auto)                     |

#### Otros

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd>README.md</kbd>                  | todos.sh                                            | [N]             | Defaults (auto)                     |


---

### [lua/plugins/ui/gitsigns.lua](lua/plugins/ui/gitsigns.lua)

#### Búsqueda

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Notas/Duplicados                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd>[e</kbd>                         | Navegación: hunk anterior                           | [N]             |                                     |
| <kbd>]e</kbd>                         | Navegación: siguiente hunk                          | [N]             |                                     |

#### Selección

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Notas/Duplicados                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd>ih</kbd>                         | Objeto de texto para seleccionar un hunk            | [V] [O]         |                                     |


---

### [lua/plugins/ui/onedark.lua](lua/plugins/ui/onedark.lua)

#### UI/Tema

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Notas/Duplicados                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><leader>ot</kbd>                 | Tecla para alternar entre los diferentes estilos del tema | [N]             |                                     |


---

### [lua/plugins/ui/snacks.lua](lua/plugins/ui/snacks.lua)

#### Navegación

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd>[a</kbd>                         | jump to top edge of scope                           | [N]             | Snacks keys                         |
| <kbd>]a</kbd>                         | jump to bottom edge of scope                        | [N]             | Snacks keys                         |

#### Ventanas/Buffers/Tabs

| Combinación de teclas                 | Acción (Español)                                    | Modo(s)         | Contexto/Notas                   |
| ------------------------------------- | --------------------------------------------------- | --------------- | ----------------------------------- |
| <kbd><cr></kbd>                       | Execute buffer                                      | [N] [V]         | Snacks keys                         |
| <kbd><leader>cr</kbd>                 | Source buffer                                       | [N] [V]         | Snacks keys                         |


---

## Conflictos y solapamientos

- Tecla <kbd><leader>ot</kbd>:
  - [N]: 
    - Treesitter Find — [lua/plugins/tools/pickme.lua:L246](lua/plugins/tools/pickme.lua#L246)
    - Tecla para alternar entre los diferentes estilos del tema — [lua/plugins/ui/onedark.lua:L37](lua/plugins/ui/onedark.lua#L37)
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

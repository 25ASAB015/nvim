-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ keys.lua: Mapeo y Personalización de Atajos de Teclado en Neovim     ║
-- ║ Este archivo es invocado desde 'init.lua'                            ║
-- ║                                                                      ║
-- ║ Define y documenta combinaciones de teclas (keymaps) para todos      ║
-- ║ los modos de Neovim, optimizando edición, navegación y manipulación  ║
-- ║ de texto en flujos de trabajo modernos de desarrollo web.            ║
-- ║ Incluye escapes rápidos, manipulación visual sin contaminar          ║
-- ║ registros, navegación eficiente entre líneas, centrado automático    ║
-- ║ de cursor tras búsquedas y movimientos, y atajos para bloques.       ║
-- ║                                                                      ║
-- ╚══════════════════════════════════════════════════════════════════════╝

-- Función utilitaria para definir mapeos de teclas con opciones sensatas por defecto.
local function map(mode, lhs, rhs, opts)  
  opts = opts or {}
  opts.silent = opts.silent ~= false
  vim.keymap.set(mode, lhs, rhs, opts)
end

local opts = { noremap = true, silent = true }

-- Asigna la barra espaciadora como tecla líder global y local.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- MODOS
-- normal_mode = "n", insert_mode = "i", visual_mode = "v",
-- visual_block_mode = "x", term_mode = "t", command_mode = "c",

-- Salir de Insert/Terminal escribiendo rápido 'jj' o 'JJ'
map('i', 'jj', '<Esc>', opts)        -- Rápido escape en Insert Mode
map('t', 'JJ', '<C-\\><C-n>', opts)  -- Escape en Terminal Mode

-- Pegar sobre texto visual seleccionado sin sobreescribir el registro ("paste sin perder el clipboard")
map({ 'v', 'x' }, 'p', '"_dP', opts)

-- Eliminar texto en visual sin copiar al registro principal
map({ 'v', 'x' }, 'x', '"_x', opts)

-- Eliminar línea/carácteres en normal y visual block sin copiar
map('n', 'X', '"_D', opts)               -- Eliminar hasta el final, sin copiar
map({ 'v', 'x' }, 'X', '"_d', opts)      -- Eliminar selección, sin copiar

-- Incrementar y decrementar números/valores rápido (implementa tu lógica en los rhs)
map({ 'n', 'v', 'x' }, '-', '<Nop>', opts) -- Placeholder para decremento
map({ 'n', 'v', 'x' }, '=', '<Nop>', opts) -- Placeholder para incremento

-- Salto rápido a inicio/fin de línea
map({ 'n', 'v', 'x' }, 'gl', '$', { desc = 'Fin de línea' })
map({ 'n', 'v', 'x' }, 'gh', '^', { desc = 'Inicio de línea' })

-- Mantener el cursor siempre centrado tras ciertas acciones
map('n', 'J', 'mzJ`z', opts)             -- Unir líneas y centrar cursor
map('n', '<C-d>', '<C-d>zz', opts)       -- Half-page down y centrar
map('n', '<C-u>', '<C-u>zz', opts)       -- Half-page up y centrar
map('n', 'n', 'nzzzv', opts)             -- Buscar siguiente y centrar
map('n', 'N', 'Nzzzv', opts)             -- Buscar anterior y centrar

-- Desplazamiento eficiente en líneas largas (visual)
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true }) -- Bajar línea real
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true }) -- Subir línea real

-- Mover bloques de texto seleccionados arriba y abajo en visual
map({ 'v', 'x' }, 'J', ":move '>+1<CR>gv-gv", opts)
map({ 'v', 'x' }, 'K', ":move '<-2<CR>gv-gv", opts)

-- Limpia el highlight de búsqueda y ajusta pantalla
map({ 'i', 'n' }, '<Esc>', '<Esc>:noh<CR>', { desc = 'Escape y limpia búsqueda' })

-- Mapeos consistentes n/N para buscar adelante/atrás según dirección corriente
map('n', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Siguiente resultado' })
map('x', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Siguiente resultado' })
map('o', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Siguiente resultado' })
map('n', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Anterior resultado' })
map('x', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Anterior resultado' })
map('o', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Anterior resultado' })

-- Indentado persistente en modo visual
map('v', '<', '<gv', opts)
map('v', '>', '>gv', opts)

-- Punto de interrupción de undo tras ciertos caracteres en insert
map('i', ',', ',<C-g>u', opts)
map('i', '.', '.<C-g>u', opts)
map('i', ';', ';<C-g>u', opts)

-- ╔═════════════════════════════════════════════════════╗
-- ║                                                     ║
-- ║              Roberto Flores - Nvim                  ║
-- ║                                                     ║
-- ╚═════════════════════════════════════════════════════╝
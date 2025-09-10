-- ╔════════════════════════════════════════════════════════════════════════════════════╗
-- ║ autocmd.lua: Definición centralizada de autocomandos (autocmds) para Neovim      ║
-- ║ Este archivo es invocado desde 'init.lua'                                        ║
-- ║                                                                                  ║
-- ║ Aquí se configuran y documentan los autocomandos principales de Neovim,          ║
-- ║ permitiendo automatizar comportamientos según eventos como abrir, guardar o      ║
-- ║ cambiar el tipo de archivo. Estos autocomandos mejoran la experiencia de         ║
-- ║ edición y facilitan tareas repetitivas, integración con herramientas modernas,   ║
-- ║ y adaptación a flujos de trabajo productivos para desarrollo web y general.      ║
-- ║                                                                                  ║
-- ║ Modifica este archivo para ajustar o añadir comportamientos automáticos según    ║
-- ║ tus necesidades y preferencias personales.                                       ║
-- ╚════════════════════════════════════════════════════════════════════════════════════╝

-- Helper: Crea grupos únicos de autocmd para facilitar su gestión y limpieza
local function augroup(name)
    return vim.api.nvim_create_augroup('nvim2k_' .. name, { clear = true })
end

-- Autocomando: Elimina espacios en blanco al final de las líneas antes de guardar cualquier archivo
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    group = augroup('strip_space'),
    pattern = { '*' },
    callback = function()
        vim.cmd([[ %s/\s\+$//e ]])
    end,
})
-- Autocomando: Verifica si necesita recargar el archivo cuando ha cambiado externamente
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
    group = augroup('checktime'),
    command = 'checktime',
})

-- Autocomando: Resalta el texto copiado (yank) temporalmente para feedback visual
vim.api.nvim_create_autocmd('TextYankPost', {
    group = augroup('highlight_yank'),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Autocomando: Reajusta el tamaño de los splits cuando la ventana principal cambia de tamaño
vim.api.nvim_create_autocmd({ 'VimResized' }, {
    group = augroup('resize_splits'),
    callback = function()
        vim.cmd('tabdo wincmd =')
    end,
})

-- Autocomando: Va a la última ubicación del cursor al abrir un buffer
vim.api.nvim_create_autocmd('BufReadPost', {
    group = augroup('last_loc'),
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd('FileType', {
    group = augroup('close_with_q'),
    pattern = {
        'Jaq',
        'PlenaryTestPopup',
        'Avante',
        'AvanteInput',
        'AvanteSelectedFiles',
        'fugitive',
        'git',
        'help',
        'lir',
        'lspinfo',
        'man',
        'netrw',
        'notify',
        'qf',
        'spectre_panel',
        'startuptime',
        'tsplayground',
    },
    callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
    end,
})

-- Autocomando: Activa el ajuste de línea (wrap) y corrector ortográfico (spell) 
-- en archivos de texto como gitcommit y markdown
vim.api.nvim_create_autocmd('FileType', {
    group = augroup('wrap_spell'),
    pattern = { 'gitcommit', 'markdown' },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
    end,
})

-- Autocomando: Crea automáticamente los directorios necesarios antes de guardar un archivo
-- si algún directorio intermedio no existe
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    group = augroup('auto_create_dir'),
    callback = function(event)
        local file = vim.loop.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
    end,
})


-- Autocomando: Asigna automáticamente el filetype 'arb' a archivos con extensión .arb
vim.api.nvim_create_autocmd({ 'BufEnter' }, {
    group = augroup('set_file_type'),
    pattern = { '*.arb' },
    command = require('lib.util').get_file_type_cmd('arb'),
})

-- Autocomando: Desactiva ciertas opciones de formateo para evitar 
-- la inserción automática de comentarios e indentaciones no deseadas
vim.api.nvim_create_autocmd('FileType', {
    group = augroup('disable_formatoptions'),
    pattern = '*',
    callback = function()
        vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' })
    end,
})

-- Función auxiliar: Habilita el formateo automático usando LSP antes de guardar
local function enable_autoformat()
    vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
        group = augroup('autoformat'),
        pattern = { '*' },
        callback = function()
            vim.lsp.buf.format()
        end,
    })
end

enable_autoformat()

-- Comando personalizado: Permite guardar un archivo sin aplicar el formateo automático
vim.api.nvim_create_user_command('WriteNoFormat', function()
    -- Temporarily disable the autoformat autocmd
    vim.api.nvim_del_augroup_by_name('nvim2k_autoformat')
    vim.cmd('write')
    -- Re-enable the autoformat autocmd
    enable_autoformat()
end, {})

-- ╔═════════════════════════════════════════════════════╗
-- ║                                                     ║
-- ║              Roberto Flores - Nvim                  ║
-- ║                                                     ║
-- ╚═════════════════════════════════════════════════════╝

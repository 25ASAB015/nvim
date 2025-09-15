-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ gitsigns.lua: Configuración de indicadores Git para Neovim          ║
-- ║ Este archivo es invocado desde 'init.lua'                            ║
-- ║                                                                      ║
-- ║ Muestra signos en el margen para cambios (add/change/delete),        ║
-- ║ navegación entre hunks, preview de cambios y blame en línea.         ║
-- ║ Optimiza la visibilidad y el flujo de trabajo con Git dentro de Nvim.║
-- ║                                                                      ║
-- ╚══════════════════════════════════════════════════════════════════════╝

local gitsigns = require('gitsigns')
local icons = require('lib.icons')

-- Configuración principal del plugin Gitsigns
gitsigns.setup({
    -- Signos mostrados en la columna de signos para cada tipo de cambio
    signs = {
        add = { text = icons.ui.SeparatorLight },
        change = { text = icons.ui.SeparatorLight },
        delete = { text = icons.ui.SeparatorLight },
        topdelete = { text = icons.ui.Topline },
        changedelete = { text = icons.ui.SeparatorLight },
        untracked = { text = icons.ui.SeparatorDashed },
    },
    -- Opciones de visualización y rendimiento
    signcolumn = true,
    numhl = false,
    linehl = false,
    word_diff = false,
    watch_gitdir = { interval = 1000, follow_files = true },
    attach_to_untracked = true,
    current_line_blame = false,
    -- Configuración del blame en la línea actual
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',
        delay = 0,
        ignore_whitespace = false,
    },
    current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil,
    max_file_length = 40000,
    -- Configuración de la ventana de preview de hunks
    preview_config = { border = 'rounded', style = 'minimal', relative = 'cursor', row = 0, col = 1 },
    -- Mapeos buffer-local al adjuntarse el plugin
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        -- Helper para mapear teclas con alcance al buffer
        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navegación: siguiente hunk
        map('n', ']e', function()
            if vim.wo.diff then
                return ']e'
            end
            vim.schedule(function()
                gs.next_hunk()
            end)
            return '<Ignore>'
        end, { expr = true, desc = 'Next Change' })

        -- Navegación: hunk anterior
        map('n', '[e', function()
            if vim.wo.diff then
                return '[e'
            end
            vim.schedule(function()
                gs.prev_hunk()
            end)
            return '<Ignore>'
        end, { expr = true, desc = 'Prev Change' })

        -- Objeto de texto para seleccionar un hunk
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<cr>')
    end,
})

-- ╔═════════════════════════════════════════════════════╗
-- ║                                                     ║
-- ║              Roberto Flores - Nvim                  ║
-- ║                                                     ║
-- ╚═════════════════════════════════════════════════════╝

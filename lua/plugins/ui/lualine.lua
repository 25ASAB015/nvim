-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ lualine.lua: Configuración central de la barra de estado lualine     ║
-- ║ Este archivo es invocado desde 'init.lua'                            ║
-- ║                                                                      ║
-- ║ Define y documenta la configuración de la barra de estado lualine,   ║
-- ║ permitiendo personalizar el aspecto, componentes y comportamiento de ║
-- ║ la barra de estado en Neovim.                                        ║
-- ║                                                                      ║
-- ╚══════════════════════════════════════════════════════════════════════╝

local lualine = require('lualine')
local icons = require('lib.icons')

-- Paleta de colores base para lualine (ajusta estética global)
local colors = {
    bg = '#000000',
    fg = '#bbc2cf',
    yellow = '#ECBE7B',
    cyan = '#008080',
    darkblue = '#081633',
    green = '#98be65',
    orange = '#FF8800',
    violet = '#a9a1e1',
    magenta = '#c678dd',
    blue = '#51afef',
    red = '#ec5f67',
}

-- Mapa de color por modo de Neovim (colorea el icono del modo)
local mode_color = {
    n = colors.green,
    i = colors.blue,
    v = colors.magenta,
    [''] = colors.magenta,
    V = colors.magenta,
    c = colors.yellow,
    t = colors.red,
    R = colors.orange,
    Rv = colors.orange,
    no = colors.fg,
    s = colors.violet,
    S = colors.violet,
    [''] = colors.violet,
    ic = colors.yellow,
    cv = colors.red,
    ce = colors.red,
    r = colors.cyan,
    rm = colors.cyan,
    ['r?'] = colors.cyan,
    ['!'] = colors.red,
}

-- Condiciones reutilizables para mostrar/ocultar componentes según contexto
local conditions = {
    buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
    end,
    buffer_is_file = function()
        return vim.bo.buftype == ''
    end,
    buffer_not_scratch = function()
        return string.find(vim.fn.bufname(), 'SCRATCH') == nil
    end,
    hide_in_width = function()
        return vim.fn.winwidth(0) > 80
    end,
    check_git_workspace = function()
        local filepath = vim.fn.expand('%:p:h')
        local gitdir = vim.fn.finddir('.git', filepath .. ';')
        return gitdir and #gitdir > 0 and #gitdir < #filepath
    end,
    is_note = function()
        local notes_dir = vim.env.NOTES_DIR
        if not notes_dir then
            return false
        end
        local current_file = vim.fn.expand('%:p')
        return current_file:find(vim.fn.expand(notes_dir), 1, true) == 1
    end,
}

-- Componentes básicos con estilo consistente
-- Conteo de resultados de búsqueda actuales
local searchcount = { 'searchcount', color = { fg = colors.fg, gui = 'bold' } }
-- Conteo de selección visual
local selectioncount = { 'selectioncount', color = { fg = colors.fg, gui = 'bold' } }
-- Progreso dentro del archivo actual
local progress = { 'progress', color = { fg = colors.fg, gui = 'bold' } }
-- Tipo de archivo del buffer actual
local filetype = { 'filetype', color = { fg = colors.blue, gui = 'bold' } }
-- Tamaño del archivo (si el buffer no está vacío)
local filesize = { 'filesize', color = { fg = colors.fg, gui = 'bold' }, cond = conditions.buffer_not_empty }
-- Formato de archivo (unix/dos/mac) con iconos
local fileformat = { 'fileformat', icons_enabled = true, color = { fg = colors.white, gui = 'bold' } }

-- Nombre del archivo (oculta buffers vacíos o especiales)
local filename = {
    'filename',
    cond = conditions.buffer_not_empty and conditions.buffer_is_file and conditions.buffer_not_scratch,
    color = { fg = colors.magenta, gui = 'bold' },
}

-- Lista de buffers en la tabline con alias por tipo de archivo
local buffers = {
    'buffers',
    mode = 2,
    cond = conditions.buffer_not_scratch,
    filetype_names = {
        NvimTree = icons.documents.OpenFolder .. 'Files',
        TelescopePrompt = icons.ui.Telescope .. 'Telescope',
        Avante = icons.ui.Copilot .. 'Avante',
        AvanteInput = icons.ui.Pencil .. 'Avante',
        AvanteSelectedFiles = icons.documents.File .. 'Avante',
        dashboard = icons.ui.Dashboard .. 'Dashboard',
        lazy = icons.ui.Sleep .. 'Lazy',
        mason = icons.ui.Package .. 'Mason',
        minifiles = icons.documents.OpenFolder .. 'Files',
        snacks_picker_input = icons.ui.Telescope .. 'Picker',
        spectre_panel = icons.ui.Search .. 'Spectre',
    },
    use_mode_colors = true,
}

-- Rama Git actual, truncada para ahorrar espacio
local branch = {
    'branch',
    icon = icons.git.Branch,
    fmt = function(str)
        return str:sub(1, 32)
    end,
    color = { fg = colors.green, gui = 'bold' },
}

-- Indicadores de cambios Git (añadidos/modificados/eliminados)
local diff_icons = {
    'diff',
    symbols = { added = icons.git.AddAlt, modified = icons.git.DiffAlt, removed = icons.git.RemoveAlt },
    diff_color = {
        added = { fg = colors.green },
        modified = { fg = colors.orange },
        removed = { fg = colors.red },
    },
    cond = conditions.hide_in_width,
}

-- Resumen de diagnósticos del LSP y de Neovim
local diagnostics = {
    'diagnostics',
    sources = { 'nvim_lsp', 'nvim_diagnostic', 'nvim_workspace_diagnostic' },
    symbols = {
        error = icons.diagnostics.Error,
        warn = icons.diagnostics.Warning,
        info = icons.diagnostics.Information,
        hint = icons.diagnostics.Hint,
    },
    diagnostics_color = {
        color_error = { fg = colors.red },
        color_warn = { fg = colors.yellow },
        color_info = { fg = colors.blue },
        color_hint = { fg = colors.yellow },
    },
}

-- Cliente LSP activo para el tipo de archivo actual
local lsp = {
    function()
        local msg = 'No LSP'
        local buf_ft = vim.api.nvim_get_option_value('filetype', { buf = 0 })
        local clients = vim.lsp.get_clients()
        if next(clients) == nil then
            return msg
        end
        for _, client in ipairs(clients) do
            local filetypes = client.config and client.config.filetypes or nil
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                return client.name
            end
        end
        return msg
    end,
    icon = icons.ui.Gear,
    color = { fg = colors.fg, gui = 'bold' },
}

-- Indicador de tareas desde 'tdo' (actualización diferida para evitar bloquear la UI)
local tdo = {
    function()
        local update_frequency = 300
        if not vim.g.tdo_last_update or (os.time() - vim.g.tdo_last_update) > update_frequency then
            vim.g.tdo_last_update = os.time()
            local result = vim.fn.system('tdo pending')
            vim.g.tdo_count = tonumber(result:match('%d+')) or 0
        end
        return vim.g.tdo_count or 0
    end,
    icon = icons.ui.Check,
    color = { fg = '#8BCD5B', gui = 'bold' },
    cond = conditions.is_note,
}

-- Codificación del buffer en mayúsculas (visible si hay ancho suficiente)
local encoding = {
    'o:encoding',
    fmt = string.upper,
    cond = conditions.hide_in_width,
    color = { fg = colors.green, gui = 'bold' },
}

-- Componente minimalista de modo: sólo un icono coloreado según el modo
local function mode(icon)
    icon = icon or icons.ui.Neovim
    return {
        function()
            return icon
        end,
        color = function()
            return { fg = mode_color[vim.fn.mode()] }
        end,
        padding = { left = 1, right = 0 },
    }
end

-- Ajuste del tema 'onedark' para un fondo de barra uniforme
local custom_onedark = require('lualine.themes.onedark')
custom_onedark.normal.c.bg = colors.bg

-- Configuración principal de lualine
lualine.setup({
    options = {
        component_separators = '',
        -- section_separators = '',
        theme = custom_onedark,
        disabled_filetypes = {
            'dashboard',
        },
    },
    -- extensions = { 'quickfix', 'man', 'mason', 'lazy', 'toggleterm', 'nvim-tree' },
    -- Configuración de la barra superior (tabline)
    tabline = {
        lualine_a = {},
        -- Izquierda: modo, tareas y buffers
        lualine_b = { mode(), tdo, buffers },
        lualine_c = {},
        -- Derecha: cambios y rama Git
        lualine_x = { diff_icons, branch },
        -- Contadores de búsqueda y selección
        lualine_y = { searchcount, selectioncount },
        lualine_z = {},
    },
    -- Secciones de la barra de estado por ventana
    sections = {
        lualine_a = {},
        lualine_b = {},
        -- Centro: modo (icono), ubicación del cursor, progreso y nombre de archivo
        lualine_c = { mode(icons.ui.Heart), 'location', progress, filename },
        -- Derecha: diagnósticos, LSP, tipo/tamaño/formato y codificación
        lualine_x = { diagnostics, lsp, filetype, filesize, fileformat, encoding },
        lualine_y = {},
        lualine_z = {},
    },
})


-- ╔═════════════════════════════════════════════════════╗
-- ║                                                     ║
-- ║              Roberto Flores - Nvim                  ║
-- ║                                                     ║
-- ╚═════════════════════════════════════════════════════╝
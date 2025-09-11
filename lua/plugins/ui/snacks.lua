
-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║ snacks.lua: Configuración de Snacks.nvim para UI moderna en Neovim         ║
-- ║ Este archivo es invocado desde 'plugins/list.lua'                          ║
-- ║                                                                            ║
-- ║ Este archivo define y documenta la configuración principal de Snacks.nvim, ║
-- ║ permitiendo personalizar layouts, atajos y la experiencia visual de        ║
-- ║ selección y paletas en Neovim. Aquí se establecen valores predeterminados  ║
-- ║ para aspectos como disposición de ventanas, bordes, títulos y estilos,     ║
-- ║ adaptando Snacks a un flujo de trabajo moderno y eficiente.                ║
-- ║                                                                            ║
-- ╚════════════════════════════════════════════════════════════════════════════╝

local Snacks = require('snacks')
local icons = require('lib.icons')

-- Dependencias locales
-- - `snacks`: plugin que provee UI moderna (pickers, notificaciones, layout, etc.)
-- - `icons`: tabla de íconos compartida usada para títulos, indicadores y estilos

-- Disposición tipo "archivos": lista a la izquierda + vista previa a la derecha
--
-- Parametros:
-- - preview_width: ancho relativo del panel de previsualización
-- - height/width: dimensiones relativas del popup en pantalla
--
local function files_layout(preview_width, height, width)
    preview_width = preview_width or 0.6
    height = height or 0.8
    width = width or 0.9
    return {
        layout = {
            box = 'horizontal',
            width = width,
            min_width = 120,
            height = height,
            {
                box = 'vertical',
                border = 'rounded',
                title = '{title} {live} {flags}',
                { win = 'input', height = 1, border = 'bottom' },
                { win = 'list', border = 'none' },
            },
            { win = 'preview', title = '{preview}', border = 'rounded', width = preview_width },
        },
    }
end

-- Disposición tipo "paleta": enfoque en entrada y lista, sin preview por defecto
--
-- Parametros:
-- - height/width: dimensiones relativas del popup para paletas/menús rápidos
--
local function palette_layout(height, width)
    height = height or 0.4
    width = width or 0.6
    return {
        preview = false,
        layout = {
            backdrop = false,
            row = 1,
            width = width,
            min_width = 80,
            height = height,
            border = 'rounded',
            box = 'vertical',
            {
                win = 'input',
                height = 1,
                border = 'rounded',
                title = '{title} {live} {flags}',
                title_pos = 'center',
            },
            { win = 'list', border = 'hpad' },
            { win = 'preview', title = '{preview}', border = 'rounded' },
        },
    }
end

-- Configuración principal de Snacks.nvim
--
-- Nota: siguiendo el estilo de `options.lua`, documentamos cada bloque
-- de configuración para facilitar su mantenimiento y ajuste.
Snacks.setup({
    -- Animaciones suaves para ventanas/paneles (apertura, cierre, resize)
    animate = {
        enabled = true,
        duration = 20, -- ms per step
        easing = 'linear',
        fps = 60,
    },
    -- Modo archivos grandes: desactiva características costosas según tamaño
    bigfile = {
        enabled = true,
        notify = true,
        size = 100 * 1024, -- 100 KB
    },
    -- Cierre de buffers sin romper ventanas
    bufdelete = { enabled = true },
    -- Pantalla de inicio con secciones útiles (teclas, recientes, proyectos)
    dashboard = {
        enabled = true,
        sections = {
            { section = 'header' },
            {
                icon = icons.ui.Keyboard,
                title = 'Keymaps',
                section = 'keys',
                indent = 2,
                padding = 1,
            },
            {
                icon = icons.documents.File,
                title = 'Recent Files',
                section = 'recent_files',
                indent = 2,
                padding = 1,
            },
            {
                icon = icons.documents.OpenFolder,
                title = 'Projects',
                section = 'projects',
                indent = 2,
                padding = 1,
            },
            { section = 'startup' },
        },
    },
    -- Utilidades de depuración de Snacks
    debug = { enabled = true },
    -- Atenúa el texto fuera del bloque/ámbito activo para mejorar el foco
    dim = {
        enabled = true,
        scope = {
            min_size = 5,
            max_size = 20,
            siblings = true,
        },
    },
    -- Explorador de archivos (deshabilitado: usamos otro plugin)
    explorer = { enabled = false },
    -- Integración con Git (signs, status, etc.)
    git = { enabled = true },
    -- Abrir URLs hacia el proveedor remoto (GitHub, etc.)
    gitbrowse = { enabled = true },
    -- Soporte para imágenes en la UI
    image = { enabled = true },
    -- Guías de indentación con colores en degradado
    indent = {
        enabled = true,
        priority = 1,
        char = icons.ui.SeparatorLight,
        only_scope = false,
        only_current = false,
        hl = {
            'SnacksIndent1',
            'SnacksIndent2',
            'SnacksIndent3',
            'SnacksIndent4',
            'SnacksIndent5',
            'SnacksIndent6',
            'SnacksIndent7',
            'SnacksIndent8',
        },
    },
    -- Entrada flotante con icono/título, usada por pickers y prompts
    input = {
        enabled = true,
        icon = icons.ui.Edit,
        icon_hl = 'SnacksInputIcon',
        icon_pos = 'left',
        prompt_pos = 'title',
        win = { style = 'input' },
        expand = true,
    },
    -- Administrador de diseños flotantes (backdrops, presets, etc.)
    layout = { enabled = true },
    -- Integración con LazyGit
    lazygit = { enabled = true },
    -- Centro de notificaciones compacto y ordenado por nivel/tiempo
    notifier = {
        enabled = true,
        timeout = 2000,
        width = { min = 40, max = 0.4 },
        height = { min = 1, max = 0.6 },
        margin = { top = 0, right = 1, bottom = 0 },
        padding = true,
        sort = { 'level', 'added' },
        level = vim.log.levels.TRACE,
        -- Mapea cada nivel a un icono visual consistente en toda la UI
        icons = {
            debug = icons.ui.Bug,
            error = icons.diagnostics.Error,
            info = icons.diagnostics.Information,
            trace = icons.ui.Bookmark,
            warn = icons.diagnostics.Warning,
        },
        style = 'compact',
        top_down = true,
        date_format = '%R',
        more_format = ' ↓ %d lines ',
        refresh = 50,
    },
    -- Reemplaza `vim.notify` con la versión de Snacks
    notify = { enabled = true },
    -- Picker universal: archivos, buffers, comandos, búsquedas, etc.
    picker = {
        enabled = true,
        icon = icons.ui.Search,
        icon_hl = 'SnacksPickerIcon',
        icon_pos = 'left',
        prompt_pos = 'title',
        win = { style = 'picker' },
        expand = true,
        -- Fuentes disponibles y su layout recomendado
        sources = {
            -- layout options: dropdown, horizontal, vertical, vscode, ivy, ivy_split, telescope, top, left, right, bottom, sidebar
            buffers = { layout = files_layout() },
            commands = { layout = palette_layout() },
            command_history = { layout = palette_layout() },
            files = {
                hidden = true,
                layout = files_layout(),
            },
            icons = {
                icon_sources = { 'nerd_fonts', 'emoji' },
                layout = palette_layout(),
            },
            git_files = { layout = files_layout() },
            git_branches = { layout = { preset = 'vertical' } },
            git_status = { layout = files_layout() },
            help = { layout = { preset = 'ivy_split' } },
            man = { layout = { preset = 'ivy_split' } },
            notifications = { layout = palette_layout() },
            projects = { layout = files_layout(0.8) },
            recent = { layout = files_layout() },
            search_history = { layout = palette_layout() },
            smart = { layout = files_layout() },
            undo = { layout = { preset = 'ivy' } },
            zoxide = { layout = files_layout(0.7) },
        },
    },
    -- Perfilador de rendimiento (útil para diagnosticar lentitud en UI)
    profiler = { enabled = true },
    -- Abre archivos pequeños/temporales rápidamente
    quickfile = { enabled = true },
    -- Renombrado mejorado con UI
    rename = { enabled = true },
    -- Delimitación de "scope" (bloques/ámbitos) y teclas asociadas
    scope = {
        enabled = true,
        keys = {
            -- Textobjects basados en alcance actual/completo
            textobject = {
                ii = {
                    min_size = 2, -- minimum size of the scope
                    edge = false, -- inner scope
                    cursor = false,
                    treesitter = { blocks = { enabled = false } },
                    desc = 'inner scope',
                },
                ai = {
                    cursor = false,
                    min_size = 2, -- minimum size of the scope
                    treesitter = { blocks = { enabled = false } },
                    desc = 'full scope',
                },
            },
            -- Saltos rápidos al borde superior/inferior del alcance
            jump = {
                ['[a'] = {
                    min_size = 1, -- allow single line scopes
                    bottom = false,
                    cursor = false,
                    edge = true,
                    treesitter = { blocks = { enabled = false } },
                    desc = 'jump to top edge of scope',
                },
                [']a'] = {
                    min_size = 1, -- allow single line scopes
                    bottom = true,
                    cursor = false,
                    edge = true,
                    treesitter = { blocks = { enabled = false } },
                    desc = 'jump to bottom edge of scope',
                },
            },
        },
    },
    -- Buffers de borrador persistentes con detección de filetype
    scratch = {
        enabled = true,
        name = 'SCRATCH',
        -- Deduce filetype del buffer actual o usa Markdown como fallback
        ft = function()
            if vim.bo.buftype == '' and vim.bo.filetype ~= '' then
                return vim.bo.filetype
            end
            return 'markdown'
        end,
        icon = nil,
        root = vim.fn.stdpath('data') .. '/scratch',
        autowrite = true,
        -- Clave del archivo para agrupar por cwd/rama/contador
        filekey = {
            cwd = true,
            branch = true,
            count = true,
        },
        win = {
            width = 120,
            height = 40,
            bo = { buftype = '', buflisted = false, bufhidden = 'hide', swapfile = false },
            minimal = false,
            noautocmd = false,
            zindex = 20,
            wo = { winhighlight = 'NormalFloat:Normal' },
            border = 'rounded',
            title_pos = 'center',
            footer_pos = 'center',

            -- Atajos dentro del scratch: ejecutar buffer con SnipRun
            keys = {
                ['execute'] = {
                    '<cr>',
                    function(_)
                        vim.cmd('%SnipRun')
                    end,
                    desc = 'Execute buffer',
                    mode = { 'n', 'x' },
                },
            },
        },
        -- Config específico por filetype (ej: Lua: "source" del buffer)
        win_by_ft = {
            lua = {
                keys = {
                    ['source'] = {
                        '<leader>cr',
                        function(self)
                            local name = 'scratch.' .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(self.buf), ':e')
                            Snacks.debug.run({ buf = self.buf, name = name })
                        end,
                        desc = 'Source buffer',
                        mode = { 'n', 'x' },
                    },
                },
            },
        },
    },
    -- Scroll mejorado (deshabilitado para evitar solaparse con otros plugins)
    scroll = { enabled = false },
    -- Columna de estado: signos, folds y git en un sólo carril
    statuscolumn = {
        enabled = true,
        left = { 'mark', 'sign' },
        right = { 'fold', 'git' },
        folds = {
            open = false,
            git_hl = false,
        },
        git = {
            patterns = { 'GitSign', 'MiniDiffSign' },
        },
        refresh = 50,
    },
    -- Terminal integrado (deshabilitado por preferencia)
    terminal = { enabled = false },
    -- Toggle de opciones rápidas (deshabilitado)
    toggle = { enabled = false },
    -- Utilidades generales para ventanas flotantes
    win = { enabled = true },
    -- Resaltado de palabras repetidas (deshabilitado)
    words = { enabled = false },
    -- Modo enfoque/zen para escribir/leer con mínima distracción
    zen = {
        enabled = true,
        toggles = {
            dim = true,
            git_signs = false,
            mini_diff_signs = false,
            -- diagnostics = false,
            -- inlay_hints = false,
        },
        show = {
            statusline = false,
            tabline = false,
        },
        win = { style = 'zen' },
        zoom = {
            toggles = {},
            show = { statusline = true, tabline = true },
            win = {
                backdrop = false,
                width = 0,
            },
        },
    },
})


-- ╔═════════════════════════════════════════════════════╗
-- ║                                                     ║
-- ║              Roberto Flores - Nvim                  ║
-- ║                                                     ║
-- ╚═════════════════════════════════════════════════════╝

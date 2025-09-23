-- ╔════════════════════════════════════════════════════════════════════════════╗
-- ║                                                                            ║
-- ║        📦 PLUGINS PRINCIPALES - CONFIGURACIÓN NVIM2K                       ║
-- ║                                                                            ║
-- ║  Archivo:    list.lua                                                      ║
-- ║  NOTA: Este archivo solo define la lista de plugins y su organización.     ║
-- ║       La configuración de Lazy.nvim y su inicialización se encuentra en    ║
-- ║       'plugins/lazy.lua'.                                                  ║
-- ║                                                                            ║
-- ║  Este archivo centraliza la declaración de plugins, agrupados por:         ║
-- ║    • UI: Temas, iconos y elementos visuales                                ║
-- ║    • Editor: Funciones de edición y manipulación de texto                  ║
-- ║    • Language: LSP, soporte de lenguajes y herramientas                    ║
-- ║    • AI: Integración con asistentes de IA (Copilot, Avante, etc.)          ║
-- ║    • Tools: Utilidades y herramientas adicionales                          ║
-- ║    • Homegrown: Plugins propios de 2kabhishek                              ║
-- ║    • Optional: Plugins opcionales según configuración del usuario          ║
-- ║                                                                            ║
-- ╚════════════════════════════════════════════════════════════════════════════╝

local util = require('lib.util')

-- ──────────────────────────────────────────────────────────────────────────────
-- 🔧 FUNCIÓN AUXILIAR PARA CARGA DE CONFIGURACIONES
-- ──────────────────────────────────────────────────────────────────────────────
-- Función helper que facilita la carga lazy de configuraciones de plugins
local function load_config(package)
    return function()
        require('plugins.' .. package)
    end
end

-- ──────────────────────────────────────────────────────────────────────────────
-- 📋 DEFINICIÓN PRINCIPAL DE PLUGINS
-- ──────────────────────────────────────────────────────────────────────────────
local plugins = {

    -- ═════════════════════════════════════════════════════════════════════════
    -- 🎨 CATEGORIA: UI (INTERFAZ DE USUARIO)
    -- ═════════════════════════════════════════════════════════════════════════
    -- Plugins relacionados con la apariencia y elementos visuales de Neovim

    {
        -- Tema principal OneDark con configuración personalizada
        'navarasu/onedark.nvim',
        config = load_config('ui.onedark'),
        lazy = false, -- Se carga inmediatamente
        priority = 1000, -- Alta prioridad para evitar parpadeos
    },

    {
        -- Iconos web para mejorar la visualización de archivos
        'nvim-tree/nvim-web-devicons',
    },

    {
        -- Snacks: Colección de utilities UI modernas
        'folke/snacks.nvim',
        priority = 1000,
        lazy = false,
        config = load_config('ui.snacks'),
    },

    {
        -- Barra de estado personalizable y moderna
        'nvim-lualine/lualine.nvim',
        config = load_config('ui.lualine'),
        event = { 'BufReadPost', 'BufNewFile' },
    },

    {
        -- Sistema de ayuda contextual para atajos de teclado
        'folke/which-key.nvim',
        config = load_config('ui.which-key'),
        event = 'VeryLazy',
    },

    {
        -- Indicadores visuales para Git (diff, blame, etc.)
        'lewis6991/gitsigns.nvim',
        config = load_config('ui.gitsigns'),
        cmd = 'Gitsigns',
        event = { 'BufReadPost', 'BufNewFile' },
    },

    {
        '2kabhishek/markit.nvim',
        config = load_config('ui.markit'),
        event = { 'BufReadPost', 'BufNewFile' },
    },

    -- ═════════════════════════════════════════════════════════════════════════
    -- 🛠️ CATEGORIA: TOOLS (HERRAMIENTAS GENERALES)
    -- ═════════════════════════════════════════════════════════════════════════
    -- Utilidades y herramientas para productividad
    {
        -- Herramienta avanzada para búsqueda y reemplazo en múltiples archivos
        'windwp/nvim-spectre',
        config = load_config('tools.spectre'), -- Carga la configuración personalizada para Spectre
        cmd = 'Spectre', -- Comando para abrir la interfaz de Spectre
    },
    {
        -- Generación de enlaces de Git para compartir código
        'ruifm/gitlinker.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = load_config('tools.gitlinker'),
        keys = '<leader>yg',
    },

    {
        -- Git wrapper clásico y confiable
        'tpope/vim-fugitive',
        cmd = 'Git',
    },
    -- ═════════════════════════════════════════════════════════════════════════
    -- 🏠 CATEGORIA: HOMEGROWN (PLUGINS DE 2KABHISHEK)
    -- ═════════════════════════════════════════════════════════════════════════
    {
        -- Selector genérico con soporte para múltiples proveedores
        '2kabhishek/pickme.nvim',
        cmd = 'PickMe',
        event = 'VeryLazy',
        dependencies = {
            'folke/snacks.nvim',
            -- 'nvim-telescope/telescope.nvim', -- Alternativo
            -- 'ibhagwan/fzf-lua',              -- Alternativo
        },
        opts = {
            picker_provider = 'snacks',
        },
    },

    {
        -- Utilidades compartidas para plugins de 2kabhishek
        '2kabhishek/utils.nvim',
        cmd = 'UtilsClearCache',
    },

    {
        -- Manejo de co-autores en commits
        '2kabhishek/co-author.nvim',
        cmd = 'CoAuthor',
    },

    {
        -- Selector de iconos y caracteres especiales
        '2kabhishek/nerdy.nvim',
        cmd = { 'Nerdy' },
        keys = { '<leader>in', '<leader>iN' },
        config = load_config('tools.nerdy'),
    },

    {
        -- Terminal integrado mejorado
        '2kabhishek/termim.nvim',
        cmd = { 'Fterm', 'FTerm', 'Sterm', 'STerm', 'Vterm', 'VTerm' },
    },

    {
        -- Gestor de TODOs integrado
        {
            '2kabhishek/tdo.nvim',
            cmd = { 'Tdo' },
            keys = { '<leader>nn', '<leader>nt', '<leader>nx', '[t', ']t' },
            config = load_config('tools.tdo'),
        },

        {
            -- Integración con GitHub para gestión de repositorios
            '2kabhishek/octohub.nvim',
            cmd = { 'Octohub' },
            keys = { '<leader>goo' },
            dependencies = {
                '2kabhishek/utils.nvim',
            },
            config = load_config('tools.octohub'),
        },

        {
            -- Integración con Exercism para práctica de programación
            '2kabhishek/exercism.nvim',
            cmd = { 'Exercism' },
            keys = { '<leader>exa', '<leader>exl', '<leader>exr' },
            dependencies = {
                '2kabhishek/utils.nvim',
                '2kabhishek/termim.nvim',
            },
            config = load_config('tools.exercism'),
        },

        -- Plugin de template comentado para desarrollo
        -- {
        --     '2kabhishek/template.nvim',
        --     cmd = { 'Template' },
        --     keys = { 'th' },
        --     dependencies = { '2kabhishek/utils.nvim', },
        --     config = load_config('tools.template'),
        --     opts = {},
        --     dir = '~/Projects/2KAbhishek/exercism.nvim/',
        -- },
    },
}
-- ──────────────────────────────────────────────────────────────────────────────
-- 📤 EXPORTACIÓN DE CONFIGURACIÓN
-- ──────────────────────────────────────────────────────────────────────────────
return {
    plugins = plugins,
}
-- ╔═════════════════════════════════════════════════════╗
-- ║                                                     ║
-- ║              Roberto Flores - Nvim                  ║
-- ║                                                     ║
-- ╚═════════════════════════════════════════════════════╝

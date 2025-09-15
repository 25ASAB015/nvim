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
        lazy = false,        -- Se carga inmediatamente
        priority = 1000,     -- Alta prioridad para evitar parpadeos
    },

    {
        -- Iconos web para mejorar la visualización de archivos
        'nvim-tree/nvim-web-devicons'
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

  -- ═════════════════════════════════════════════════════════════════════════
    -- 🛠️ CATEGORIA: TOOLS (HERRAMIENTAS GENERALES)
    -- ═════════════════════════════════════════════════════════════════════════
    -- Utilidades y herramientas para productividad
   
    {
        -- Generación de enlaces de Git para compartir código
        'ruifm/gitlinker.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = load_config('tools.gitlinker'),
        keys = '<leader>yg',
    },

     -- ═════════════════════════════════════════════════════════════════════════
    -- 🏠 CATEGORIA: HOMEGROWN (PLUGINS DE 2KABHISHEK)
    -- ═════════════════════════════════════════════════════════════════════════
    -- Plugins desarrollados específicamente por el autor de nvim2k
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
        config = load_config('tools.pickme'),
    },
    
    {
        -- Utilidades compartidas para plugins de 2kabhishek
        '2kabhishek/utils.nvim',
        cmd = 'UtilsClearCache',
    },

        -- Gestor de TODOs integrado
    {
        '2kabhishek/tdo.nvim',
        cmd = { 'Tdo' },
        keys = { '<leader>nn', '<leader>nt', '<leader>nx', '[t', ']t' },
        config = load_config('tools.tdo'),
    },
    {
        -- Terminal integrado mejorado
        '2kabhishek/termim.nvim',
        cmd = { 'Fterm', 'FTerm', 'Sterm', 'STerm', 'Vterm', 'VTerm' },
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

    {
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

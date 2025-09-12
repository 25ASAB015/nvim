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
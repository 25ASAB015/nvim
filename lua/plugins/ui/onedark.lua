-- ╔════════════════════════════════════════════════════════════════════════════════════╗
-- ║ onedark.lua: Configuración centralizada del tema OneDark para Neovim               ║
-- ║ Este archivo se encarga de definir y gestionar la apariencia del editor            ║
-- ║ utilizando el tema OneDark, permitiendo personalizar estilos, transparencias,      ║
-- ║ colores de diagnóstico y otras opciones visuales clave.                            ║
-- ║                                                                                    ║
-- ║ Aquí se agrupan y documentan las principales opciones del tema, como el estilo     ║
-- ║ (dark, deep, warm, etc.), la transparencia, la integración con lualine y           ║
-- ║ configuraciones para resaltar código y diagnósticos.                               ║
-- ║ Esto permite mantener una apariencia consistente y fácilmente ajustable en         ║
-- ║ todo el entorno de Neovim.                                                         ║
-- ║                                                                                    ║
-- ╚════════════════════════════════════════════════════════════════════════════════════╝


-- Carga el módulo principal del tema OneDark
local onedark = require('onedark')

-- Configuración personalizada del tema OneDark
onedark.setup({
    -- Estilo principal del tema (opciones: dark, darker, cool, warm, warmer, deep, light)
    style = 'deep',

    -- Habilita la transparencia en el fondo del editor
    transparent = true,

    -- Desactiva los colores personalizados en la terminal integrada
    term_colors = false,

    -- Oculta las tildes (~) al final de los buffers vacíos
    ending_tildes = false,

    -- Mantiene el orden original de los íconos en los menús de autocompletado
    cmp_itemkind_reverse = false,

    -- Tecla para alternar entre los diferentes estilos del tema
    toggle_style_key = '<leader>ot',

    -- Lista de estilos disponibles para alternar dinámicamente
    toggle_style_list = { 'dark', 'darker', 'cool', 'warm', 'warmer', 'deep', 'light' },

    -- Estilos de resaltado para diferentes elementos del código
    code_style = {
        comments = 'italic',    -- Comentarios en cursiva
        keywords = 'none',      -- Palabras clave sin estilo especial
        functions = 'none',     -- Funciones sin estilo especial
        strings = 'none',       -- Cadenas de texto sin estilo especial
        variables = 'none',     -- Variables sin estilo especial
    },

    -- Configuración de transparencia para la barra de estado lualine
    lualine = { transparent = true },

    -- Opciones de resaltado para diagnósticos (LSP, errores, advertencias, etc.)
    diagnostics = { 
        darker = true,         -- Colores más oscuros para diagnósticos
        undercurl = true,      -- Subrayado con curva para diagnósticos
        background = false     -- Sin fondo especial para diagnósticos
    },
})

-- Aplica la configuración y carga el tema OneDark
onedark.load()

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║                                                                      ║
-- ║              Roberto Flores - Nvim                                   ║
-- ║                                                                      ║
-- ╚══════════════════════════════════════════════════════════════════════╝
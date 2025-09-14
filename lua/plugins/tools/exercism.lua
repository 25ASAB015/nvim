-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ exercism.lua: Configuración de integración con Exercism              ║
-- ║ Este archivo es invocado desde la configuración de plugins           ║
-- ║                                                                      ║
-- ║ Este archivo define y documenta la configuración principal para      ║
-- ║ la integración de Neovim con la plataforma Exercism, permitiendo     ║
-- ║ gestionar ejercicios, enviar soluciones y navegar el workspace.      ║
-- ║ Aquí se establecen valores predeterminados como el workspace,        ║
-- ║ el lenguaje por defecto, y otras opciones para personalizar la       ║
-- ║ experiencia de práctica de programación desde el editor.             ║
-- ║                                                                      ║
-- ╚══════════════════════════════════════════════════════════════════════╝

-- Configuración principal para el plugin de integración con Exercism.
-- Define el directorio de trabajo, el lenguaje por defecto, y otras opciones.
local exercism = require('exercism')

exercism.setup({
    -- Ruta al workspace donde se almacenan los ejercicios de Exercism
    exercism_workspace = '~/Projects/25ASAB015/exercism',
    -- Habilita los atajos de teclado predeterminados del plugin
    add_default_keybindings = true,
---Add default keybindings for Exercism commands
-- local function add_default_keymaps()
--     local mappings = {
--         { '<leader>exa', ':Exercism languages<CR>', 'All Exercism Languages' },
--         { '<leader>exl', ':Exercism list<CR>', 'List Default Language Exercises' },
--         { '<leader>exr', ':Exercism recents<CR>', 'Recent Exercises' },
--         { '<leader>ext', ':Exercism test<CR>', 'Test Exercise' },
--         { '<leader>exs', ':Exercism submit<CR>', 'Submit Exercise' },
--     }
    -- Lenguaje de programación por defecto al descargar ejercicios
    default_language = 'elixir',
    -- Usa el nuevo comando de Exercism CLI si está disponible
    use_new_command = true,
    -- Número máximo de ejercicios recientes a mostrar
    max_recents = 80,
})


-- ╔═════════════════════════════════════════════════════╗
-- ║                                                     ║
-- ║              Roberto Flores - Nvim                  ║
-- ║                                                     ║
-- ╚═════════════════════════════════════════════════════╝
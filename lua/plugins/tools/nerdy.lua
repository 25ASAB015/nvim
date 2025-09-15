-- ╔════════════════════════════════════════════════════════╗
-- ║ nerdy.lua: Configuración del plugin de selección de    ║
-- ║ iconos y caracteres especiales                         ║
-- ║ Este archivo es invocado desde 'init.lua'              ║
-- ║                                                        ║
-- ║ Este archivo define y documenta la configuración del   ║
-- ║ plugin de selección de iconos y caracteres especiales, ║
-- ║ permitiendo personalizar el comportamiento y la        ║
-- ║ integración con otras herramientas.                    ║
-- ║                                                        ║
-- ╚════════════════════════════════════════════════════════╝


-- Requiere el módulo principal del plugin 'nerdy'
local nerdy = require('nerdy')

-- Configuración del plugin 'nerdy'
nerdy.setup({
    max_recents = 80,                -- Número máximo de iconos/caracteres recientes a recordar
    add_default_keybindings = true,  -- Habilita los atajos de teclado predeterminados
    use_new_command = true,          -- Usa el nuevo comando para abrir el selector
})

-- function M.setup()
--     add_nerdy_command()
--     if config.add_default_keybindings then
--         vim.api.nvim_set_keymap('n', '<leader>in', ':Nerdy list<CR>', { noremap = true, silent = true })
--         vim.api.nvim_set_keymap('n', '<leader>iN', ':Nerdy recents<CR>', { noremap = true, silent = true })
--     end
-- end

-- ╔═════════════════════════════════════════════════════╗
-- ║                                                     ║
-- ║              Roberto Flores - Nvim                  ║
-- ║                                                     ║
-- ╚═════════════════════════════════════════════════════╝
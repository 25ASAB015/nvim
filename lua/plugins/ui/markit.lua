-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ markit.lua: Configuración y documentación del plugin Markit         ║
-- ║ Este archivo es invocado desde la configuración de plugins          ║
-- ║                                                                    ║
-- ║ Aquí se definen las opciones principales para el plugin Markit,     ║
-- ║ permitiendo personalizar el manejo de marcas y bookmarks en Neovim. ║
-- ║ Se establecen valores predeterminados para iconos, prioridades,     ║
-- ║ exclusiones y tipos de bookmarks, adaptando la experiencia de uso   ║
-- ║ a flujos de trabajo modernos y eficientes.                          ║
-- ║                                                                    ║
-- ╚══════════════════════════════════════════════════════════════════════╝

-- Requiere el módulo principal del plugin 'markit'
local markit = require('markit')
local icons = require('lib.icons')

-- Configuración principal del plugin 'markit'
markit.setup({
    add_default_keybindings = true,
    builtin_marks = { '.', '<', '>', '^' },
    cyclic = true,
    force_write_shada = false,
    sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
    excluded_filetypes = {},
    excluded_buftypes = { 'nofile' },
    bookmarks = {
        { sign = icons.ui.Neovim, virt_text = 'flag', annotate = false },
        { sign = icons.ui.Eye, virt_text = 'watch', annotate = false },
        { sign = icons.ui.Star, virt_text = 'star', annotate = false },
        { sign = icons.ui.Bug, virt_text = 'bug', annotate = false },
    },
})


-- local function setup_default_keybindings(config)
--     local mappings = {
--         { '<leader>mm', ':Markit mark list all<cr>', 'All Marks' },
--         { '<leader>mM', ':Markit mark list buffer<cr>', 'Buffer Marks' },
--         { '<leader>ms', ':Markit mark set<cr>', 'Set Next Available Mark' },
--         { '<leader>mS', ':Markit mark set<cr>', 'Set Mark (Interactive)' },
--         { '<leader>mt', ':Markit mark toggle<cr>', 'Toggle Mark at Cursor' },
--         { '<leader>mT', ':Markit mark toggle<cr>', 'Toggle Mark (Interactive)' },

--         { '<leader>mj', ':Markit mark next<cr>', 'Next Mark' },
--         { '<leader>mk', ':Markit mark prev<cr>', 'Previous Mark' },
--         { '<leader>mP', ':Markit mark preview<cr>', 'Preview Mark' },

--         { '<leader>md', ':Markit mark delete line<cr>', 'Delete Marks In Line' },
--         { '<leader>mD', ':Markit mark delete buffer<cr>', 'Delete Marks In Buffer' },
--         { '<leader>mX', ':Markit mark delete<cr>', 'Delete Mark (Interactive)' },

--         { '<leader>mb', ':Markit bookmark list all<cr>', 'All Bookmarks' },
--         { '<leader>mx', ':Markit bookmark delete<cr>', 'Delete Bookmark at Cursor' },
--         { '<leader>ma', ':Markit bookmark annotate<cr>', 'Annotate Bookmark' },

--         { '<leader>ml', ':Markit bookmark next<cr>', 'Next Bookmark' },
--         { '<leader>mh', ':Markit bookmark prev<cr>', 'Previous Bookmark' },

--         { '<leader>mv', ':Markit bookmark signs<cr>', 'Toggle Signs' },

--         { '<leader>mqm', ':Markit mark list quickfix all<cr>', 'All Marks → QuickFix' },
--         { '<leader>mqb', ':Markit bookmark list quickfix all<cr>', 'All Bookmarks → QuickFix' },
--         { '<leader>mqM', ':Markit mark list quickfix buffer<cr>', 'Buffer Marks → QuickFix' },
--         { '<leader>mqg', ':Markit mark list quickfix all<cr>', 'All Marks → QuickFix' },
--     }


-- ╔═════════════════════════════════════════════════════╗
-- ║                                                     ║
-- ║              Roberto Flores - Nvim                  ║
-- ║                                                     ║
-- ╚═════════════════════════════════════════════════════╝

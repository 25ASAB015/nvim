-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ tdo.lua: Configuración de la herramienta de gestión de tareas        ║
-- ║ Este archivo es invocado desde 'init.lua'                            ║
-- ║                                                                      ║
-- ║ Este archivo define y documenta la configuración de la herramienta   ║
-- ║ de gestión de tareas, permitiendo personalizar el comportamiento y   ║
-- ║ la integración con otras herramientas.                               ║
-- ║                                                                      ║
-- ╚══════════════════════════════════════════════════════════════════════╝

-- Requiere el módulo principal de la herramienta de gestión de tareas
local tdo = require('tdo')

-- Configura la herramienta de gestión de tareas con las siguientes opciones:
tdo.setup({
    -- Habilita el uso de un nuevo comando para gestionar tareas
    use_new_command = true,
    -- Añade los atajos de teclado predeterminados para la herramienta
    add_default_keybindings = true,
    -- Configuración de la caché para mejorar el rendimiento
    cache = {
        -- Tiempo de expiración de la caché en milisegundos
        timeout = 5000,
        -- Número máximo de entradas que se pueden almacenar en la caché
        max_entries = 100,
    },
    -- Opciones relacionadas con la autocompletación de tareas
    completion = {
        -- Desplazamientos personalizados para la autocompletación (vacío por defecto)
        offsets = {},
        -- Archivos y carpetas que serán ignorados por la autocompletación
        ignored_files = { 'README.md', 'templates', 'todos.sh' },
    },
})


-- local function add_default_keymaps()
--     local mappings = {
--         { '<leader>nn', ':Tdo<CR>', "Today's Todo" },
--         { '<leader>ne', ':Tdo entry<CR>', "Today's Entry" },
--         { '<leader>nf', ':Tdo files<CR>', 'All Notes' },
--         { '<leader>ng', ':Tdo find<CR>', 'Find Notes' },
--         { '<leader>nh', ':Tdo yesterday<CR>', "Yesterday's Todo" },
--         { '<leader>nl', ':Tdo tomorrow<CR>', "Tomorrow's Todo" },
--         { '<leader>nc', ':Tdo note<CR>', 'Create Note' },
--         { '<leader>nt', ':Tdo todos<CR>', 'Incomplete Todos' },
--         { '<leader>nx', ':Tdo toggle<CR>', 'Toggle Todo' },

--         { ']t', [[/\v\[ \]\_s*[^[]<CR>:noh<CR>]], 'Next Todo' },
--         { '[t', [[?\v\[ \]\_s*[^[]<CR>:noh<CR>]], 'Prev Todo' },
--     }

--     table.insert(mappings, {
--         '<leader>ns',
--         ':lua require("tdo.notes").run_with("commit " .. vim.fn.expand("%:p")) vim.notify("Tdo Committed!")<CR>',
--         'Commit Note',
--     })

--     for i = 1, 9 do
--         table.insert(mappings, {
--             string.format('<leader>nd%d', i),
--             string.format(':Tdo %d<CR>', i),
--             string.format('Todo %d Days Later', i),
--         })

--         table.insert(mappings, {
--             string.format('<leader>nD%d', i),
--             string.format(':Tdo -%d<CR>', i),
--             string.format('Todo %d Days Ago', i),
--         })

--         table.insert(mappings, {
--             string.format('<leader>nw%d', i),
--             string.format(':Tdo %d-weeks-later<CR>', i),
--             string.format('Todo %d Weeks Later', i),
--         })

--         table.insert(mappings, {
--             string.format('<leader>nW%d', i),
--             string.format(':Tdo %d-weeks-ago<CR>', i),
--             string.format('Todo %d Weeks Ago', i),
--         })

--         table.insert(mappings, {
--             string.format('<leader>nm%d', i),
--             string.format(':Tdo %d-months-later<CR>', i),
--             string.format('Todo %d Months Later', i),
--         })

--         table.insert(mappings, {
--             string.format('<leader>nM%d', i),
--             string.format(':Tdo %d-months-ago<CR>', i),
--             string.format('Todo %d Months Ago', i),
--         })

--         table.insert(mappings, {
--             string.format('<leader>ny%d', i),
--             string.format(':Tdo %d-years-later<CR>', i),
--             string.format('Todo %d Years Later', i),
--         })

--         table.insert(mappings, {
--             string.format('<leader>nY%d', i),
--             string.format(':Tdo %d-years-ago<CR>', i),
--             string.format('Todo %d Years Ago', i),
--         })
--     end


-- ╔═════════════════════════════════════════════════════╗
-- ║                                                     ║
-- ║              Roberto Flores - Nvim                  ║
-- ║                                                     ║
-- ╚═════════════════════════════════════════════════════╝
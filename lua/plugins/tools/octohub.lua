-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ octohub.lua: Configuración del plugin Octohub para Neovim            ║
-- ║ Este archivo es invocado desde 'init.lua'                            ║
-- ║                                                                      ║
-- ║ Este archivo define y documenta la configuración del plugin Octohub, ║
-- ║ permitiendo personalizar la visualización y el comportamiento de las ║
-- ║ estadísticas de GitHub en Neovim.                                    ║
-- ║                                                                      ║
-- ╚══════════════════════════════════════════════════════════════════════╝

local octohub = require('octohub')

octohub.setup({
    -- Configuración de los repositorios
    repos = {
        per_user_dir = true,           -- Crea un subdirectorio por usuario de GitHub
        projects_dir = '~/Projects/',  -- Directorio raíz donde se almacenan los repositorios
        sort_by = '',                  -- Criterio de ordenamiento de repos (vacío = por defecto)
        repo_type = '',                -- Tipo de repos a mostrar (vacío = todos)
    },
    -- Configuración de las estadísticas y visualización
    stats = {
        contribution_icons = { '', '', '', '', '', '', '' }, -- Iconos para el gráfico de contribuciones
        max_contributions = 50,        -- Máximo de contribuciones a mostrar
        top_lang_count = 5,            -- Número de lenguajes principales a mostrar
        event_count = 5,               -- Número de eventos recientes a mostrar
        window_width = 90,             -- Ancho de la ventana de estadísticas
        window_height = 60,            -- Alto de la ventana de estadísticas
        show_recent_activity = true,   -- Mostrar actividad reciente
        show_contributions = true,     -- Mostrar gráfico de contribuciones
        show_repo_stats = true,        -- Mostrar estadísticas de repositorios
    },
    -- Configuración de caché (en segundos)
    cache = {
        events = 3600 * 6,             -- Caché de eventos: 6 horas
        contributions = 3600 * 6,      -- Caché de contribuciones: 6 horas
        repos = 3600 * 24 * 7,         -- Caché de repositorios: 1 semana
        username = 3600 * 24 * 7,      -- Caché de nombre de usuario: 1 semana
        user = 3600 * 24 * 7,          -- Caché de datos de usuario: 1 semana
    },
    add_default_keybindings = true,    -- Habilita los atajos de teclado predeterminados
    use_new_command = true,            -- Usa el nuevo comando de Octohub si está disponible
})

-- ---Add all default keymaps for Octohub commands
-- local function add_default_keymaps()
--     local mappings = {
--         { '<leader>goo', ':Octohub repos<CR>', 'All Repos' },

--         { '<leader>gob', ':Octohub repos sort:size<CR>', 'Repos by Size' },
--         { '<leader>goc', ':Octohub repos sort:created<CR>', 'Repos by Created' },
--         { '<leader>gof', ':Octohub repos sort:forks<CR>', 'Repos by Forks' },
--         { '<leader>goi', ':Octohub repos sort:issues<CR>', 'Repos by Issues' },
--         { '<leader>gol', ':Octohub repos sort:language<CR>', 'Repos by Language' },
--         { '<leader>gos', ':Octohub repos sort:stars<CR>', 'Repos by Stars' },
--         { '<leader>gou', ':Octohub repos sort:updated<CR>', 'Repos by Updated' },
--         { '<leader>goU', ':Octohub repos sort:pushed<CR>', 'Repos by Pushed' },

--         { '<leader>goA', ':Octohub repos type:archived<CR>', 'Archived Repos' },
--         { '<leader>goF', ':Octohub repos type:forked<CR>', 'Forked Repos' },
--         { '<leader>goP', ':Octohub repos type:private<CR>', 'Private Repos' },
--         { '<leader>goS', ':Octohub repos type:starred<CR>', 'Starred Repos' },
--         { '<leader>goT', ':Octohub repos type:template<CR>', 'Template Repos' },

--         { '<leader>goL', ':Octohub repos languages<CR>', 'Filter by Language' },

--         { '<leader>goa', ':Octohub stats activity<CR>', 'Activity Stats' },
--         { '<leader>gog', ':Octohub stats contributions<CR>', 'Contribution Graph' },
--         { '<leader>gor', ':Octohub stats repo<CR>', 'Repo Stats' },
--         { '<leader>got', ':Octohub stats<CR>', 'All Stats' },

--         { '<leader>gop', ':Octohub web profile<CR>', 'Open GitHub Profile' },
--         { '<leader>gow', ':Octohub web repo<CR>', 'Open Repo in Browser' },
--     }

-- ╔═════════════════════════════════════════════════════╗
-- ║                                                     ║
-- ║              Roberto Flores - Nvim                  ║
-- ║                                                     ║
-- ╚═════════════════════════════════════════════════════╝



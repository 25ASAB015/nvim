-- ╔════════════════════════════════════════════════════════════════════════════════════╗
-- ║ lazy.lua: Configuración del gestor de plugins Lazy.nvim                            ║
-- ║ Este archivo es invocado desde 'init.lua'                                          ║
-- ║                                                                                    ║
-- ║ Aquí se configura Lazy.nvim, el gestor de plugins moderno para Neovim que          ║
-- ║ permite la carga perezosa (lazy loading) de plugins para optimizar el tiempo       ║
-- ║ de inicio. Define la instalación automática, configuración de UI, gestión de       ║
-- ║ dependencias, y comportamientos de rendimiento para una experiencia fluida         ║
-- ║ y eficiente en el manejo de plugins.                                               ║
-- ║                                                                                    ║
-- ╚════════════════════════════════════════════════════════════════════════════════════╝

-- Configuración de la ruta donde se instalará Lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

-- Instalación automática de Lazy.nvim si no existe
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        '--single-branch',
        'https://github.com/folke/lazy.nvim.git',
        lazypath,
    })
end

-- Prepende Lazy.nvim al runtimepath para que esté disponible
vim.opt.runtimepath:prepend(lazypath)

-- Carga segura del módulo lazy con manejo de errores
local status_ok, lazy = pcall(require, 'lazy')
if not status_ok then
    return
end

-- Importa los iconos personalizados para la interfaz
local icons = require('lib.icons')
-- Importa la lista de plugins desde el módulo correspondiente
local plugins = require('plugins.list').plugins

-- Configuración principal de Lazy.nvim
lazy.setup({
    -- Directorio raíz donde se instalan los plugins
    root = vim.fn.stdpath('data') .. '/lazy',
    -- Configuración por defecto: todos los plugins se cargan de forma perezosa
    defaults = { lazy = true },
    -- Especificación de los plugins a cargar
    spec = plugins,
    -- Archivo de bloqueo para versiones específicas de plugins
    lockfile = vim.fn.stdpath('config') .. '/lua/plugins/lock.json',
    -- Número de plugins que se pueden instalar/actualizar simultáneamente
    concurrency = 8,
    -- Configuración para desarrollo local de plugins
    dev = { path = '~/Projects/2KAbhishek/', patterns = { '2kabhishek' }, fallback = true },
    -- Configuración de instalación automática
    install = { missing = true, colorscheme = { 'onedark' } },
    -- Configuración de Git para la gestión de plugins
    git = {
        log = { '--since=3 days ago' },
        timeout = 120,
        url_format = 'https://github.com/%s.git',
        filter = true,
    },
    -- Configuración de la interfaz de usuario de Lazy
    ui = {
        -- Tamaño de la ventana de Lazy
        size = { width = 0.9, height = 0.8 },
        wrap = true,
        border = 'rounded',
        -- Iconos personalizados para diferentes elementos
        icons = {
            cmd = icons.ui.Terminal,
            config = icons.ui.Gear,
            event = icons.ui.Electric,
            ft = icons.documents.File,
            init = icons.ui.Rocket,
            import = icons.documents.Import,
            keys = icons.ui.Keyboard,
            lazy = icons.ui.Sleep,
            loaded = icons.ui.CircleSmall,
            not_loaded = icons.ui.CircleSmallEmpty,
            plugin = icons.ui.Package,
            runtime = icons.ui.Neovim,
            source = icons.ui.Code,
            start = icons.ui.Play,
            task = icons.ui.Check,
            list = {
                icons.ui.CircleSmall,
                icons.ui.Arrow,
                icons.ui.Star,
                icons.ui.Minus,
            },
        },
        browser = nil,
        throttle = 20,
        -- Atajos de teclado personalizados en la interfaz de Lazy
        custom_keys = {
            -- 'l': Abre lazygit para ver el log del plugin
            ['<localleader>l'] = function(plugin)
                require('lazy.util').float_term({ 'lazygit', 'log' }, {
                    cwd = plugin.dir,
                })
            end,
            -- 't': Abre una terminal en el directorio del plugin
            ['<localleader>t'] = function(plugin)
                require('lazy.util').float_term(nil, {
                    cwd = plugin.dir,
                })
            end,
        },
    },
    -- Configuración para mostrar diferencias en actualizaciones
    diff = { cmd = 'git' },
    -- Configuración del verificador automático de actualizaciones
    checker = { enabled = false, concurrency = nil, notify = true, frequency = 3600 },
    -- Configuración de detección de cambios en plugins
    change_detection = { enabled = true, notify = true },
    -- Configuraciones de rendimiento y optimización
    performance = {
        cache = { enabled = true },
        reset_packpath = true,
        rtp = {
            reset = true,
            paths = {},
            -- Plugins deshabilitados para mejorar el tiempo de inicio
            disabled_plugins = {
                'gzip',
                'tarPlugin',
                'zipPlugin',
                'tohtml',
                -- 'tutor',
                -- 'matchit',
                -- 'matchparen',
                -- 'netrwPlugin',
            },
        },
    },
    -- Configuración para archivos README de plugins
    readme = {
        root = vim.fn.stdpath('state') .. '/lazy/readme',
        files = { 'README.md', 'lua/**/README.md' },
        skip_if_doc_exists = true,
    },
    -- Archivo de estado para persistir información entre sesiones
    state = vim.fn.stdpath('state') .. '/lazy/state.json',
})

-- ╔═════════════════════════════════════════════════════╗
-- ║                                                     ║
-- ║              Roberto Flores - Nvim                  ║
-- ║                                                     ║
-- ╚═════════════════════════════════════════════════════╝
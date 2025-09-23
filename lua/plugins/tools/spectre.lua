-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ spectre.lua: Configuración y documentación de nvim-spectre          ║
-- ║ Este archivo configura el plugin 'nvim-spectre' para búsqueda y     ║
-- ║ reemplazo avanzado en múltiples archivos dentro de Neovim.           ║
-- ║                                                                    ║
-- ║ Proporciona atajos y opciones para facilitar refactorizaciones      ║
-- ║ globales, permitiendo buscar y reemplazar patrones en el proyecto,  ║
-- ║ buffer actual o selecciones visuales. Los mapeos y colores están    ║
-- ║ adaptados para una experiencia coherente con el resto del entorno.  ║
-- ║                                                                    ║
-- ║ Este archivo es cargado automáticamente cuando se invoca Spectre    ║
-- ║ mediante comandos o atajos definidos en which-key.                  ║
-- ╚══════════════════════════════════════════════════════════════════════╝

-- Carga el módulo principal del plugin Spectre
local spectre = require('spectre')

-- Configuración principal de Spectre
spectre.setup({
    -- Visual: colorea los iconos (devicons) en los resultados
    color_devicons = true,
    -- Grupos de resaltado usados por la UI de Spectre
    highlight = {
        ui = 'String',
        search = 'DiffChange',
        replace = 'DiffDelete',
    },
    -- Atajos dentro del panel de resultados de Spectre
    mapping = {
        -- t: alterna la selección del ítem/resultado actual
        ['toggle_line'] = {
            map = 't',
            cmd = ":lua require('spectre').toggle_line()<cr>",
            desc = 'toggle current item',
        },
        -- Enter: abre el archivo en la ubicación del resultado
        ['enter_file'] = {
            map = '<cr>',
            cmd = ":lua require('spectre.actions').select_entry()<cr>",
            desc = 'goto current file',
        },
        -- Q: envía todos los resultados al quickfix para revisión masiva
        ['send_to_qf'] = {
            map = 'Q',
            cmd = ":lua require('spectre.actions').send_to_qf()<cr>",
            desc = 'send all item to quickfix',
        },
        -- c: abre un prompt para escribir el comando de reemplazo de Vim
        ['replace_cmd'] = {
            map = 'c',
            cmd = ":lua require('spectre.actions').replace_cmd()<cr>",
            desc = 'input replace vim command',
        },
        -- o: muestra el menú de opciones (filtros/toggles)
        ['show_option_menu'] = {
            map = 'o',
            cmd = ":lua require('spectre').show_options()<cr>",
            desc = 'show option',
        },
        -- R: ejecuta el reemplazo en todos los ítems marcados
        ['run_replace'] = {
            map = 'R',
            cmd = ":lua require('spectre.actions').run_replace()<cr>",
            desc = 'replace all',
        },
        -- m: alterna el modo de vista de resultados (compacta/detallada)
        ['change_view_mode'] = {
            map = 'm',
            cmd = ":lua require('spectre').change_view()<cr>",
            desc = 'change result view mode',
        },
        -- I: activar/desactivar búsqueda que ignora mayúsculas
        ['toggle_ignore_case'] = {
            map = 'I',
            cmd = ":lua require('spectre').change_options('ignore-case')<cr>",
            desc = 'toggle ignore case',
        },
        -- H: incluir/ocultar archivos ocultos en la búsqueda
        ['toggle_ignore_hidden'] = {
            map = 'H',
            cmd = ":lua require('spectre').change_options('hidden')<cr>",
            desc = 'toggle search hidden',
        },
    },
    -- Motores de búsqueda disponibles (puedes alternar entre rg/ag)
    find_engine = {
        ['rg'] = {
            cmd = 'rg',
            -- Argumentos por defecto para ripgrep (salida compatible con Spectre)
            args = {
                '--color=never',
                '--no-heading',
                '--with-filename',
                '--line-number',
                '--column',
            },
            -- Opciones que puedes activar/desactivar desde el panel de Spectre
            options = {
                ['ignore-case'] = {
                    value = '--ignore-case',
                    icon = '[I]',
                    desc = 'ignore case',
                },
                ['hidden'] = {
                    value = '--hidden',
                    desc = 'hidden file',
                    icon = '[H]',
                },
            },
        },
        ['ag'] = {
            cmd = 'ag',
            -- Argumentos por defecto para The Silver Searcher
            args = {
                '--vimgrep',
                '-s',
            },
            -- Opciones con significado equivalente a las de rg
            options = {
                ['ignore-case'] = {
                    value = '-i',
                    icon = '[I]',
                    desc = 'ignore case',
                },
                ['hidden'] = {
                    value = '--hidden',
                    desc = 'hidden file',
                    icon = '[H]',
                },
            },
        },
    },
    -- Motor de reemplazo (externo). Por defecto se usa 'sed'
    replace_engine = {
        ['sed'] = {
            cmd = 'sed',
            args = nil,
        },
        -- Opciones aplicables al motor de reemplazo
        options = {
            ['ignore-case'] = {
                value = '--ignore-case',
                icon = '[I]',
                desc = 'ignore case',
            },
        },
    },
    -- Valores por defecto al abrir Spectre
    default = {
        -- Búsqueda: usa ripgrep con ignore-case activado
        find = {
            cmd = 'rg',
            options = { 'ignore-case' },
        },
        -- Reemplazo: usa sed
        replace = {
            cmd = 'sed',
        },
    },
    -- Comando de Vim para aplicar reemplazos sobre la quickfix list (cdo)
    -- Alternativas comunes: cfdo (por archivo) o %s (en el buffer actual)
    replace_vim_cmd = 'cdo',
    -- Abre la ventana del archivo objetivo al entrar desde los resultados
    is_open_target_win = true,
    -- Empieza en modo Insert para escribir patrones de búsqueda de inmediato
    is_insert_mode = true,
})

-- ╔═════════════════════════════════════════════════════╗
-- ║                                                     ║
-- ║              Roberto Flores - Nvim                  ║
-- ║                                                     ║
-- ╚═════════════════════════════════════════════════════╝

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ gitlinker.lua: Configuración del plugin Gitlinker para Neovim       ║
-- ║ Este archivo es invocado desde la configuración de plugins           ║
-- ║                                                                      ║
-- ║ Proporciona enlaces directos (perma-enlaces) a líneas/rangos del     ║
-- ║ repositorio remoto desde el buffer actual. Copia al portapapeles o   ║
-- ║ imprime la URL, y soporta múltiples forjas (GitHub, GitLab, Gitea,   ║
-- ║ Bitbucket, etc.).                                                    ║
-- ║                                                                      ║
-- ╚══════════════════════════════════════════════════════════════════════╝

local gitlinker = require('gitlinker')

gitlinker.setup({
    -- Opciones generales
    opts = {
        remote = nil, -- Usa remoto por defecto (o establece 'origin', 'upstream', etc.)
        add_current_line_on_normal_mode = true, -- En modo normal, incluye la línea actual
        action_callback = require('gitlinker.actions').copy_to_clipboard, -- Copiar URL al portapapeles
        print_url = true, -- También imprimir la URL generada
    },

    -- Soporte para distintos hosts/forjas
    callbacks = {
        ['github.com'] = require('gitlinker.hosts').get_github_type_url,
        ['gitlab.com'] = require('gitlinker.hosts').get_gitlab_type_url,
        ['try.gitea.io'] = require('gitlinker.hosts').get_gitea_type_url,
        ['codeberg.org'] = require('gitlinker.hosts').get_gitea_type_url,
        ['bitbucket.org'] = require('gitlinker.hosts').get_bitbucket_type_url,
        ['try.gogs.io'] = require('gitlinker.hosts').get_gogs_type_url,
        ['git.sr.ht'] = require('gitlinker.hosts').get_srht_type_url,
        ['git.launchpad.net'] = require('gitlinker.hosts').get_launchpad_type_url,
        ['repo.or.cz'] = require('gitlinker.hosts').get_repoorcz_type_url,
        ['git.kernel.org'] = require('gitlinker.hosts').get_cgit_type_url,
        ['git.savannah.gnu.org'] = require('gitlinker.hosts').get_cgit_type_url,
    },

    -- Mapeo por defecto provisto por el plugin
    -- Nota: Declarado también en la especificación de plugins para lazy-load
    mappings = '<leader>yg',
})

-- Ejemplos de mapeos adicionales (descomentarlos si se añaden en plugins.list)
-- local actions = require('gitlinker.actions')
-- vim.keymap.set('n', '<leader>yG', function()
--     gitlinker.get_buf_range_url('n', { action_callback = actions.open_in_browser })
-- end, { desc = 'Gitlinker: abrir enlace en navegador' })
-- vim.keymap.set('v', '<leader>yG', function()
--     gitlinker.get_buf_range_url('v', { action_callback = actions.open_in_browser })
-- end, { desc = 'Gitlinker: abrir selección en navegador' })

-- ╔═════════════════════════════════════════════════════╗
-- ║                                                     ║
-- ║              Roberto Flores - Nvim                  ║
-- ║                                                     ║
-- ╚═════════════════════════════════════════════════════╝




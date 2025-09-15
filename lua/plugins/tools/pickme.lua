-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ pickme.lua: Configuración del plugin PickMe para Neovim              ║
-- ║ Este archivo es invocado desde 'init.lua'                            ║
-- ║                                                                      ║
-- ║ Este archivo define y documenta la configuración del plugin PickMe,  ║
-- ║ permitiendo personalizar el proveedor de picker y los atajos         ║
-- ║ de teclado para búsquedas y selección de archivos en Neovim.         ║
-- ║                                                                      ║
-- ╚══════════════════════════════════════════════════════════════════════╝

require('pickme').setup({
    -- Elige tu proveedor de picker preferido
    picker_provider = 'snacks', -- Opciones: 'snacks' (por defecto), 'telescope', 'fzf_lua'
  
    -- Detección automática de proveedores de picker disponibles (por defecto: true)
    -- Si el picker_provider especificado no está disponible, intentará usar uno de la lista provider_priority
    detect_provider = true,
  
    -- Añadir atajos de teclado por defecto (por defecto: true)
    -- Ver la sección de Keybindings abajo para la lista completa de atajos por defecto
    add_default_keybindings = true,
  
    -- Alias de comandos para accesos directos convenientes
    -- Ejemplo: usar ':PickMe grep' llamará a ':PickMe live_grep'
    command_aliases = {
      grep = 'live_grep',
      -- Añade tus propios alias aquí
    }
  })

-- Personalizado: buscar archivos en cualquier parte de $HOME por nombre
local home_dir = vim.loop.os_homedir()
vim.keymap.set('n', '<leader>eh', function()
  local exclude_dirs = {
    '.git', '.cache', 'node_modules', '.venv', 'venv',
    'target', 'build', 'dist', '.mozilla',
    '.cargo', '.rustup', '.npm', '.nvm'
  }

  -- Preferir fd si está disponible para un listado rápido del sistema de archivos
  local fd_cmd = { 'fd', '--type', 'f', '--hidden', '--follow' }
  for _, d in ipairs(exclude_dirs) do
    table.insert(fd_cmd, '--exclude'); table.insert(fd_cmd, d)
  end

  require('pickme').pick('files', {
    cwd = home_dir,
    title = 'Home Files',
    hidden = true,
    -- Passthrough compatible con Telescope
    find_command = fd_cmd,
    -- Passthrough compatible con fzf-lua
    fd_opts = table.concat({
      '--type f', '--hidden', '--follow',
      table.concat(vim.tbl_flatten(vim.tbl_map(function(x) return { '--exclude', x } end, exclude_dirs)), ' '),
    }, ' '),
    -- Ignorados genéricos que muchos proveedores respetan
    file_ignore_patterns = {
      '%.git/', 'node_modules/', '%.cache/', 'target/', 'build/', 'dist/',
      '%.venv/', '/venv/', '%.mozilla/', '%.cargo/',
      '%.rustup/', '%.npm/', '%.nvm/'
    },
    exclude = exclude_dirs,
  })
end, { desc = 'Home Files' })

-- Directorios en $HOME -> abrir nueva instancia de Neovim en el directorio seleccionado
vim.keymap.set('n', '<leader>ed', function()
  local exclude_dirs = {
    '.git', '.cache', 'node_modules', '.venv', 'venv',
    'target', 'build', 'dist', '.mozilla',
    '.cargo', '.rustup', '.npm', '.nvm'
  }

  local fd_cmd = { 'fd', '.', home_dir, '--type', 'd', '--hidden', '--follow', '--max-depth', '4' }
  for _, d in ipairs(exclude_dirs) do
    table.insert(fd_cmd, '--exclude'); table.insert(fd_cmd, d)
  end

  -- Forzar listado con fd para recorrer todos los directorios (zoxide solo muestra visitados)
  local has_fd = vim.fn.executable('fd') == 1
  
  if has_fd then
    -- Obtener directorios con fd
    local dirs = vim.fn.systemlist(table.concat(fd_cmd, ' '))
    if vim.v.shell_error ~= 0 or #dirs == 0 then 
      vim.notify('No se encontraron directorios', vim.log.levels.WARN)
      return 
    end
    
    -- Usar vim.ui.select con ventana y visualización mejoradas
    -- Configurar ventana más grande a través de vim.ui.select
    local orig_select = vim.ui.select
    vim.ui.select = function(items, opts, on_choice)
      -- Mejorar opts para ventana más grande
      opts = opts or {}
      opts.telescope = opts.telescope or {}
      -- Layout apilado: lista arriba, vista previa de ancho completo abajo
      opts.telescope.layout_strategy = 'vertical'
      opts.telescope.layout_config = {
        width = 0.99,
        height = 0.90,
        preview_height = 0.55,
        prompt_position = 'top',
      }
      return orig_select(items, opts, on_choice)
    end
    
    -- Crear lista de directorios mejorada
    local enhanced_dirs = {}
    for _, dir in ipairs(dirs) do
      local rel_path = vim.fn.fnamemodify(dir, ':~')
      local display_name = rel_path:gsub('^~/', '')
      local parts = vim.split(display_name, '/')
      local short_name = display_name
      if #parts > 2 then
        short_name = parts[1] .. '/.../' .. parts[#parts]
      end
      table.insert(enhanced_dirs, dir)
    end
    
    vim.ui.select(enhanced_dirs, { 
      prompt = 'Selecciona un directorio para abrir en un nuevo Neovim (📁):',
      format_item = function(item)
        local rel_path = vim.fn.fnamemodify(item, ':~')
        local display_name = rel_path:gsub('^~/', '')
        local parts = vim.split(display_name, '/')
        local short_name = display_name
        if #parts > 2 then
          short_name = parts[1] .. '/.../' .. parts[#parts]
        end
        -- Entrada de dos líneas: nombre arriba, ruta abajo (indentada)
        local name_line = '📁 ' .. short_name
        local path_line = '   ' .. rel_path
        return name_line .. '\n' .. path_line
      end
    }, function(selected)
      -- Restaurar vim.ui.select original
      vim.ui.select = orig_select
      
      if selected then
        -- Ofrecer varias formas de abrir el directorio
        local options = {
          '🚀 Nueva instancia de Neovim',
          '📦 Nueva sesión tmux + Neovim',
          '🖥️  Terminal en el directorio',
          '📂 Este Neovim (cambiar cwd)',
        }
        
        vim.ui.select(options, {
          prompt = '¿Cómo abrir ' .. vim.fn.fnamemodify(selected, ':~') .. '?',
        }, function(choice)
          if not choice then return end
          
          local dir_name = vim.fn.fnamemodify(selected, ':t') -- nombre base
          local session_name = 'nvim_' .. dir_name:gsub('[^%w]', '_')
          
          if choice:match('Nueva instancia de Neovim') or choice:match('New Neovim') then
            -- Abrir nueva ventana de terminal con Neovim dentro
            local terminal = os.getenv('TERMINAL') or 'alacritty'
            local cmd = string.format("%s --working-directory '%s' -e nvim .", terminal, selected)
            vim.fn.jobstart(cmd, { detach = true })
            
          elseif choice:match('tmux session') or choice:match('sesión tmux') then
            -- Crear nueva sesión tmux con nvim
            local tmux_cmd = string.format(
              "tmux new-session -d -s '%s' -c '%s' 'nvim .'",
              session_name, selected
            )
            vim.fn.system(tmux_cmd)
            
            -- Abrir terminal y adjuntar a la sesión
            local terminal = os.getenv('TERMINAL') or 'alacritty'
            local attach_cmd = string.format(
              "%s -e tmux attach-session -t '%s'",
              terminal, session_name
            )
            vim.fn.jobstart(attach_cmd, { detach = true })
            vim.notify('Sesión tmux creada: ' .. session_name)
            
          elseif choice:match('Terminal en') or choice:match('Terminal in') then
            -- Abrir terminal en el directorio
            local terminal = os.getenv('TERMINAL') or 'alacritty'
            vim.fn.jobstart({ terminal, '--working-directory', selected }, { detach = true })
            
          elseif choice:match('Este Neovim') or choice:match('This Neovim') then
            -- Cambiar directorio en la instancia actual de Neovim
            vim.cmd('tcd ' .. vim.fn.fnameescape(selected))
            vim.notify('Directorio cambiado a: ' .. vim.fn.fnamemodify(selected, ':~'))
          end
        end)
      end
    end)
  else
    vim.notify('fd no encontrado. Instala fd para el listado de directorios.', vim.log.levels.ERROR)
  end
end, { desc = 'Home Dirs -> new Neovim' })

--   if config.add_default_keybindings then
--     local function add_keymap(keys, cmd, desc)
--         vim.api.nvim_set_keymap('n', keys, cmd, { noremap = true, silent = true, desc = desc })
--     end

--     add_keymap('<leader>,', ':PickMe buffers<cr>', 'Buffers')
--     add_keymap('<leader>/', ':PickMe search_history<cr>', 'Search History')
--     add_keymap('<leader>:', ':PickMe command_history<cr>', 'Command History')
--     add_keymap('<leader><space>', ':PickMe files<cr>', 'Files')
--     add_keymap('<C-f>', ':PickMe files<cr>', 'Files')

--     add_keymap('<leader>fa', ':PickMe files<cr>', 'Find Files')
--     add_keymap('<leader>fb', ':PickMe buffers<cr>', 'Buffers')
--     add_keymap('<leader>fc', ':PickMe git_log_file<cr>', 'File Commits')
--     add_keymap('<leader>fd', ':PickMe projects<cr>', 'Project Dirs')
--     add_keymap('<leader>ff', ':PickMe git_files<cr>', 'Find Git Files')
--     add_keymap('<leader>fg', ':PickMe live_grep<cr>', 'Grep')
--     add_keymap('<leader>fl', ':PickMe loclist<cr>', 'Location List')
--     add_keymap('<leader>fm', ':PickMe git_status<cr>', 'Modified Files')
--     add_keymap('<leader>fo', ':PickMe grep_buffers<cr>', 'Grep Open Buffers')
--     add_keymap('<leader>fp', ':PickMe resume<cr>', 'Previous Picker')
--     add_keymap('<leader>fq', ':PickMe quickfix<cr>', 'Quickfix List')
--     add_keymap('<leader>fr', ':PickMe oldfiles<cr>', 'Recent Files')
--     add_keymap('<leader>fs', ':PickMe buffer_grep<cr>', 'Buffer Lines')
--     add_keymap('<leader>ft', ':PickMe pickers<cr>', 'All Pickers')
--     add_keymap('<leader>fu', ':PickMe undo<cr>', 'Undo History')
--     add_keymap('<leader>fw', ':PickMe grep_string<cr>', 'Word Grep')
--     add_keymap('<leader>fz', ':PickMe zoxide<cr>', 'Zoxide')

--     add_keymap('<leader>gL', ':PickMe git_log<cr>', 'Git Log')
--     add_keymap('<leader>gS', ':PickMe git_stash<cr>', 'Git Stash')
--     add_keymap('<leader>gc', ':PickMe git_commits<cr>', 'Git Commits')
--     add_keymap('<leader>gl', ':PickMe git_log_line<cr>', 'Git Log Line')
--     add_keymap('<leader>gs', ':PickMe git_branches<cr>', 'Git Branches')

--     add_keymap('<leader>ii', ':PickMe icons<cr>', 'Icons')
--     add_keymap('<leader>ir', ':PickMe registers<cr>', 'Registers')
--     add_keymap('<leader>is', ':PickMe spell_suggest<cr>', 'Spell Suggestions')
--     add_keymap('<leader>iv', ':PickMe cliphist<cr>', 'Clipboard')

--     add_keymap('<leader>lD', ':PickMe lsp_declarations<cr>', 'LSP Declarations')
--     add_keymap('<leader>lF', ':PickMe lsp_references<cr>', 'References')
--     add_keymap('<leader>lL', ':PickMe diagnostics<cr>', 'Diagnostics')
--     add_keymap('<leader>lS', ':PickMe lsp_workspace_symbols<cr>', 'Workspace Symbols')
--     add_keymap('<leader>ld', ':PickMe lsp_definitions<cr>', 'LSP Definitions')
--     add_keymap('<leader>li', ':PickMe lsp_implementations<cr>', 'LSP Implementations')
--     add_keymap('<leader>ll', ':PickMe diagnostics_buffer<cr>', 'Buffer Diagnostics')
--     add_keymap('<leader>ls', ':PickMe lsp_document_symbols<cr>', 'Document Symbols')
--     add_keymap('<leader>lt', ':PickMe lsp_type_definitions<cr>', 'Type Definitions')

--     add_keymap('<leader>oC', ':PickMe colorschemes<cr>', 'Colorschemes')
--     add_keymap('<leader>oa', ':PickMe autocmds<cr>', 'Autocmds')
--     add_keymap('<leader>oc', ':PickMe command_history<cr>', 'Command History')
--     add_keymap('<leader>od', ':PickMe help<cr>', 'Docs')
--     add_keymap('<leader>of', ':PickMe marks<cr>', 'Marks')
--     add_keymap('<leader>og', ':PickMe commands<cr>', 'Commands')
--     add_keymap('<leader>oh', ':PickMe highlights<cr>', 'Highlights')
--     add_keymap('<leader>oj', ':PickMe jumplist<cr>', 'Jump List')
--     add_keymap('<leader>ok', ':PickMe keymaps<cr>', 'Keymaps')
--     add_keymap('<leader>ol', ':PickMe lazy<cr>', 'Search for Plugin Spec')
--     add_keymap('<leader>om', ':PickMe man<cr>', 'Man Pages')
--     add_keymap('<leader>on', ':PickMe notifications<cr>', 'Notifications')
--     add_keymap('<leader>oo', ':PickMe options<cr>', 'Options')
--     add_keymap('<leader>os', ':PickMe search_history<cr>', 'Search History')
--     add_keymap('<leader>ot', ':PickMe treesitter<cr>', 'Treesitter Find')

--     add_keymap(
--         '<leader>ecc',
--         ':lua require("pickme").pick("files", { cwd = vim.fn.stdpath("config"), title = "Neovim Configs" })<cr>',
--         'Neovim Configs'
--     )
--     add_keymap(
--         '<leader>ecP',
--         ':lua require("pickme").pick("files", { cwd = vim.fn.stdpath("data") .. "/lazy", title = "Plugin Files" })<cr>',
--         'Neovim Plugins'
--     )
--     add_keymap(
--         '<leader>ecL',
--         ':lua require("pickme").pick("files", { cwd = vim.fn.stdpath("state"), title = "Log Files" })<cr>',
--         'Neovim Logs'
--     )
-- end


-- ╔═════════════════════════════════════════════════════╗
-- ║                                                     ║
-- ║              Roberto Flores - Nvim                  ║
-- ║                                                     ║
-- ╚═════════════════════════════════════════════════════╝

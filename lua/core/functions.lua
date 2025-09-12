-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ functions.lua: Funciones y comandos personalizadas para Neovim       ║
-- ║ invocado desde 'init.lua'                                            ║
-- ║                                                                      ║
-- ║ Este archivo define funciones Lua y comandos de usuario que mejoran  ║
-- ║ la experiencia, facilitando tareas comunes como recargar la config,  ║
-- ║ copiar rutas de archivos al portapapeles y navegar directorios raíz. ║
-- ║                                                                      ║
-- ║ Modifica o añade funciones aquí según tus necesidades para optimizar ║
-- ║ tu flujo de trabajo con Neovim.                                      ║
-- ╚══════════════════════════════════════════════════════════════════════╝

-- Comando para recargar la configuración completa de Neovim sin reiniciar
vim.api.nvim_create_user_command('ReloadConfig', function()
    -- Limpia todos los módulos cargados que empiecen con "plugins"
    for name, _ in pairs(package.loaded) do
      if name:match('^plugins') then
        package.loaded[name] = nil
      end
    end
    -- Vuelve a ejecutar el archivo init.lua principal
    dofile(vim.env.MYVIMRC)
    vim.notify('Configuración de Nvim recargada correctamente!', vim.log.levels.INFO)
  end, {})
  
  -- Función auxiliar para copiar contenido al portapapeles con notificación
  local function copy_to_clipboard(content)
    vim.fn.setreg('+', content) -- Registra contenido en portapapeles + (sistema)
    vim.notify('Copiado al portapapeles: "' .. content .. '"', vim.log.levels.INFO)
  end
  
    -- Función auxiliar para copiar contenido al portapapeles con notificación
    local function copy_to_clipboard(content)
      vim.fn.setreg('+', content) -- Registra contenido en portapapeles + (sistema)
      vim.notify('Copiado al portapapeles: "' .. content .. '"', vim.log.levels.INFO)
    end
  
    -- Comando: Copiar ruta relativa del archivo actual
    vim.api.nvim_create_user_command('CopyRelativePath', function()
      local path = vim.fn.expand('%:.')
      copy_to_clipboard(path, 'Copiado "' .. path .. '" al portapapeles!')
    end, {})
  
    -- Comando: Copiar ruta absoluta del archivo actual
    vim.api.nvim_create_user_command('CopyAbsolutePath', function()
      local path = vim.fn.expand('%:p')
      copy_to_clipboard(path, 'Copiado  "' .. path .. '" al portapapeles!')
    end, {})
  
    -- Comando: Copiar ruta relativa con línea actual (formato: ruta:línea)
    vim.api.nvim_create_user_command('CopyRelativePathWithLine', function()
      local path = vim.fn.expand('%:.')
      local line = vim.fn.line('.')
      local result = path .. ':' .. line
      copy_to_clipboard(result, 'Copiado "' .. result .. '" al portapapeles!')
    end, {})

    -- Comando: Copiar ruta absoluta con línea actual (formato: ruta:línea)
    vim.api.nvim_create_user_command('CopyAbsolutePathWithLine', function()
      local path = vim.fn.expand('%:p')
      local line = vim.fn.line('.')
      local result = path .. ':' .. line
      copy_to_clipboard(result, 'Copiado "' .. result .. '" al portapapeles!')
    end, {})
  
  -- Comando: Copiar solo el nombre del archivo actual
  vim.api.nvim_create_user_command('CopyFileName', function()
    local filename = vim.fn.expand('%:t') -- Solo el nombre del archivo
    copy_to_clipboard(filename)
  end, {})
  
  -- Comando para cambiar el directorio de trabajo a la raíz Git o al directorio padre del archivo
  vim.api.nvim_create_user_command('RootDir', function()
    -- Requiere función para obtener directorio raíz (debe estar definido en 'lib.util')
    local root = require('lib.util').get_root_dir()
    if root == '' or not root then
      -- Si no encuentra raíz válida, no cambia directorio
      return
    end
    vim.cmd('lcd ' .. root) -- Cambia solo el directorio local para la ventana actual
    vim.notify('Directorio cambiado a raíz del proyecto:\n' .. root, vim.log.levels.INFO)
  end, {})
  
-- ╔═════════════════════════════════════════════════════╗
-- ║                                                     ║
-- ║              Roberto Flores - Nvim                  ║
-- ║                                                     ║
-- ╚═════════════════════════════════════════════════════╝

  

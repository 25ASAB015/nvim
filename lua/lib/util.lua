-- ╔════════════════════════════════════════════════════════════════════════════════════╗
-- ║ util.lua: Funciones utilitarias generales para Neovim                              ║
-- ║ Este archivo centraliza utilidades reutilizables en la configuración de Neovim.    ║
-- ║                                                                                    ║
-- ║ Aquí se agrupan y documentan funciones auxiliares como obtención de rutas,         ║
-- ║ detección de configuración de usuario, manipulación de buffers, y lógica común.    ║
-- ║ Esto permite mantener el código DRY y facilita la extensión de funcionalidades.    ║
-- ║                                                                                    ║
-- ╚════════════════════════════════════════════════════════════════════════════════════╝

local util = {}

-- Obtiene una configuración personalizada del usuario, o retorna un valor por defecto si no existe
util.get_user_config = function(key, default)
    local status_ok, user = pcall(require, 'user') -- Intenta cargar el módulo 'user'
    if not status_ok then
        return default -- Si falla, retorna el valor por defecto
    end

    local user_config = user[key] -- Busca la clave en la configuración del usuario
    if user_config == nil then
        return default -- Si no existe, retorna el valor por defecto
    end
    return user_config -- Retorna el valor encontrado
end

-- Obtiene el directorio raíz del proyecto (usando git si está disponible)
util.get_root_dir = function()
    local bufname = vim.fn.expand('%:p') -- Obtiene la ruta absoluta del buffer actual
    if vim.fn.filereadable(bufname) == 0 then
        return -- Si el archivo no es legible, retorna nil
    end

    local parent = vim.fn.fnamemodify(bufname, ':h') -- Obtiene el directorio padre
    local git_root = vim.fn.systemlist('git -C ' .. parent .. ' rev-parse --show-toplevel') -- Busca la raíz de git
    if #git_root > 0 and git_root[1] ~= '' then
        return git_root[1] -- Si existe, retorna la raíz de git
    else
        return parent -- Si no, retorna el directorio padre
    end
end

-- Obtiene la ruta del archivo actual, o el directorio, o el cwd si no hay archivo
util.get_file_path = function()
    local buf_name = vim.api.nvim_buf_get_name(0) -- Nombre del buffer actual
    if vim.fn.filereadable(buf_name) == 1 then
        return buf_name -- Si es un archivo legible, retorna la ruta
    end

    local dir_name = vim.fn.fnamemodify(buf_name, ':p:h') -- Obtiene el directorio del buffer
    if vim.fn.isdirectory(dir_name) == 1 then
        return dir_name -- Si es un directorio, retorna la ruta
    end

    return vim.loop.cwd() -- Si no, retorna el directorio de trabajo actual
end

-- Retorna un comando para establecer el filetype según la extensión y archivos presentes en el root
util.get_file_type_cmd = function(extension)
    local root = util.get_root_dir() -- Obtiene el root del proyecto

    if extension == 'arb' and root then
        local gemfile_exists = vim.fn.filereadable(root .. '/Gemfile') == 1 -- Verifica si existe Gemfile
        local pubspec_exists = vim.fn.filereadable(root .. '/pubspec.yaml') == 1 -- Verifica si existe pubspec.yaml
        if gemfile_exists then
            return 'setfiletype ruby' -- Si hay Gemfile, es ruby
        end
        if pubspec_exists then
            return 'setfiletype json' -- Si hay pubspec.yaml, es json
        end
    end
    return '' -- Si no cumple condiciones, retorna cadena vacía
end

-- Verifica si un binario está presente en el sistema
util.is_present = function(bin)
    return vim.fn.executable(bin) == 1 -- Retorna true si el binario es ejecutable
end

return util


-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║                                                                      ║
-- ║              Roberto Flores - Nvim                                   ║
-- ║                                                                      ║
-- ╚══════════════════════════════════════════════════════════════════════╝
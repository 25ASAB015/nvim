-- ╔════════════════════════════════════════════════════════════════════════════════════╗
-- ║ prompts.lua: Definición centralizada de prompts para asistentes de IA en Neovim    ║
-- ║ Este archivo es utilizado para almacenar y gestionar prompts reutilizables,        ║
-- ║ facilitando su inserción en flujos de trabajo de desarrollo asistido por IA.       ║
-- ║                                                                                    ║
-- ║ Aquí se agrupan y documentan los prompts principales, como generación de           ║
-- ║ documentación, explicación de código, optimización, revisión, pruebas, etc.        ║
-- ║ Esto permite mantener consistencia y rapidez al interactuar con herramientas       ║
-- ║ de IA, así como personalizar o ampliar los prompts según las necesidades.          ║
-- ║                                                                                    ║
-- ║ Modifica este archivo para ajustar o añadir comportamientos automáticos según      ║
-- ║ tus necesidades y preferencias personales.                                         ║
-- ╚════════════════════════════════════════════════════════════════════════════════════╝

-- Tabla de prompts predefinidos para IA
local prompts = {
    docs = 'Generate comprehensive documentation for this code including parameters, return values, and usage examples.',
    explain = 'Explain this code in detail, including its purpose, logic flow, and any algorithms used.',
    fix = 'Identify and fix any bugs, errors, or code smells in this code.',
    commit = 'Create a descriptive commit message following conventional commits format for these changes.',
    optimize = 'Optimize this code for better performance, readability, and maintainability.',
    review = 'Review this code for best practices, potential issues, and suggest improvements.',
    tests = 'Write comprehensive unit tests covering all edge cases for this code.',
}

---Retorna una función que inserta el prompt nombrado en la posición del cursor
---@param prompt_name string Nombre del prompt a insertar
---@return function Función para ejecutar en un keybinding
prompts.add_prompt = function(prompt_name)
    local prompt_text = prompts[prompt_name] -- Obtiene el texto del prompt
    return function()
        -- Inserta el prompt en el buffer actual, escapando comillas simples
        vim.cmd("put ='" .. prompt_text:gsub("'", "''") .. "'")
    end
end

return prompts

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║                                                                      ║
-- ║              Roberto Flores - Nvim                                   ║
-- ║                                                                      ║
-- ╚══════════════════════════════════════════════════════════════════════╝

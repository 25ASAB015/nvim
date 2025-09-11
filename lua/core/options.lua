-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║ options.lua: Configuración central de opciones de Neovim             ║
-- ║ Este archivo es invocado desde 'init.lua'                            ║
-- ║                                                                      ║
-- ║ Este archivo define y documenta las opciones principales de Neovim,  ║
-- ║ permitiendo personalizar el comportamiento, la experiencia de        ║
-- ║ edición y la integración con herramientas modernas. Aquí se          ║
-- ║ establecen valores predeterminados para aspectos como indentación,   ║
-- ║ portapapeles, codificación, autoguardado, y más, adaptando Neovim    ║
-- ║ a un flujo de trabajo eficiente y actual.                            ║
-- ║                                                                      ║
-- ╚══════════════════════════════════════════════════════════════════════╝

local options = {
    -- Habilita Neovim AI si la integración está disponible (experimental)
    ai = true,

    -- Indentado inteligente basado en el contexto del código
    autoindent = true,
    smartindent = true,           -- Ajuste de indentación para la siguiente línea
    smarttab = true,              -- Tab en el inicio de línea respeta 'shiftwidth'
    si = true,                    -- Compatibilidad con versiones antiguas de Vim

    -- Escritura automática al salir de buffers y movimientos
    autowrite = true,

    -- Control refinado sobre backspace (permite borrar indentaciones, saltos de línea, inicios)
    backspace = 'indent,eol,start',

    -- Deshabilita archivos temporales de backup para evitar archivos residuales
    backup = false,
    swapfile = false,             -- Sin archivos swap
    writebackup = false,          -- Sin backups al sobreescribir

    -- Indentado visual coherente aun en líneas largas
    breakindent = true,

    -- Permite copiar/pegar entre Neovim y el portapapeles del sistema
    clipboard = 'unnamedplus',

    -- Altura de la línea de comandos para mostrar mensajes sin saturar la UI
    cmdheight = 1,

    -- Opciones de autocompletado (importante para plugins como nvim-cmp)
    completeopt = 'menu,menuone,noselect',

    -- Controla el nivel de ocultamiento de texto (útil para Markdown)
    conceallevel = 0,

    -- Solicita confirmación al salir de buffers modificados
    confirm = true,

    -- Resalta la línea actual para fácil referencia visual
    cursorline = true,

    -- Convierte tabs en espacios; evita mezclar formatos de identado
    expandtab = true,

    -- Codificación por defecto para archivos nuevos
    fileencoding = 'utf-8',

    -- Opciones de formateo (ver ":h fo-table" para detalles)
    formatoptions = 'jlnqt',

    -- Salida de grep formateada para integración con el quickfix list
    grepformat = '%f:%l:%c:%m',
    grepprg = 'rg --vimgrep',     -- Usa ripgrep como motor de búsqueda (mucho más rápido)

    -- Resalta todas las ocurrencias al buscar
    hlsearch = true,

    -- Búsqueda insensible a mayúsculas/minúsculas, pero sensible si incluyes mayúsculas
    ignorecase = true,
    smartcase = true,

    -- Vista previa del reemplazo incremental
    inccommand = 'split',

    -- Siempre muestra la barra de estado (tabline)
    laststatus = 3,

    -- Muestra caracteres invisibles (tabs, espacios no separables)
    list = true,
    listchars = { trail = '', tab = '', nbsp = '_', extends = '>', precedes = '<' }, -- highlight
    
    -- Activa el uso del mouse en todas las ventanas y modos
    mouse = 'a',

    -- Números de línea absolutos y relativos (útil para movimientos rápidos)
    number = true,
    relativenumber = true,
    numberwidth = 4,              -- Ancho de columna para los números

    -- Pop-up blend para menús de autocompletado translúcidos
    pumblend = 10,
    pumheight = 10,               -- Altura máxima del menú emergente

    -- El scroll nunca deja menos de X líneas de margen respecto al cursor
    scrolloff = 10,
    sidescrolloff = 8,

    -- Sesión guarda más información al restaurar el entorno
    sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal',

    -- Ajusta indentado a múltiplos de shiftwidth al hacer << y >>
    shiftround = true,
    shiftwidth = 4,               -- Número de espacios por nivel de indentación

    -- Menos mensajes superfluos en el modo comando
    showcmd = false,
    showmode = false,             -- Oculta el estado como "-- INSERT --"

    -- Control de visualización de la línea de tabs
    showtabline = 0,

    -- Siempre muestra la columna de signos (por ejemplo para Git/LSP)
    signcolumn = 'yes',

    -- División automática de ventana: abajo/derecha por defecto
    splitbelow = true,            -- Horizontal 
    splitright = true,            -- Vertical

    -- Número mínimo de columnas por ventana
    winminwidth = 5,

    -- Desactiva el wrapping de líneas largas: útil para código
    wrap = false,

    -- Persistencia de deshacer/write-undo sin perder historial
    undofile = true,
    undodir = vim.fn.stdpath('cache') .. '/undo',
    undolevels = 10000,

    -- Tiempo entre updates de eventos (reduce latencia de plugins y LSP)
    updatetime = 50,              -- Predeterminado 4000ms

    -- Menú de comandos más inteligente e interactivo
    wildmenu = true,
    wildmode = 'longest:full,full',

    -- Duración máxima para combinaciones de teclas mapeadas (ideal para atajos custom)
    timeoutlen = 300,

    -- Muestra el título de la ventana
    title = true,

    -- Insert 2 spaces for a tab
    tabstop = 4, -- insert 2 spaces for a tab
    termguicolors = true, -- set term gui colors (most terminals support this)
    
}

-- Aplica cada opción definida arriba usando la tabla 'options'
for k, v in pairs(options) do
    vim.opt[k] = v
end

-- ════════════════════════════════
--       CONFIGURACIONES EXTRA
-- ════════════════════════════════

-- Netrw: Explorar archivos integrado mejorado
vim.g.netrw_winsize = 20     -- Tamaño del panel lateral
vim.g.netrw_banner = 0       -- Oculta la cabecera de ayuda
vim.g.netrw_liststyle = 1    -- Vista tipo lista (más minimalista)

-- Deshabilita recomendaciones restrictivas en archivos Markdown
vim.g.markdown_recommended_style = 0

-- Permite búsqueda recursiva en subdirectorios con :find (para proyectos grandes)
vim.opt.path:append({ '**' })

-- Reduce cantidad de mensajes innecesarios en la UI
vim.opt.shortmess:append({ W = true, I = true, c = true })

-- Oculta el símbolo "~" al final del buffer vacío para una UI más limpia
vim.cmd([[set fillchars+=eob:\ ]])

-- Configuraciones específicas por tipo de archivo y entorno
vim.cmd([[
    setlocal spell spelllang=en,es " Define idioma para el spellcheck (Inglés)
    setlocal spell!                " Desactiva spellcheck por defecto, se puede activar bajo demanda

    filetype plugin indent on      " Detecta tipo de archivo, activa plugins e indentación automática

    " Soporte para integración de Python en Windows
    if has('win32')
        let g:python3_host_prog = $HOME . '/scoop/apps/python/current/python.exe'
    endif

    " Habilita el subrayado tipo 'undercurl' (útil para diagnostics del LSP)
    let &t_Cs = "\e[4:3m"
    let &t_Ce = "\e[4:0m"

    " Permite saltar líneas con h/l y mover entre líneas usando <, >, [, ]
    set whichwrap+=<,>,[,],h,l

    " Considera el guion (-) como parte de las palabras (práctico para identificadores de JS/TS)
    set iskeyword+=-
]])

-- ╔═════════════════════════════════════════════════════╗
-- ║                                                     ║
-- ║              Roberto Flores - Nvim                  ║
-- ║                                                     ║
-- ╚═════════════════════════════════════════════════════╝



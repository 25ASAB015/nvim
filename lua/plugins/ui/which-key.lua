local which_key = require('which-key')
local icons = require('lib.icons')
local util = require('lib.util')
local prompts = require('lib.prompts')

local setup = {
    preset = 'modern',
    plugins = {
        marks = true,
        registers = true,
        spelling = {
            enabled = true,
            suggestions = 30,
        },
        presets = {
            operators = true,
            motions = true,
            text_objects = true,
            windows = true,
            nav = true,
            z = true,
            g = true,
        },
    },
    icons = {
        breadcrumb = icons.ui.ArrowOpen,
        separator = icons.ui.Arrow,
        group = '',
        keys = {
            Space = icons.ui.Rocket,
        },
        rules = false, -- enable auto icon rules
    },
    win = {
        no_overlap = true,
        border = 'rounded',
        width = 0.8,
        height = { min = 5, max = 25 },
        padding = { 1, 2 },
        title = true,
        title_pos = 'center',
        zindex = 1000,
        wo = {
            winblend = 10,
        },
    },
    layout = {
        width = { min = 20 },
        spacing = 6,
        align = 'center',
    },
    show_help = false,
    show_keys = true,
    triggers = {
        { '<auto>', mode = 'nvisoct' },
        { '<leader>', mode = { 'n', 'v' } },
    },
}

local normal_mappings = {
    mode = 'n',
    { '<leader>x', ':x<cr>', desc = ' Save and Quit' },

    { '<leader>a', group = ' AI' },

    { '<leader>c', group = ' Code' },

    { '<leader>e', group = ' Edit' },

    { '<leader>f', group = ' Find' },

    { '<leader>g', group = ' Git' },

    { '<leader>i', group = ' Insert' },

    { '<leader>j', group = ' Jump' },

    { '<leader>l', group = ' LSP' },

    { '<leader>m', group = ' Marks' },

    { '<leader>n', group = ' Notes' },

    { '<leader>o', group = ' Options' },

    { '<leader>p', group = ' Packages' },

    { '<leader>q', group = ' Quit' },
    { '<leader>qa', ':qall<cr>', desc = 'Quit All' },
    { '<leader>qb', ':bw<cr>', desc = 'Close Buffer' },
    { '<leader>qd', ':lua require("snacks").bufdelete()<cr>', desc = 'Delete Buffer' },
    { '<leader>qf', ':qall!<cr>', desc = 'Force Quit' },
    { '<leader>qo', ':%bdelete|b#|bdelete#<cr>', desc = 'Close Others' },
    { '<leader>qq', ':q<cr>', desc = 'Quit' },
    { '<leader>qs', '<C-w>c', desc = 'Close Split' },
    { '<leader>qw', ':wq<cr>', desc = 'Write and Quit' },

    { '<leader>r', group = ' Refactor' },

    { '<leader>s', group = ' Split' },

    { '<leader>t', group = ' Terminal' },
    { '<leader>t`', ':Sterm<cr>', desc = 'Horizontal Terminal' },
    { '<leader>tc', ':Sterm bundle exec rails console<cr>', desc = 'Rails Console' },
    { '<leader>td', ':Sterm dexe<cr>', desc = 'Exe Launcher' },
    { '<leader>tn', ':Sterm node<cr>', desc = 'Node' },
    { '<leader>tp', ':Sterm bpython<cr>', desc = 'Python' },
    { '<leader>tr', ':Sterm irb<cr>', desc = 'Ruby' },
    { '<leader>ts', ':Sterm<cr>', desc = 'Horizontal Terminal' },
    { '<leader>tt', ':Fterm<cr>', desc = 'Terminal' },
    { '<leader>tv', ':Vterm<cr>', desc = 'Vertical Terminal' },
    { '<leader>tw', ':Sterm dexe --wait-before-exit<cr>', desc = 'Exe Launcher, Wait' },

    { '<leader>w', group = ' Writing' },

    { '<leader>y', group = ' Yank' },
    { '<leader>yL', ':CopyAbsolutePathWithLine<cr>', desc = 'Absolute Path with Line' },
    { '<leader>yP', ':CopyAbsolutePath<cr>', desc = 'Absolute Path' },
    { '<leader>ya', ':%y+<cr>', desc = 'Copy Whole File' },
    { '<leader>yf', ':CopyFileName<cr>', desc = 'File Name' },
    { '<leader>yg', ':lua require"gitlinker".get_buf_range_url()<cr>', desc = 'Copy Git URL' },
    { '<leader>yl', ':CopyRelativePathWithLine<cr>', desc = 'Relative Path with Line' },
    { '<leader>yp', ':CopyRelativePath<cr>', desc = 'Relative Path' },
}

-- Numerical mappings
for i = 1, 9 do
    table.insert(normal_mappings, {
        string.format('<leader>f%d', i),
        string.format(':LualineBuffersJump%d<cr>', i),
        desc = string.format('File %d', i),
    })
end

local visual_mappings = {
    mode = 'v',
    { '<leader>a', group = ' AI' },

    { '<leader>c', group = ' Code' },
 
    { '<leader>g', group = ' Git' },
 
    { '<leader>j', group = ' Jump' },
 
    { '<leader>l', group = ' LSP' },
 

    { '<leader>y', group = ' Yank' },
    { '<leader>yg', ':lua require"gitlinker".get_buf_range_url("v")<cr>', desc = 'Copy Git URL' },
}

local no_leader_mappings = {
    mode = 'n',

}

which_key.setup(setup)
which_key.add(normal_mappings)
which_key.add(visual_mappings)
which_key.add(no_leader_mappings)

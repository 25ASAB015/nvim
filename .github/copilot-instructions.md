# Neovim Personal Configuration (Roberto Flores)

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

This is a personal Neovim configuration written in Lua, featuring modern plugin management with Lazy.nvim, automated keybinding documentation, and a modular architecture optimized for development workflows.

## Working Effectively

### Bootstrap and Dependencies  
- Install Neovim: `sudo apt update && sudo apt install -y neovim` -- takes 2-3 minutes. Set timeout to 5+ minutes.
- Verify Neovim version: `nvim --version` -- should show v0.9.5 or higher
- Install Python for scripts: `sudo apt install -y python3` -- takes 1-2 minutes. Set timeout to 3+ minutes.
- Install Stylua for Lua formatting (optional): `cargo install stylua` -- takes 60-90 seconds. NEVER CANCEL. Set timeout to 3+ minutes.

### CRITICAL: Configuration Setup  
- **REQUIRED**: Create symlink for proper config loading: `mkdir -p ~/.config && ln -sf $PWD ~/.config/nvim`
- **REQUIRED**: Initial plugin installation happens automatically on first run -- takes 10-30 seconds. NEVER CANCEL.
- First run will download plugins (onedark.nvim theme) and may show spell check warnings (safe to ignore)

### Configuration Testing and Validation
- Test configuration loads: `timeout 30 nvim --headless -c "lua print('Configuration loaded successfully')" -c "qall"` -- takes 2-3 seconds
- Test custom commands: `timeout 30 nvim --headless -c "ReloadConfig" -c "qall"` -- should show "Configuración de Nvim recargada correctamente!"
- Run keybinding extraction: `python3 scripts/update_keybindings.py` -- takes 2-3 seconds, updates docs/keybindings.md
- Check Lua syntax: `stylua --check .` -- takes 3-5 seconds, may show formatting diffs but should not show syntax errors
- ALWAYS test in interactive mode after making changes: `nvim` then `:ReloadConfig` command

### Development Workflow
- Format Lua code: `stylua .` -- takes 3-5 seconds, applies formatting fixes
- Validate custom functions work: Open nvim interactively and test `:ReloadConfig`, `:CopyRelativePath`, `:RootDir`
- Update keybinding docs after changes: `python3 scripts/update_keybindings.py` -- auto-updates docs/keybindings.md
- ALWAYS run the keybinding script before committing changes to Lua files

## Validation Scenarios

After making changes to the configuration, ALWAYS complete these validation steps:

1. **Configuration Setup**: Ensure symlink exists: `mkdir -p ~/.config && ln -sf $PWD ~/.config/nvim`
2. **Configuration Load Test**: Run `nvim --headless -c "checkhealth" -c "qall"` to verify no errors
3. **Plugin Installation**: First run downloads plugins automatically (onedark.nvim) -- takes 10-30 seconds. NEVER CANCEL.
4. **Custom Commands Test**: Run `nvim --headless -c "ReloadConfig" -c "qall"` -- should show success message in Spanish
5. **Interactive Function Test**: Open `nvim`, test custom commands like `:CopyFileName`, `:CopyRelativePath` 
6. **Plugin Manager Test**: In nvim, run `:lua require('lazy').show()` to verify plugin manager loads correctly
7. **Keybinding Validation**: Test basic keybindings like `jj` (escape), `<Space>` (leader key), `gl`/`gh` (line navigation)
8. **Documentation Update**: Run `python3 scripts/update_keybindings.py` to ensure docs stay current

## Build and Test Commands

- **No traditional build process** - this is a configuration setup, not a compiled application
- Test configuration: `nvim --headless -c "checkhealth" -c "qall"` -- takes 2-3 seconds
- Format code: `stylua .` -- takes 3-5 seconds  
- Generate docs: `python3 scripts/update_keybindings.py` -- takes 2-3 seconds
- Syntax check: `stylua --check .` -- takes 3-5 seconds

## Key Project Components

### Core Configuration (lua/core/)
- `options.lua`: Neovim settings, UI behavior, editor preferences
- `keys.lua`: Key mappings and leader key bindings
- `functions.lua`: Custom user commands like ReloadConfig, path copying utilities
- `autocmd.lua`: Auto-commands for file types, formatting, spell check

### Plugin Management (lua/plugins/)
- `lazy.lua`: Lazy.nvim plugin manager configuration with custom keybindings
- `list.lua`: Central plugin list organized by category (UI, Editor, Language, AI, Tools)
- `ui/`: UI-specific plugin configurations (themes, visual elements)

### Utilities (lua/lib/)
- `util.lua`: Helper functions for file operations, git root detection
- `icons.lua`: Icon definitions for UI elements, diagnostics, git, LSP
- `prompts.lua`: AI prompts and templates

### Automation (scripts/ and .github/)
- `scripts/update_keybindings.py`: Extracts keybindings from Lua files, generates documentation
- `.github/workflows/update-keybindings.yml`: Auto-updates keybinding docs on code changes

## Important File Locations

### Configuration Entry Points
- `init.lua`: Main configuration entry point - loads all core modules
- `lua/core/options.lua`: Primary configuration settings (157 lines of documented options)
- `lua/plugins/lazy.lua`: Plugin manager setup and UI configuration

### Documentation
- `docs/keybindings.md`: Auto-generated keybinding reference (updated by Python script)
- `README.md`: Basic project description
- `.stylua.toml`: Lua formatting rules (120 char width, 4-space indent)

### Generated Files (DO NOT manually edit)
- `docs/keybindings.md`: Auto-generated by scripts/update_keybindings.py
- Plugin directories in `~/.local/share/nvim/` when nvim runs

## Configuration Behavior

### Plugin Loading
- Uses Lazy.nvim for lazy loading - plugins load on demand for faster startup
- OneDark theme loads immediately (priority 1000) to prevent UI flicker
- Plugin configurations are modular and stored in separate files

### Custom Commands Available
- `:ReloadConfig`: Reload nvim configuration without restarting
- `:CopyRelativePath`: Copy current file's relative path to clipboard  
- `:CopyAbsolutePath`: Copy current file's absolute path to clipboard
- `:CopyRelativePathWithLine`: Copy path:line format to clipboard
- `:CopyFileName`: Copy just the filename to clipboard
- `:RootDir`: Change working directory to git root

### Key Mappings Highlights
- Leader key: `<Space>`
- Quick escape: `jj` in insert mode, `JJ` in terminal mode
- Line navigation: `gl` (end), `gh` (beginning)
- Smart paste: `p` in visual mode (doesn't overwrite clipboard)
- Center cursor: `n`/`N` for search, `<C-d>`/`<C-u>` for scrolling

## Troubleshooting

### Common Issues
- **"Not an editor command" errors**: 
  - Custom commands only work in interactive mode, not headless
  - For Lazy plugin manager, use `:lua require('lazy').show()` instead of `:Lazy` if command not found
- **Configuration not loading**: Ensure symlink exists: `ln -sf $PWD ~/.config/nvim` 
- **Plugin not loading**: Check `:lua require('lazy').show()` interface, ensure internet connection for plugin downloads
- **Keybinding conflicts**: Review `docs/keybindings.md` for current mappings
- **Syntax errors in Lua**: Run `stylua --check .` to identify issues
- **Spell check warnings**: Safe to ignore "No writable spell directory" warnings on first run

### Validation Commands
- Configuration loads: `nvim --headless -c "checkhealth" -c "qall"`
- Check for Lua errors: `nvim --headless -c "luafile init.lua" -c "qall"`
- Test plugin manager: `nvim --headless -c "lua require('plugins.lazy')" -c "qall"`

### Performance Notes
- Configuration optimizes for fast startup with lazy loading
- Some plugins are disabled for performance (gzip, tar, zip plugins)
- Startup time typically under 100ms with proper lazy loading

## Making Changes

### Safe Editing Practices
- ALWAYS test configuration changes with `:ReloadConfig` in interactive nvim
- Run `python3 scripts/update_keybindings.py` after modifying keybindings  
- Use `stylua .` to maintain consistent code formatting
- Test custom functions interactively before committing

### File Modification Guidelines
- Core settings: Edit `lua/core/options.lua`
- Keybindings: Edit `lua/core/keys.lua` 
- Custom functions: Edit `lua/core/functions.lua`
- Plugin list: Edit `lua/plugins/list.lua`
- Never manually edit `docs/keybindings.md` - it's auto-generated

This configuration provides a modern, efficient Neovim setup optimized for development work with extensive customization and automation.
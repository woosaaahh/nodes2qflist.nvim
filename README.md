<!-- 
vim: expandtab tabstop=2 
-->

- [Requirements](#requirements)
- [Usage](#usage)
- [Configuration](#configuration)

## nodes2qflist

This plugin helps to search for Tree-Sitter nodes in a buffer and populate the quickfix
list with the result.

### Requirements

Only [Neovim 0.8+](https://github.com/neovim/neovim/releases) is required, nothing more.

### Usage

For this plugins you can use bundled queries from
`<this_plugin_dir>/queries/<filetype>/nodes2qflist.scm` or add your own queries in
`<nvim_config_dir>/queries/<filetype>/nodes2qflist.scm`.

Then you only need to assign `nodes2qflist.search()` to a keymap :

```lua
vim.keymap.set("n", "<leader>qf", function()
  -- "functions" is the capture name to use from the queries file (*.scm)
  -- "@functions" is also allowed
  require("nodes2qflist").search("functions")
end)
``` 

### Configuration

No configuration needed !

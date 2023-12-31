# nvim-traveller-buffer
Better management for buffers (using Telescope), great to use in combination with a project plugin like (project.nvim /
nvim-traveller.nvim)

https://github.com/Norlock/nvim-traveller-buffers/assets/7510943/fa4d6c12-7e49-43c4-9abc-ec49c6a32726

### Why use it?
- If you work with multiple projects, the buffer overview can get clogged up quickly using
the builtin buffer view, but with this plugin it won't.
- It integrates with harpoon, so you don't need to consciously stay on top of adding /
removing buffers from the list.
- Separates (project buffers / other buffers / term buffers)

## Features
- [x] Tabbing through types of buffer overview
- [x] Deleting buffers from the list
- [x] Sort based on last time used
- [x] Keep a maximum of buffers (20)
- [x] Add to/Remove from  harpoon list (optional)
- [x] Custom mapping options

## Install

#### Lazy
```lua
    { 'nvim-telescope/telescope.nvim',   tag = '0.1.2' },
    'ThePrimeagen/harpoon', -- optional
    'norlock/nvim-traveller-buffers',
```

#### Packer
```lua
use 'nvim-telescope/telescope.nvim', tag = '0.1.2', -- (or whatever version)
use 'ThePrimeagen/harpoon', -- optional
use 'norlock/nvim-traveller-buffers',
```

## Usage
```lua
vim.keymap.set('n', '<leader>b', require('nvim-traveller-buffers').buffers, {})
```

```viml
nnoremap <leader>b <cmd>lua require('nvim-traveller-buffers').buffers()<cr>
```

#### Change defaults (optional)
```lua
local traveller_buffers = require('nvim-traveller-buffers')

traveller_buffers.setup({
    mappings = {
        next_tab = "<Tab>",
        previous_tab = "<S-Tab>",
        harpoon_buffer = "<C-h>",
        delete_buffer = "<C-d>",
        preview_scrolling_up = "<C-b>",
        preview_scrolling_down = "<C-f>",
        delete_all = "<C-z>"
    }
})
```

#### Default keymapping
| Key       | Action                    |
|-----------|:-------------------------:|
| Tab       | Next overview             |
| S-Tab     | Previous overview         |
| C-d       | Delete buffer             |
| C-z       | Delete all (excl Harpoon) |
| C-h       | Toggle harpoon            |
| C-f       | Preview scroll down       |
| C-b       | Preview scroll up         |

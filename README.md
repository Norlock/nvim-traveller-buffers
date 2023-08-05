# nvim-traveller-buffer
Better management for buffers (using Telescope), great to use in combination with a project plugin like (project.nvim /
nvim-traveller.nvim)

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

## Install

#### Lazy
```lua
    { 'nvim-telescope/telescope.nvim',   tag = '0.1.2' },
    'ThePrimeagen/harpoon', -- optional
    'norlock/nvim-traveller-buffer',
```

#### Packer
```lua
use 'nvim-telescope/telescope.nvim', tag = '0.1.2', -- (or whatever version)
use 'ThePrimeagen/harpoon', -- optional
use 'norlock/nvim-traveller-buffer',
```

## Usage
```lua
vim.keymap.set('n', '<leader>b', require('nvim-traveller-buffers').buffers, {})
```

```viml
nnoremap <leader>b <cmd>lua require('nvim-traveller-buffers').buffers()<cr>
```

#### keymapping
| Key       | Action                 |
|-----------|:----------------------:|
| Tab       | Next overview          |
| S-Tab     | Previous overview      |
| C-d       | Delete buffer          |
| C-h       | Toggle harpoon         |
| C-f       | Preview scroll down    |
| C-b       | Preview scroll up      |

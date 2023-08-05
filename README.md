# nvim-traveller-buffer
Better management for buffers, recommended to use a project plugin like (project.nvim /
nvim-traveller.nvim)

### Why use it?
- If you work with multiple projects, your buffer overview can get clogged up quite quickly.
- It integrates with harpoon, so you don't need to consciously need to stay on top of adding /
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

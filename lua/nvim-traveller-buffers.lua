local ProjectBuffers = require("traveller-buffers.project-buffers")
local debug = require("traveller-buffers.debug")
local persist = require("traveller-buffers.persist-data")

local M = {}

local proj_buffers = ProjectBuffers:new();

function M.buffers()
    proj_buffers:open_telescope()
end

function M.setup(options)
    ProjectBuffers.set_options(options)
end

vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
        proj_buffers.root = proj_buffers.get_root();
        local buffers = proj_buffers:project_buffers();
        persist.persist_data(buffers, proj_buffers.root);
    end
})



return M

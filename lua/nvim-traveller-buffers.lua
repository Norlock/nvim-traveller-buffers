local ProjectBuffers = require("project-buffers")

local M = {}

function M.buffers()
    local proj_buffers = ProjectBuffers:new();
    proj_buffers:open_telescope()
end

function M.setup(options)
    ProjectBuffers.set_options(options)
end

return M

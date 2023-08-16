local M = {}
local path = vim.fn.stdpath('log') .. '/nvim-traveller-buffers.log'

function M.log(val, label)
    local filewrite = io.open(path, "a+")

    if filewrite == nil then
        print("Can't open debug file")
        return
    end

    if label ~= nil then
        filewrite:write("--" .. label .. "\n")
    end

    filewrite:write(vim.inspect(val) .. "\n\n")
    filewrite:close()
end

M.log("Opening Neovim " .. os.date('%Y-%m-%d %H:%M:%S'))

return M;

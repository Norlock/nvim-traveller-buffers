local debug = require("traveller-buffers.debug");

local M = {}

local data_path = vim.fn.stdpath('data') .. '/nvim-traveller-buffers.json'

local function retrieve_data()
    if vim.fn.filereadable(data_path) == 0 then
        local filewrite = io.open(data_path, "w")

        if filewrite == nil then
            debug.log("Can't write data")
            return {}
        end

        filewrite:write("[]") -- empty JSON array
        filewrite:close()
        return {}
    end

    local file_output = vim.fn.readfile(data_path)
    local json_str = ""

    for _, item in pairs(file_output) do
        json_str = json_str .. item
    end

    return vim.fn.json_decode(json_str)
end

local history = retrieve_data()

---Persists data
---@param buffers any
---@param root any
function M.persist_data(buffers, root)
    local data = history;

    local exist = false
    for _, item in pairs(data) do
        if item.root then
            item.buffers = buffers
            exist = true
        end
    end

    if not exist then
        table.insert(data, {
            root = root,
            buffers = buffers,
        })
    end

    local json = vim.fn.json_encode(data)
    local filewrite = io.open(data_path, "w+")

    if filewrite == nil then
        return
    end

    filewrite:write(json)
    filewrite:close()
end

---@param root string
---@return table
function M.last_used_buffers(root)
    for _, item in pairs(history) do
        if root == item.root then
            for _, buffer in pairs(item.buffers) do
                buffer.bufnr = vim.fn.bufadd(buffer.name)
            end

            return item.buffers;
        end
    end

    return {}
end

return M

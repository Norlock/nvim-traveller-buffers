local persist = require("traveller-buffers.persist-data")
local debug = require("traveller-buffers.debug")

local ProjectBuffers = {}
local max_buffers = 20
local _only_stderr = " > /dev/null"
local only_stdout = " 2> /dev/null"
local project_buffers_idx = 0
local other_buffers_idx = 1
local term_buffers_idx = 2

local options = {
    mappings = {
        next_tab = nil,
        previous_tab = nil,
        preview_scrolling_up = nil,
        preview_scrolling_down = nil,
        delete_buffer = nil,
    }
}

function ProjectBuffers:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self

    if package.loaded["telescope"] then
        ProjectBuffers.builtin = require("telescope.builtin")
        ProjectBuffers.pickers = require("telescope.pickers")
        ProjectBuffers.finders = require("telescope.finders")
        ProjectBuffers.config = require("telescope.config").values
        ProjectBuffers.actions = require("telescope.actions")
        ProjectBuffers.action_state = require("telescope.actions.state")
        ProjectBuffers.action_utils = require("telescope.actions.utils")
        ProjectBuffers.themes = require("telescope.themes")
        ProjectBuffers.previewers = require("telescope.previewers")
    end

    o.initialized = false

    return o
end

function ProjectBuffers.set_options(opt)
    options = opt
end

function ProjectBuffers:open_telescope()
    self.root = self.get_root()

    -- From term buffers show default
    if vim.startswith(self.root, "term://") then
        self.builtin.buffers()
        return
    end

    self.show_buffers_idx = project_buffers_idx

    local define_preview = function(this, entry, _)
        self.preview_win_id = this.state.winid
        local content = vim.api.nvim_buf_get_lines(entry.bufnr, 0, -1, false)
        vim.api.nvim_buf_set_lines(this.state.bufnr, 0, -1, true, content)

        self.previewers.buffer_previewer_maker(entry.value, this.state.bufnr, {
            callback = function()
                -- TODO fix cursor bug some time
            end,
        })
    end

    local function attach_mappings(prompt_buf_id, map)
        return self:attach_mappings(prompt_buf_id, map)
    end

    local opts = {}

    self.picker = self.pickers.new(opts, {
        prompt_title = "Project buffers (Tab / S-Tab)",
        finder = self:create_finder(self:project_buffers()),
        sorter = self.config.file_sorter(opts),
        previewer = self.previewers.new_buffer_previewer({
            define_preview = define_preview,
        }),
        attach_mappings = attach_mappings,
    });
    self.picker:find()
end

function ProjectBuffers:attach_mappings(prompt_buf_id, map)
    local actions = self.actions
    local action_state = self.action_state
    local mappings = options.mappings or {}

    map('i', mappings.preview_scrolling_up or "<C-b>", actions.preview_scrolling_up)
    map('i', mappings.preview_scrolling_down or "<C-f>", actions.preview_scrolling_down)
    map('i', "<C-u>", function() end)
    map('i', mappings.delete_buffer or "<C-d>", function()
        local entry = action_state.get_selected_entry()

        actions.delete_buffer(prompt_buf_id)
    end)

    map('i', mappings.delete_all or "<C-z>", function()
        self.action_utils.map_entries(prompt_buf_id, function(entry, index, _)
            vim.cmd("bw " .. entry.bufnr)
        end)

        self:refresh_buffers(self.show_buffers_idx)
    end)

    map('i', mappings.next_tab or "<Tab>", function()
        self.show_buffers_idx = (self.show_buffers_idx + 1) % 3
        self:refresh_buffers(project_buffers_idx)
    end)

    map('i', mappings.previous_tab or '<S-Tab>', function()
        local idx = self.show_buffers_idx - 1

        if idx == -1 then
            self.show_buffers_idx = term_buffers_idx
        else
            self.show_buffers_idx = idx
        end

        self:refresh_buffers(other_buffers_idx)
    end)

    return true;
end

function ProjectBuffers:sort_buffers(buffers)
    local function compare(a, b)
        return b.lastused < a.lastused
    end

    table.sort(buffers, compare)

    if 1 < #buffers then
        local current_buf = table.remove(buffers, 1);
        table.insert(buffers, current_buf); -- Append current buf to end
    end

    if max_buffers < #buffers then
        local result = {}

        for i, buff in ipairs(buffers) do
            if i <= max_buffers then
                table.insert(result, buff)
            end
        end

        return result
    else
        return buffers
    end
end

function ProjectBuffers:refresh_buffers(skip_term_idx)
    if self.show_buffers_idx == project_buffers_idx then
        self.picker:refresh(self:create_finder(self:project_buffers()), {})
    elseif self.show_buffers_idx == other_buffers_idx then
        self.picker:refresh(self:create_finder(self:other_buffers()), {})
    else
        local term_buffers = self:term_buffers()

        -- Skip term buffers if empty
        if #term_buffers == 0 then
            self.show_buffers_idx = skip_term_idx;
            self:refresh_buffers(skip_term_idx)
        else
            self.picker:refresh(self:create_finder(term_buffers), {})
        end
    end
end

function ProjectBuffers:project_buffers()
    local buffers = {}

    if not self.initialized then
        buffers = persist.last_used_buffers(self.root)
    end

    local function already_in_list(buf_info)
        for _, buffer in pairs(buffers) do
            if buffer.bufnr == buf_info.bufnr then
                buffer.lastused = buf_info.lastused
                return true
            end
        end

        return false
    end

    for _, buf_info in pairs(vim.fn.getbufinfo({ buflisted = true })) do
        local parts = vim.split(buf_info.name, self.root, { plain = true })

        if 1 < #parts and not already_in_list(buf_info) then
            table.insert(buffers, {
                name = buf_info.name,
                ordinal = buf_info.name,
                filename = buf_info.name,
                display = parts[2],
                bufnr = buf_info.bufnr,
                lnum = buf_info.lnum,
                col = 0,
                lastused = buf_info.lastused,
            })
        end
    end

    return self:sort_buffers(buffers)
end

function ProjectBuffers:other_buffers()
    local buffers = {}
    local home_dir = vim.fn.expand("$HOME") .. "/"

    local function create_display(buf_info)
        local parts = vim.split(buf_info.name, home_dir, { plain = true })

        if 1 < #parts then
            return "~/" .. parts[2]
        else
            return buf_info.name
        end
    end

    for _, buf_info in pairs(vim.fn.getbufinfo({ buflisted = true })) do
        local is_proj_buffer = vim.startswith(buf_info.name, self.root)
        local is_term_buffer = vim.startswith(buf_info.name, "term://")

        if not is_proj_buffer and not is_term_buffer then
            table.insert(buffers, {
                name = buf_info.name,
                filename = buf_info.name,
                display = create_display(buf_info),
                ordinal = buf_info.name,
                bufnr = buf_info.bufnr,
                lnum = buf_info.lnum,
                col = 0,
                lastused = buf_info.lastused,
            })
        end
    end

    return self:sort_buffers(buffers)
end

function ProjectBuffers:term_buffers()
    local buffers = {}

    for _, buf_info in pairs(vim.fn.getbufinfo({ buflisted = true })) do
        local is_term = vim.startswith(buf_info.name, "term://")

        if is_term then
            table.insert(buffers, {
                name = buf_info.name,
                filename = buf_info.name,
                display = buf_info.name,
                ordinal = buf_info.name,
                bufnr = buf_info.bufnr,
                lnum = buf_info.lnum,
                col = 0,
                lastused = buf_info.lastused,
            })
        end
    end

    return self:sort_buffers(buffers)
end

function ProjectBuffers:create_finder(buffers)
    local function entry_maker(entry)
        return {
            value = entry.name,
            ordinal = entry.name,
            display = entry.display,
            filename = entry.name,
            bufnr = entry.bufnr,
            lnum = entry.lnum,
            col = entry.col,
        }
    end

    return self.finders.new_table({
        results = buffers,
        entry_maker = entry_maker,
    })
end

function ProjectBuffers.get_root()
    local dir_path = vim.fn.expand('%:p:h')
    local sh_cmd = "cd " .. dir_path .. only_stdout .. " && git rev-parse --show-toplevel" .. only_stdout
    local git_root = vim.fn.systemlist(sh_cmd)[1]

    if git_root == nil then
        return dir_path .. "/"
    else
        return git_root .. "/"
    end
end

function ProjectBuffers.home_directory()
    return vim.fn.expand("$HOME") .. "/"
end

return ProjectBuffers

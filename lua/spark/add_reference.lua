local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local globals = require("spark.globals")
local utils = require("spark.utils")

local M = {}



function M.find_place_for_internal_ref()
    local no = 0
    local location = 0
    local references_section = false
    local start = false

    local current_buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
    for _, line in ipairs(lines) do
        line = utils.trim(line)
        if start and line ~= "" then
            no = no + 1
        end

        if line == "## References" then
            references_section = true
        end

        if line == "### Internal" and references_section then
            start = true
        end

        if line == "### External" and references_section then
            start = false
            break
        end

        if start and line ~= "" then
            location = location + 1
        end
        if not start then
            location = location + 1
        end
    end

    return no, location
end

function M.find_place_for_external_ref()
    local no = 0
    local location = 0
    local references_section = false
    local start = false

    local current_buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
    for i, line in ipairs(lines) do
        line = utils.trim(line)
        if start and line ~= "" then
            no = no + 1
        end

        if line == "## References" then
            references_section = true
        end

        if line == "### External" and references_section then
            start = true
        end

        if start and line ~= "" then
            location = location + 1
        end
        if not start then
            location = location + 1
        end
    end

    return location
end

function M.write_reference(prompt_bufnr, map, type)
    actions.select_default:replace(
    function()
        actions.close(prompt_bufnr)

        local ids = utils.get_ids()
        local titles = utils.get_titles()
        local selection = action_state.get_selected_entry()
        local index = utils.index_of(titles, selection[1])

        local no, location
        if type == "notes" then
            no, location = M.find_place_for_internal_ref()
        elseif type == "sources" then
            location = M.find_place_for_external_ref()
        end
        if not no then
            no = " - "
        else
            no = no .. ". "
        end
        local reference = no .. "[" .. ids[index] .. "] " .. titles[index]

        local current_buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_lines(current_buf, location, location, false, { reference })
    end)
    return true
end

function M.add_reference(type)
    local opts = require("telescope.themes").get_dropdown{}
    utils.setup_data(type)

    pickers.new(opts, {
        prompt_title = "Add " .. type:sub(1, -2) .. " as reference",
        finder = finders.new_table { results = utils.get_titles() },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function (prompt_bufnr, map)
            return M.write_reference(prompt_bufnr, map, type)
        end,
    }):find()
end

-- to execute the function
-- M.add_note_reference(require("telescope.themes").get_dropdown{})

return M

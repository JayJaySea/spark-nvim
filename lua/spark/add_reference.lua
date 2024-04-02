local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local globals = require("spark.globals")
local utils = require("spark.utils")

local M = {}

function M.setup_data()
    vim.print(globals)
    local ids_cmd = "spark list notes --id > " .. globals.idspath .. " 2> " .. globals.logpath
    local titles_cmd = "spark list notes --title > " .. globals.titlespath .. " 2> " .. globals.logpath
    local status = os.execute(ids_cmd .. ";" .. titles_cmd)

    if status ~= 0 then
        utils.print_spark_error()
    end
end

function M.get_ids()
    local results = {}
    for id in io.lines(globals.idspath) do
        table.insert(results, id)
    end

    return results
end

function M.get_titles()
    local results = {}
    for title in io.lines(globals.titlespath) do
        table.insert(results, title)
    end

    return results
end

function M.index_of(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function M.find_place_for_internal_ref()
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

        if line == "### Internal" and references_section then
            start = true
        end

        if line == "### External" and references_section then
            start = false
            break
        end

        location = i
    end

    return no, location - 1
end

function M.write_reference(prompt_bufnr, map)
    actions.select_default:replace(
    function()
        actions.close(prompt_bufnr)

        local ids = M.get_ids()
        local titles = M.get_titles()
        local selection = action_state.get_selected_entry()
        local index = M.index_of(titles, selection[1])

        local no, location = M.find_place_for_internal_ref()
        local reference = no .. ". [" .. ids[index] .. "] " .. titles[index]

        local current_buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_buf_set_lines(current_buf, location, location, false, { reference })
    end)
    return true
end

function M.add_note_reference(opts)
    opts = opts or require("telescope.themes").get_dropdown{}
    M.setup_data()

    pickers.new(opts, {
        prompt_title = "Add note as reference",
        finder = finders.new_table { results = M.get_titles() },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function (prompt_bufnr, map)
            return M.write_reference(prompt_bufnr, map)
        end,
    }):find()
end



-- to execute the function
-- M.add_note_reference(require("telescope.themes").get_dropdown{})

return M

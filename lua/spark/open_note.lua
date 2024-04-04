local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local globals = require("spark.globals")
local utils = require("spark.utils")

local M = {}
function M.get_selected_note(prompt_bufnr)
    actions.close(prompt_bufnr)

    local ids = utils.get_ids()
    local titles = utils.get_titles()
    local selection = action_state.get_selected_entry()
    local index = utils.index_of(titles, selection[1])
    local id = ids[index]

    local path = globals.tmpdir .. id .. ".spark.md"
    local cmd = "spark get note " .. id .. " --path " .. path .. " &> " .. globals.logpath

    return path, os.execute(cmd)
end

function M.open_selected_note(prompt_bufnr, map)
    actions.select_default:replace(
    function()
        local path, result = M.get_selected_note(prompt_bufnr)

        if result == 0 then
            vim.api.nvim_command("edit " .. path)
        else
            utils.print_spark_error()
        end
    end)

    actions.select_tab:replace(
    function()
        local path, result = M.get_selected_note(prompt_bufnr)

        if result == 0 then
            vim.api.nvim_command("tabedit " .. path)
        else
            utils.print_spark_error()
        end
    end)

    return true
end

function M.open_note()
    local opts = {}
    utils.setup_data("notes")

    pickers.new(opts, {
        prompt_title = "Open note",
        finder = finders.new_table { results = utils.get_titles() },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function (prompt_bufnr, map)
            return M.open_selected_note(prompt_bufnr, map)
        end,
    }):find()
end

-- to execute the function
-- M.add_note_reference(require("telescope.themes").get_dropdown{})

return M

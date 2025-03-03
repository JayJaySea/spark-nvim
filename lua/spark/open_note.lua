local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local globals = require("spark.globals")
local utils = require("spark.utils")

local M = {}
function M.get_selected_note()
    local ids = utils.get_ids()
    local titles = utils.get_titles()
    local selection = action_state.get_selected_entry()
    print(vim.inspect(selection))
    local index = utils.index_of(titles, selection[1])
    local id = ids[index]

    local path = globals.tmpdir .. id .. ".spark.md"
    local cmd = "spark get note " .. id .. " --path " .. path .. " &> " .. globals.logpath

    return path, os.execute(cmd)
end

function M.open_selected_note(new_tab)
    local path, result = M.get_selected_note()

    if result == 0 then
        if new_tab then
            vim.api.nvim_command("tabedit " .. path)
        else
            vim.api.nvim_command("edit " .. path)
        end
    else
        utils.print_spark_error()
    end

    return true
end

function M.open_note()
    local opts = {}
    utils.setup_data("notes")

    pickers.new(opts, {
        prompt_title = "Open note",
        finder = finders.new_table { results = utils.get_titles() },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function (_, map)
            map("i", "<CR>", function(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    actions.close(prompt_bufnr)
                    M.open_selected_note(false)
                end
            end)
            map("i", "<C-t>", function(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    actions.close(prompt_bufnr)
                    M.open_selected_note(true)
                end
            end)
            return true
        end,
    }):find()
end

function M.open_note_by_id(id, new_tab, line_number)
    local path = globals.tmpdir .. id .. ".spark.md"
    local cmd = "spark get note " .. id .. " --path " .. path .. " &> " .. globals.logpath

    if os.execute(cmd) then
        if new_tab then
            vim.api.nvim_command("tabedit " .. path)
        else
            vim.api.nvim_command("edit " .. path)
        end

        if line_number then
            vim.api.nvim_win_set_cursor(0, {line_number, 0})
            vim.cmd("normal! zz")
        end
    else
        utils.print_spark_error()
    end
end
-- to execute the function
-- M.add_note_reference(require("telescope.themes").get_dropdown{})

return M

local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"
local utils = require("spark.utils")
local open_note = require("spark.open_note")

local M = {}
function M.search_cli(phrase)
    if phrase:len() < 3 then
        return vim.json.decode("[]")
    end

    local handle = io.popen("spark search --phrase '" .. phrase .. "'")
    if handle then
        local results = handle:read("*a")
        results = vim.json.decode(results)
        handle:close()
        return results
    end
end

function M.search_note()
    local opts = {}
    utils.setup_data("notes")

    pickers.new(opts, {
        prompt_title = "Search contents",
        finder = finders.new_dynamic({
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = entry.note.title,
                    ordinal = entry.note.contents,
                    preview = "# [" .. entry.note.id .. "] " .. entry.note.title .. entry.note.contents
                }
            end,
            fn = M.search_cli,
        }),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function (_, map)
            map("i", "<CR>", function(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    actions.close(prompt_bufnr)
                    open_note.open_note_by_id(selection.value.note.id, false, selection.value.line_number)
                end
            end)
            map("i", "<C-t>", function(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    actions.close(prompt_bufnr)
                    open_note.open_note_by_id(selection.value.note.id, true, selection.value.line_number)
                end
            end)
            return true
        end,
        previewer = previewers.new_buffer_previewer({
            define_preview = function(self, entry)
                if not entry or not entry.preview then
                    return
                end

                local bufnr = self.state.bufnr
                vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(entry.preview, "\n"))
                vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")

                print(entry.value.line_number)
                print(entry.value.note.title)
                print(vim.api.nvim_buf_line_count(bufnr))
                -- print(entry.value.note.contents)
                --
                if entry.value.line_number then
                    vim.schedule(function ()
                        vim.api.nvim_win_set_cursor(self.state.winid, { entry.value.line_number, 0 })
                        vim.api.nvim_buf_call(bufnr, function()
                            vim.cmd("normal! zz")
                        end)
                        vim.api.nvim_buf_add_highlight(bufnr, -1, "Search", entry.value.line_number - 1, 0, -1)
                    end)
                end
            end
        })
    }):find()
end

return M

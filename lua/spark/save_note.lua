local utils = require("spark.utils")
local globals = require("spark.globals")

local M = {}
function M.set_autosave_note()
    if utils.check_spark() then
        vim.api.nvim_command([[autocmd BufWritePost * lua require('spark').save_note()]])
        local group = vim.api.nvim_create_augroup('autosave', {})

        vim.api.nvim_create_autocmd('User', {
            pattern = 'AutoSaveWritePost',
            group = group,
            callback = function(opts)
                M.save_note()
            end,
        })
    end
end

function M.save_note()
    if not utils.check_spark() then
        return
    end
    local cmd = "spark set --path " .. utils.current_path() .. " &> " .. globals.logpath

    local result = os.execute(cmd)

    if result ~= 0 then
        utils.print_spark_error()
    end
end
return M

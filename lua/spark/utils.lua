local globals = require("spark.globals")
local M = {}

function M.check_spark()
    local current_buf = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(current_buf)
    local suffix = ".spark.md"

    if filename:sub(-#suffix) == suffix then
        return true
    end
    return false
end

function M.print_spark_error()
    local last = ""
    for log in io.lines(globals.logpath) do
        last = log
    end
    vim.api.nvim_err_writeln(last)
end

return M

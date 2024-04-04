local globals = require("spark.globals")
local M = {}

function M.create_tmpdir()
    os.execute("mkdir -p " .. globals.tmpdir)
end

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

function M.current_path()
    local current_buf = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(current_buf)

    return filename
end

function M.setup_data(type)
    vim.print(globals)
    local ids_cmd = "spark list " .. type .. " --id > " .. globals.idspath .. " 2> " .. globals.logpath
    local titles_cmd = "spark list " .. type .. " --title > " .. globals.titlespath .. " 2> " .. globals.logpath
    local status = os.execute(ids_cmd .. ";" .. titles_cmd)

    if status ~= 0 then
        M.print_spark_error()
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

function M.trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end
return M

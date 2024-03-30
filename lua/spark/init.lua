local utils = require("spark.utils")
local globals = require("spark.globals")

local M = {}

function M.follow_reference(offset)
    os.execute("mkdir -p " .. globals.tmpdir)
    local current_buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, true)

    local start = -offset -1
    local references_section = false
    local pattern = "%[%w+%]"

    for i, line in ipairs(lines) do
        if line == "## References" then
            references_section = true
        end

        if line == "### Internal" and references_section then
            start = i
        end

        if i == start + offset then
            local extracted = line:match(pattern)

            if extracted == nil or extracted == '' then
                vim.api.nvim_err_writeln("Note id not found on that line!")
                return
            end

            local id = extracted:sub(2, -2)
            local filename = id .. ".spark.md"
            local path = globals.tmpdir .. filename
            local cmd = "spark get note " .. id .. " --path=" .. path .. "&> " .. globals.logpath
            local result = os.execute(cmd)

            if result == 0 then
                vim.api.nvim_command("edit " .. path)
            else
                utils.print_spark_error()
            end

        end
    end
end


function M.set_autosave_note()
    if utils.check_spark() then
        vim.api.nvim_command([[autocmd BufWritePost * lua require('spark').save_note()]])
    end
end

function M.save_note()
    if not utils.check_spark() then
        return
    end
    vim.print("lol")
end


return M

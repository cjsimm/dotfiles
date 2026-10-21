return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local function project_ruff(filename)
            if filename == "" then
                return nil
            end

            local directory = vim.fs.dirname(filename)
            local venv = vim.fs.find(".venv", { path = directory, upward = true, type = "directory" })[1]
            if venv then
                local binary = venv .. "/bin/ruff"
                if vim.fn.executable(binary) == 1 then
                    return binary
                end
            end

            if vim.fn.executable("mise") == 1 then
                local result = vim.system({ "mise", "exec", "-C", directory, "--", "which", "ruff" }, {
                    text = true,
                }):wait()
                if result.code == 0 then
                    local binary = vim.trim(result.stdout)
                    if vim.fn.executable(binary) == 1 then
                        return binary
                    end
                end
            end

            return nil
        end

        local function ruff_formatter(bufnr)
            local filename = vim.api.nvim_buf_get_name(bufnr)
            local binary = project_ruff(filename)
            local directory = filename ~= "" and vim.fs.dirname(filename) or nil

            return {
                command = binary or "ruff",
                condition = function()
                    return binary ~= nil
                end,
                cwd = function()
                    return directory
                end,
            }
        end

        require("conform").setup({
            formatters_by_ft = {
                python = { "ruff_format", "ruff_fix" },
            },
            formatters = {
                ruff_format = ruff_formatter,
                ruff_fix = ruff_formatter,
            },
            format_on_save = function(bufnr)
                if vim.bo[bufnr].filetype == "python" then
                    return { timeout_ms = 3000, lsp_format = "never" }
                end
            end,
        })
    end,
}

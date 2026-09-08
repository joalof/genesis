local IMAGE_DB = "~/projects/vion-orchestra/image-database.json"

-- picker over the output of any shell command, inserting the pick at the cursor
---@param spec {cmd:string, cwd?:string, prompt?:string}
local function cmd_picker(spec)
    require("fzf-lua").fzf_exec(spec.cmd, {
        cwd = spec.cwd,
        prompt = (spec.prompt or "") .. "> ",
        -- pastes the entry after the cursor, like `p`
        complete = true,
        fzf_opts = { ["--no-multi"] = true },
    })
end

---@param filter string a jq filter over the vion-orchestra image database
local function image_db_picker(filter, prompt)
    cmd_picker({
        cmd = ("jq -r %s %s"):format(vim.fn.shellescape(filter), vim.fn.shellescape(vim.fn.expand(IMAGE_DB))),
        prompt = prompt,
    })
end

-- fzf-lua has no "projects" picker; zoxide resolved to the enclosing git root is the closest thing.
local function projects()
    local fzf = require("fzf-lua")
    fzf.zoxide({
        git_root = true,
        actions = {
            enter = function(selected, opts)
                require("fzf-lua.actions").zoxide_cd(selected, opts)
                vim.schedule(function()
                    fzf.files({ cwd = vim.uv.cwd() })
                end)
            end,
        },
    })
end

return {
    "ibhagwan/fzf-lua",
    dependencies = {
        -- `opts` makes lazy call setup(), which registers the BufEnter autocmd
        -- that records scores. Without it nothing is tracked until the first
        -- frecency() call.
        { "elanmed/fzf-lua-frecency.nvim", opts = {} },
    },
    cmd = "FzfLua",
    keys = {
        { "<leader>fb", "<cmd>FzfLua buffers<CR>", desc = "Buffers" },
        {
            "<leader>fn",
            function()
                require("fzf-lua").files({ cwd = vim.fs.abspath("~/.config/nvim/lua/") })
            end,
            desc = "Find neovim configs",
        },
        {
            "<leader>f.",
            function()
                require("fzf-lua").files({ cwd = vim.fs.abspath("~/.local/share/chezmoi/") })
            end,
            desc = "Find managed dotfiles",
        },
        { "<leader>fp", projects, desc = "Projects" },
        { "<leader>f/", "<cmd>FzfLua search_history<CR>", desc = "Search History" },
        { "<leader>fC", "<cmd>FzfLua command_history<CR>", desc = "Command History" },
        { "<leader>fc", "<cmd>FzfLua commands<CR>", desc = "Commands" },
        { "<leader>fe", "<cmd>FzfLua diagnostics_document<CR>", desc = "Buffer Diagnostics" },
        { "<leader>fh", "<cmd>FzfLua helptags<CR>", desc = "Help Pages" },
        { "<leader>fm", "<cmd>FzfLua manpages<CR>", desc = "Man Pages" },
        { "<leader>fk", "<cmd>FzfLua keymaps<CR>", desc = "Key maps" },
        { "<leader>fu", "<cmd>FzfLua undotree<CR>", desc = "Undo History" },
        { "<leader>fl", "<cmd>FzfLua highlights<CR>", desc = "Highlights" },
        {
            "<leader>ff",
            function()
                require("fzf-lua-frecency").frecency({
                    cwd = require("project").get_root("cwd"),
                    -- scored files outside the project are filtered out, and
                    -- unscored project files are appended via `fd`
                    cwd_only = true,
                })
            end,
            desc = "Find project files",
        },
        { "<leader>fd", "<cmd>FzfLua zoxide<CR>", desc = "Zoxide directories" },
        { "<leader>fs", "<cmd>FzfLua lsp_document_symbols<CR>", desc = "LSP symbols" },
        { "<leader>fg", "<cmd>FzfLua grep_project<CR>", desc = "Grep all project files" },
        { "<leader>fa", "<cmd>FzfLua autocmds<CR>", desc = "autocmds" },
        {
            ",vd",
            function()
                image_db_picker(".[] | .function_name", "vion-orchestra function")
            end,
            desc = "Pick vion-orchestra function",
        },
        {
            ",va",
            function()
                image_db_picker(".[] | .output_uri", "vion-orchestra artifact")
            end,
            desc = "Pick vion-orchestra artifact uri",
        },
    },
    opts = {
        keymap = {
            builtin = {},
            fzf = {
                true,
                ["ctrl-c"] = "abort",
                ["ctrl-j"] = "accept",
                ["ctrl-u"] = "unix-line-discard",
                ["ctrl-f"] = "half-page-down",
                ["ctrl-b"] = "half-page-up",
                ["ctrl-a"] = "beginning-of-line",
                ["ctrl-e"] = "end-of-line",
            },
        },
    },
}

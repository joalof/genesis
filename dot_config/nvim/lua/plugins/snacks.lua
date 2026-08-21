return {
    "folke/snacks.nvim",
    priority = 1100,
    lazy = false,
    ---@type snacks.Config
    opts = {
        bigfile = { enabled = true },
        dashboard = { enabled = false },
        explorer = { enabled = false },
        indent = { enabled = false },
        input = { enabled = true },
        rename = { enabled = false },
        image = {
            enabled = true,
            doc = {
                enabled = true,
                max_width = 100,
                max_height = 100,
            },
        },
        notifier = { enabled = false, timeout = 3000 },
        picker = {
            enabled = true,
            win = {
                -- input window
                input = {
                    keys = {
                        ["<c-j>"] = { "confirm", mode = { "i", "n" } },
                        ["<c-c>"] = { "cancel", mode = { "i", "n" } },
                    },
                },
            },
        },
        quickfile = { enabled = true },
        scope = { enabled = false },
        scroll = { enabled = false },
        statuscolumn = { enabled = false },
        words = { enabled = false },
        styles = {
            notification = {
                -- wo = { wrap = true } -- Wrap notifications
            },
        },
    },
    keys = {
        {
            "<leader>os",
            function()
                Snacks.scratch()
            end,
            desc = "Toggle Scratch Buffer",
        },
        {
            "<leader>oS",
            function()
                Snacks.scratch.select()
            end,
            desc = "Select scratch buffer",
        },
        {
            "<leader>fb",
            function()
                Snacks.picker.buffers()
            end,
            desc = "Buffers",
        },
        {
            "<leader>fn",
            function()
                Snacks.picker.files({ cwd = vim.fs.abspath("~/.config/nvim/lua/") })
            end,
            desc = "Find neovim configs",
        },
        {
            "<leader>f.",
            function()
                Snacks.picker.files({ cwd = vim.fs.abspath("~/.local/share/chezmoi/") })
            end,
            desc = "Find managed dotfiles",
        },
        {
            "<leader>fp",
            function()
                Snacks.picker.projects()
            end,
            desc = "Projects",
        },
        {
            "<leader>f/",
            function()
                Snacks.picker.search_history()
            end,
            desc = "Search History",
        },
        {
            "<leader>fC",
            function()
                Snacks.picker.command_history()
            end,
            desc = "Command History",
        },
        {
            "<leader>fc",
            function()
                Snacks.picker.commands()
            end,
            desc = "Commands",
        },
        {
            "<leader>fe",
            function()
                Snacks.picker.diagnostics_buffer()
            end,
            desc = "Buffer Diagnostics",
        },
        {
            "<leader>fh",
            function()
                Snacks.picker.help()
            end,
            desc = "Help Pages",
        },
        {
            "<leader>fm",
            function()
                Snacks.picker.man()
            end,
            desc = "Man Pages",
        },
        {
            "<leader>fk",
            function()
                Snacks.picker.keymaps()
            end,
            desc = "Key maps",
        },
        {
            "<leader>fu",
            function()
                Snacks.picker.undo()
            end,
            desc = "Undo History",
        },
        {
            "<leader>fl",
            function()
                Snacks.picker.highlights()
            end,
            desc = "Highlights",
        },
        {
            "<leader>ff",
            function()
                Snacks.picker.files({
                    cwd = require("project").get_root("cwd"),
                    matcher = {
                        frecency = true,
                        sort_empty = true,
                    },
                })
            end,
            desc = "Find project files",
        },
        {
            "<leader>fd",
            function()
                Snacks.picker.zoxide()
            end,
            desc = "Highlights",
        },
        {
            "<leader>fs",
            function()
                Snacks.picker.lsp_symbols({
                    tree = true,
                    workspace = false,
                })
            end,
            desc = "LSP symbols",
        },
        {
            "<leader>fg",
            function()
                Snacks.picker.grep({})
            end,
            desc = "Grep",
        },
        {
            "<leader>fa",
            function()
                Snacks.picker.autocmds({})
            end,
            desc = "autocmds",
        },
    },
    config = function(_, opts)
        local Snacks = require("snacks")

        Snacks.setup(opts)

        -- a reusable insert-at-cursor confirm
        local function insert_at_cursor(picker)
            picker:close()
            local lines = vim.tbl_map(function(i)
                return i.text
            end, picker:selected({ fallback = true }))
            if #lines == 0 then
                return
            end
            local insert_mode = picker.input.mode == "i"
            vim.schedule(function()
                vim.api.nvim_put(lines, "c", not insert_mode, true) -- "c" charwise; use "l" for whole lines
                if insert_mode then
                    vim.cmd.startinsert({ bang = true })
                end
            end)
        end

        -- generic template: picker over the output of any command
        ---@param opts {cmd:string, args?:string[], cwd?:string, title?:string}
        local function cmd_picker(opts)
            return Snacks.picker.pick(vim.tbl_extend("keep", opts, {
                finder = "proc",
                format = "text",
                preview = "none",
                title = opts.title or opts.cmd,
                confirm = insert_at_cursor,
            }))
        end

        vim.keymap.set(
            { "n" },
            ",vd",
            function()
                cmd_picker({
                    cmd = "jq",
                    args = {
                        "-r",
                        ".[] | .function_name",
                        vim.fn.expand("~/projects/vion-orchestra/image-database.json"),
                    },
                    title = "vion-orchestra function",
                })
            end,
            { desc = "Pick vion-orchestra function" }
        )

        vim.keymap.set(
            { "n" },
            ",va",
            function()
                cmd_picker({
                    cmd = "jq",
                    args = {
                        "-r",
                        ".[] | .output_uri",
                        vim.fn.expand("~/projects/vion-orchestra/image-database.json"),
                    },
                    title = "vion-orchestra artifact",
                })
            end,
            { desc = "Pick vion-orchestra artifact uri" }
        )
        
    end,
}

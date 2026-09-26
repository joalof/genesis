vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

vim.keymap.set("n", "'", "`")
vim.keymap.set("n", "`", "'")
vim.keymap.set("n", "0", "^")
vim.keymap.set("n", "^", "0")

vim.keymap.set("n", "<c-q>", function()
    local mc_ns = vim.api.nvim_create_namespace("nvim.multicursor")
    vim.api.nvim_buf_clear_namespace(0, mc_ns, 0, -1)
end)
vim.keymap.del("n", "<c-l>")

-- splitline
vim.keymap.set("n", "S", function()
    return [[:keeppatterns substitute/\s*\%#\s*/\r/e <bar> normal! ==k$<CR>]]
end, { expr = true })

local kitty_direction_cmds = {
    l = "KittyNavigateRight",
    h = "KittyNavigateLeft",
    j = "KittyNavigateDown",
    k = "KittyNavigateUp",
}

local function navigate_window(direction, term_program)
    if term_program == "kitty" then
        local cmd = kitty_direction_cmds[direction]
        vim.api.nvim_cmd({ cmd = cmd }, {})
    else
        vim.cmd.wincmd(direction)
    end
end

-- split window navigation
local term_prog = os.getenv("TERM_PROGRAM")
if term_prog == nil then
    local env_term = os.getenv("TERM")
    if env_term == "wezterm" then
        term_prog = "wezterm"
    elseif env_term == "xterm-kitty" then
        term_prog = "kitty"
    elseif env_term == "xterm-ghostty" then
        term_prog = "ghostty"
    end
end

local navigate_prefix = "<c-s>%s"
-- We can only send a single mod + key with wezterm so can't use <c-s>hjkl here
if term_prog == "WezTerm" then
    navigate_prefix = "<M-%s>"
end

for _, direction in ipairs({ "h", "j", "k", "l" }) do
    vim.keymap.set({ "n", "t" }, string.format(navigate_prefix, direction), function()
        navigate_window(direction, term_prog)
    end)
end

-- treesitter inc selection
vim.keymap.set({ "x", "o" }, "n", function()
    if vim.treesitter.get_parser(nil, nil, { error = false }) then
        require("vim.treesitter._select").select_parent(vim.v.count1)
    else
        vim.lsp.buf.selection_range(vim.v.count1)
    end
end)

vim.keymap.set({ "x", "o" }, "p", function()
    if vim.treesitter.get_parser(nil, nil, { error = false }) then
        require("vim.treesitter._select").select_child(vim.v.count1)
    else
        vim.lsp.buf.selection_range(-vim.v.count1)
    end
end)

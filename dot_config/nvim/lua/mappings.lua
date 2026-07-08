vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

vim.keymap.set("n", "'", "`")
vim.keymap.set("n", "`", "'")
vim.keymap.set("n", "0", "^")
vim.keymap.set("n", "^", "0")

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
local term_program = os.getenv("TERM_PROGRAM")
if term_program == nil then
    local term = os.getenv("TERM")
    if term == "wezterm" then
        term_program = "wezterm"
    elseif term == "xterm-kitty" then
        term_program = "kitty"
    elseif term == "xterm-ghostty" then
        term_program = "ghostty"
    end
end

local navigate_prefix = "<c-s>%s"
-- We can only send a single mod + key with wezterm so can't use <c-s>hjkl here
if term_program == "WezTerm" then
    navigate_prefix = "<M-%s>"
end

for _, direction in ipairs({ "h", "j", "k", "l" }) do
    vim.keymap.set({ "n", "t" }, string.format(navigate_prefix, direction), function()
        navigate_window(direction, term_program)
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

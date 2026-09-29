-- Requires Neovim 0.11+. See README.md for keys and maintenance.
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Editing: use Neovim's built-in syntax, completion and status line.
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.wrap = false
vim.opt.scrolloff = 5
vim.opt.signcolumn = "yes"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.undofile = true
vim.opt.termguicolors = true
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.path:append("**")
vim.opt.wildignore:append({ "*/.git/*", "*/.venv/*", "*/node_modules/*", "*/__pycache__/*" })
vim.cmd.colorscheme("habamax")
vim.diagnostic.config({ virtual_text = false, severity_sort = true, float = { border = "rounded" } })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
  end,
})

-- Plugin manager: only a file tree and a language-tool installer.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local output = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
  if vim.v.shell_error ~= 0 then error("Could not install lazy.nvim:\n" .. output) end
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  { "nvim-tree/nvim-tree.lua", opts = {
    view = { width = 30 },
    renderer = { icons = { show = { file = false, folder = false, folder_arrow = true, git = false } } },
  } },
  { "mason-org/mason.nvim", opts = {} },
}, { checker = { enabled = false }, change_detection = { notify = false } })

-- Language servers. Install with :MasonInstall pyright ruff tinymist.
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "pyrightconfig.json", "setup.py", ".git" },
  settings = { python = { analysis = { autoSearchPaths = true, useLibraryCodeForTypes = true } } },
})
vim.lsp.config("ruff", {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
})
vim.lsp.config("tinymist", {
  cmd = { "tinymist" },
  filetypes = { "typst" },
  root_markers = { "typst.toml", ".git" },
  settings = { formatterMode = "typstyle", exportPdf = "onSave" },
})
vim.lsp.enable({ "pyright", "ruff", "tinymist" })

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then return end
    if client.name == "ruff" then client.server_capabilities.hoverProvider = false end
    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    end
    local function map(key, action, desc)
      vim.keymap.set("n", key, action, { buffer = event.buf, desc = desc })
    end
    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gr", vim.lsp.buf.references, "References")
    map("K", vim.lsp.buf.hover, "Documentation")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("<leader>f", function()
      vim.lsp.buf.format({ async = false, timeout_ms = 3000,
        filter = function(c) return c.name == "ruff" or c.name == "tinymist" end })
    end, "Format buffer")
  end,
})

-- Space is the leader key; other standard Neovim keys are left intact.
local map = vim.keymap.set
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree" })
map("n", "<leader>E", "<cmd>NvimTreeFindFile<cr>", { desc = "Reveal current file" })
map("n", "<leader>ff", ":find ", { desc = "Find file (Tab to complete)" })
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>t", "<cmd>split | terminal<cr>", { desc = "Open terminal" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Leave terminal mode" })
for _, key in ipairs({ "h", "j", "k", "l" }) do
  map("n", "<C-" .. key .. ">", "<C-w>" .. key, { desc = "Move between windows" })
end

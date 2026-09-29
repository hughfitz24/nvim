# Simple Neovim

Requires Neovim 0.11+, Git, Python 3 and Node.js/npm. All configuration lives in
`init.lua`: built-in syntax highlighting, LSP completion and a stock theme, with
nvim-tree for navigation and Mason for installing language tools. lazy.nvim
manages those two plugins; `lazy-lock.json` records their tested revisions.

Open Neovim from your project directory: `cd project && nvim .`.

## Keys

The leader is **Space**.

| Key | Action |
| --- | --- |
| Space e / Space E | Toggle tree / reveal current file |
| Space ff | Find file by path; Tab completes, Enter opens |
| Space bn / Space bp | Next / previous buffer |
| Ctrl-h/j/k/l | Move between windows |
| gd / gr / K | Definition / references / documentation |
| Space rn / Space ca | Rename symbol / code action |
| Space f | Format Python with Ruff or Typst with Tinymist |
| Space d | Show diagnostic under cursor |
| [d / ]d | Previous / next diagnostic |
| Space t | Open terminal in a split |
| Escape Escape | Leave terminal input mode |
| Escape | Clear search highlighting |

In the tree, Enter opens a file or directory, `a` creates, `r` renames, and `g?`
shows all keys. No special font is required.

Completion pops up on server trigger characters. Use **Ctrl-x Ctrl-o** to request
it explicitly, **Ctrl-n / Ctrl-p** to select, and **Ctrl-y** to accept.
Native `gcc` comments a line; select lines and press `gc` to comment a selection.
Use `:split`, `:vsplit`, `:bdelete`, and normal Vim search as usual.

## Language tools

Run `:MasonInstall pyright ruff tinymist` on a fresh machine, wait for installation,
then restart Neovim. `:Mason` shows installed tools and available updates.

Python uses Pyright for completion/type checks and Ruff for linting, formatting
and code actions. Activate your project's virtual environment **before** starting
Neovim so Pyright finds its packages. Python uses four spaces; other files use two.
Formatting is explicit (Space f), so saving does not rewrite your code.

Typst uses Tinymist for completion, diagnostics and formatting. Saving a valid
`.typ` file exports a PDF beside it. This setup assumes standalone documents;
for multi-file projects, configure Tinymist's main document as described in its
[documentation](https://myriad-dreamin.github.io/tinymist/frontend/neovim.html).

## Maintenance

- Edit `init.lua` and restart Neovim.
- `:Lazy update` updates configured plugins; `:Lazy restore` restores locked versions.
- Commit `init.lua`, this README and `lazy-lock.json` together.
- `:checkhealth mason` checks tool-installation prerequisites; `:checkhealth vim.lsp`
  checks language servers.
- The previous config is preserved as `init.lua.backup-20260924`. To restore it,
  copy it over `init.lua` and restart Neovim.

The previous plugin cache is retained. Avoid `:Lazy clean` if another config uses
plugins from the same data directory.

Plugin references: [nvim-tree](https://github.com/nvim-tree/nvim-tree.lua),
[Mason](https://github.com/mason-org/mason.nvim).

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- ctrl+left-click: LSP references (default is ctags jump, hence "no tags found")
vim.keymap.set("n", "<C-LeftMouse>", function()
  vim.cmd("exec \"normal! \\<LeftMouse>\"")
  vim.lsp.buf.references()
end, { desc = "Goto References (mouse)" })

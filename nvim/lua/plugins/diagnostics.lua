return {
  "neovim/nvim-lspconfig", -- This is just to ensure this plugin loads after lspconfig
  config = function()
    vim.diagnostic.config({
      virtual_text = {
        -- This will wrap the virtual text messages
        wrap = true,
      },
      float = {
        -- This will wrap the messages in the hover pop-up
        wrap = true,
      },
    })
  end,
}

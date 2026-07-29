return {
  -- nvim-lspconfig configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tsserver = {},
        tailwindcss = {},
        rust_analyzer = {},
      },
    },
  },
  -- mason.nvim configuration
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "typescript-language-server",
        "tailwindcss-language-server",
        "rust-analyzer",
      },
    },
  },
}

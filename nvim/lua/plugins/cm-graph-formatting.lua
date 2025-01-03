-- ruff instead of black

return {
  -- Configure conform.nvim for formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format" },
      },
      formatters = {
        ruff_format = {
          -- Ruff will automatically read from pyproject.toml
          -- We don't need to specify args as it will use the project config
        },
      },
    },
  },

  -- Configure nvim-lint for linting
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        python = { "ruff" },
      },
      linters = {
        ruff = {
          -- Ruff will automatically read from pyproject.toml for linting too
        },
      },
    },
  },

  -- Configure ruff-lsp
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruff_lsp = {
          -- Ruff LSP will also read from pyproject.toml
          on_attach = function(client, _)
            -- Disable formatting since we're using conform.nvim with ruff_format
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
        },
      },
    },
  },

  -- Ensure tools are installed
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "ruff",
        "ruff-lsp",
      })
    end,
  },
}

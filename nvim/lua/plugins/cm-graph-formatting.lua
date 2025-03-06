-- cm-graph-formatting.lua
-- updated as of the great dev merge effort mar 6, 2025

return {
  -- Configure conform.nvim for formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "isort", "ruff_format" }, -- Add isort before ruff_format
      },
      formatters = {
        ruff_format = {
          -- Ruff will automatically read from pyproject.toml
        },
        isort = {
          -- Configure isort to match the profile in pyproject.toml
          args = {
            "--profile",
            "black",
            "--filter-files",
            "--atomic",
          },
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
          -- Configure ruff to use the specific rules from the project
          args = {
            "--select=E402,F811,E722",
          },
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
          -- Ruff LSP will read from pyproject.toml
          on_attach = function(client, _)
            -- Disable formatting since we're using conform.nvim with ruff_format
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end,
          settings = {
            -- Match the specific lint rules in pyproject.toml
            lint = {
              select = { "E402", "F811", "E722" },
            },
          },
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
        "isort", -- Add isort
      })
    end,
  },
}

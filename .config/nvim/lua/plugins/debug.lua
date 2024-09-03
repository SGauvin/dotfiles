return {
  "mfussenegger/nvim-dap",
  event = "VeryLazy",
  dependencies = {
    "jay-babu/mason-nvim-dap.nvim",
    "nvim-neotest/nvim-nio",
    "williamboman/mason.nvim",
    {
      "rcarriga/nvim-dap-ui",
      config = function()
        require("dapui").setup({})
      end,
    },
    {
      "SGauvin/ctest-telescope.nvim",
      branch="extra_args",
      config = function()
        require("ctest-telescope").setup({
          extra_ctest_args = { "-C", "Debug" },
          dap_config = {
            stopAtEntry = true,
            setupCommands = {
              {
                text = "-enable-pretty-printing",
                description = "Enable pretty printing",
                ignoreFailures = false,
              },
            },
          },
        })
      end,
    },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    require("mason-nvim-dap").setup({
      automatic_setup = true,
      handlers = {},
      ensure_installed = {},
    })

    vim.keymap.set("n", "<F1>", dap.step_into)
    vim.keymap.set("n", "<F2>", dap.step_over)
    vim.keymap.set("n", "<F3>", dap.step_out)
    vim.keymap.set("n", "<F4>", dap.run_to_cursor)

    vim.keymap.set("n", "<F5>", function()
      if dap.session() == nil then
        if vim.bo.filetype == "c" or vim.bo.filetype == "cpp" then
          require("ctest-telescope").pick_test_and_debug()
        end
      else
        dap.continue()
      end
    end)

    vim.keymap.set("n", "<F6>", function()
      if dap.session() == nil then
        dap.configurations.cpp = {}
        -- require("dap.ext.vscode").load_launchjs(nil, { cppdbg = { "c", "cpp" } })
        dap.continue()
      end
    end)

    vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })

    vim.keymap.set("n", "<leader>B", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end)

    vim.keymap.set("n", "<F7>", dapui.toggle, { desc = "Debug: See last session result." })

    vim.keymap.set("n", "<F8>", dapui.eval)

    dap.listeners.after.event_initialized["dapui_config"] = dapui.open
    dap.listeners.before.event_terminated["dapui_config"] = dapui.close
    dap.listeners.before.event_exited["dapui_config"] = dapui.close
  end,
}

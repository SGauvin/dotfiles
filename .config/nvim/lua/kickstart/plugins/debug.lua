local gdb_targets_defaults = {
  configs = {},
}

local run_gdb_test_from_neoconf = function()
  local dap = require "dap"
  local my_settings = require("neoconf").get("gdb-targets", gdb_targets_defaults)
  local configs = {}

  for _, v in ipairs(my_settings) do
    local config = {
      name = v.name or "Launch",
      type = v.type or "cppdbg",
      request = v.request or "launch",
      program = v.program,
      cwd = v.cwd or vim.fn.getcwd(),
      args = v.args or {},
      stopAtEntry = v.stopAtEntry or true,
      setupCommands = v.setupCommands or {
        {
          text = '-enable-pretty-printing',
          description = 'enable pretty printing',
          ignoreFailures = false
        },
      },
    }
    table.insert(configs, config)
  end

  if #configs == 0 then
    print("No gdb config to run")
  else
    dap.configurations.cpp = configs
    dap.continue()
  end
end

local get_all_test_names_ctest = function()
  local all_tests = {};

  local output = vim.fn.system { "ctest", "--test-dir", "build", "--show-only=json-v1" }
  if output ~= "" then
    local output_json = vim.fn.json_decode(output)
    if output_json ~= nil then
      local discovered_tests = output_json.tests
      for _, test in ipairs(discovered_tests) do
        local command = test.command
        if command ~= nil then
          local name = test.name
          table.insert(all_tests, name)
        end
      end
    end
  end
  return all_tests
end

local select_test_and_debug_ctest = function()
  local dap = require "dap"
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

  local all_tests = get_all_test_names_ctest()
  if #(dap.configurations.cpp) == 1 then
    table.insert(all_tests, 1, "Run Last Test");
  end

  local set_dap_cpp_config = function(test_name)
    if test_name == "Run Last Test" then
      dap.continue()
      return
    end
    local output = vim.fn.system { "ctest", "--test-dir", "build", "--show-only=json-v1" }
    if output ~= "" then
      local output_json = vim.fn.json_decode(output)
      if output_json ~= nil then
        local discovered_tests = output_json.tests
        local dap_cpp_configs = {}
        for _, test in ipairs(discovered_tests) do
          local command = test.command
          if command ~= nil then
            local name = test.name
            if test_name == test.name then
              local properties = test.properties
              local working_dir = vim.fn.getcwd()
              local program_path = table.remove(command, 1);

              if properties ~= nil then
                for _, property in ipairs(properties) do
                  if property.name == "WORKING_DIRECTORY" then
                    working_dir = property.value
                    break
                  end
                end
              end

              local config = {
                name = "Launch test: " .. name,
                type = "cppdbg",
                request = "launch",
                program = program_path,
                cwd = working_dir,
                args = command,
                stopAtEntry = true,
                setupCommands = {
                  {
                    text = '-enable-pretty-printing',
                    description = 'enable pretty printing',
                    ignoreFailures = false
                  },
                },
              }
              table.insert(dap_cpp_configs, config)
              break
            end
          end
        end

        dap.configurations.cpp = dap_cpp_configs
        dap.continue()
      end
    end
  end

  local select_test_fuzzy = function(opts)
    opts = opts or {}
    pickers.new(opts, {
      prompt_title = "Select Test",
      finder = finders.new_table {
        results = all_tests
      },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          set_dap_cpp_config(selection[1])
        end)
        return true
      end,
    }):find()
  end

  select_test_fuzzy()
end

return {
  -- NOTE: Yes, you can install new plugins here!
  "mfussenegger/nvim-dap",
  event = "VeryLazy",
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    "folke/neoconf.nvim",
    "jay-babu/mason-nvim-dap.nvim",
    "jonboh/nvim-dap-rr",
    "nvim-neotest/nvim-nio",
    "rcarriga/nvim-dap-ui",
    "williamboman/mason.nvim",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    require("neoconf.plugins").register({
      on_schema = function(schema)
        schema:import("gdb-targets", gdb_targets_defaults)
        schema:set("myplugin.configs", {
          description = "Array of configs",
          anyOf = {
            type = "Array"
          }
        })
      end
    })

    require("mason-nvim-dap").setup({
      automatic_setup = true,
      handlers = {},
      ensure_installed = {},
    })

    dap.adapters.cppdbg = {
      id = 'cppdbg',
      type = 'executable',
      command = '/apps/homefs1/sgauvin/.local/share/nvim/mason/bin/OpenDebugAD7',
    }

    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set("n", "<F5>", function()
      if dap.session() == nil then
        if vim.bo.filetype == 'c' or vim.bo.filetype == 'cpp' then
          select_test_and_debug_ctest()
        end
      else
        dap.continue()
      end
    end, { desc = "Debug: Start/Continue" })

    vim.keymap.set("n", "<F10>", function()
      if dap.session() == nil then
        if vim.bo.filetype == 'c' or vim.bo.filetype == 'cpp' then
          run_gdb_test_from_neoconf()
        end
      end
    end, { desc = "Debug: Start/Continue" })

    vim.keymap.set("n", "<F1>", dap.step_into, { desc = "Debug: Step Into" })
    vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Debug: Step Over" })
    vim.keymap.set("n", "<F3>", dap.step_out, { desc = "Debug: Step Out" })
    vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
    vim.keymap.set("n", "<leader>B", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, { desc = "Debug: Set Breakpoint" })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup({
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
      controls = {
        icons = {
          pause = "⏸",
          play = "▶",
          step_into = "⏎",
          step_over = "⏭",
          step_out = "⏮",
          step_back = "b",
          run_last = "▶▶",
          terminate = "⏹",
          disconnect = "⏏",
        },
      },
    })

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set("n", "<F7>", dapui.toggle, { desc = "Debug: See last session result." })
    vim.keymap.set("v", "<F8>", dapui.eval)
    vim.keymap.set("n", "<F8>", dapui.eval)

    dap.listeners.after.event_initialized["dapui_config"] = dapui.open
    dap.listeners.before.event_terminated["dapui_config"] = dapui.close
    dap.listeners.before.event_exited["dapui_config"] = dapui.close
  end,
}

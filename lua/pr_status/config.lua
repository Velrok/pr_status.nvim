local M = {}
local utils = require("pr_status.utils")

local function github_cli_parser(line)
  local data = utils.split_string(line, "\t")

  local check = data[1]  -- any string
  local status = data[2] -- one off: pass, fail, pending, skipping

  return {
    line = line,
    check = check,
    status = status
  }
end

M.defaults = {
  icons = {
    gh_icon = "",
    unknown = '?',
    running = '',
    failed = '',
    passed = '',
  },
  failure_decorations = {
    left = '[',
    right = ']',
    join_string = ', ',
    separator = ' ',
  },
  gh_command = "gh pr checks",
  status_line_parser = github_cli_parser,
  auto_start = false, -- or function which returns true|false
  timer = {
    initial_delay_ms = 1000,
    regular_poll_delay_ms = 30000,
  }
}

M.options = {}

local function auto_start(val_or_fn)
  local should_start = nil

  if type(val_or_fn) == 'function' then
    should_start = val_or_fn()
  else
    should_start = val_or_fn
  end

  if should_start then
    require('pr_status').start()
  end
end

function M.setup(opts)
  M.options = vim.tbl_deep_extend(
    "force",
    M.defaults,
    opts or {}
  )

  if M.options.auto_start then
    auto_start(M.options.auto_start)
  end
end

return M

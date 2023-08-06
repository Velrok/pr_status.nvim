local M = {}

function M.setup(opts)
  require("pr_status.config").setup(opts)
end

function M.start()
  require("pr_status.pr_status").start()
end

function M.restart()
  require("pr_status.pr_status").restart()
end

function M.get_last_result_string()
  return require("pr_status.pr_status").get_last_result_string()
end

function M.get_last_result()
  return require("pr_status.pr_status").get_last_result()
end

return M

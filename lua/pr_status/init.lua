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

return M

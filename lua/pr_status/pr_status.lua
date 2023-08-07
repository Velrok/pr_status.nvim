local config = require("pr_status.config")

local M = {}

local last_result = {}

local function run_pr_check()
  vim.notify(
    'running pr check via ' .. config.options.gh_command,
    vim.log.levels.DEBUG
  )
  vim.fn.jobstart(
    config.options.gh_command,
    {
      stdout_buffered = true,
      on_stdout = function(_, lines, _)
        local results = {}
        local failures = {}

        local passed = 0
        local failed = 0
        local pending = 0

        for _, line in ipairs(lines) do
          if line ~= '' then
            local data = config.options.status_line_parser(line)

            local validation_errors = {}
            if data == nil or data.check == nil then
              table.insert(
                validation_errors,
                'parsed data must return a check as string'
              )
            end

            if data and data.status then
              if data.status ~= 'pass' and data.status ~= 'fail' and data.status ~= 'pending' then
                table.insert(
                  validation_errors,
                  'parsed data must return a status of pass, fail or pending but got:' .. data.status
                )
              end
            elseif data and data.status == nil then
              table.insert(
                validation_errors,
                'parsed data must return a status got nil'
              )
            end


            if #validation_errors > 0 then
              vim.notify(
                'validation errors for line:' .. line .. ':\n' .. table.concat(validation_errors, '\n'),
                vim.log.levels.ERROR
              )
            else
              table.insert(results, data)

              if data and data.status == 'pass' then
                passed = passed + 1
              elseif data and data.status == 'fail' then
                failed = failed + 1
                table.insert(failures, data.check)
              elseif data and data.status == 'pending' then
                pending = pending + 1
              end
            end
          end
        end

        last_result = {
          details = results,
          summary = { passed = passed, failed = failed, pending = pending },
          failures = failures,
          last_check_time = os.time()
        }
      end
    })
end

function M.start()
  -- exit if already running
  if M.timer then return end

  M.timer = vim.loop.new_timer()
  vim.notify('running regular PR checks via ' .. config.options.gh_command)
  M.timer:start(
    config.options.timer.initial_delay_ms,
    config.options.timer.regular_poll_delay_ms,
    vim.schedule_wrap(run_pr_check)
  )
end

function M.restart()
  M.stop()
  M.start()
end

function M.stop()
  vim.notify('stopped regular PR checks ')
  if M.timer then M.timer:close() end
end

function M.get_last_result()
  return last_result
end

function M.get_last_result_string()
  local pr_check_result = M.get_last_result()
  -- local pr_check_failed_test = require("plugins/pr_status").latest_check_test

  local pr_status_icons = config.options.icons
  local pr_status = '' .. pr_status_icons.gh_icon

  if pr_check_result and pr_check_result.summary then
    if pr_check_result.summary.pending > 0 then
      pr_status = pr_status
          .. " " .. pr_status_icons.running .. pr_check_result.summary.pending
    end

    pr_status = pr_status
        .. " " .. pr_status_icons.passed .. pr_check_result.summary.passed
        .. " " .. pr_status_icons.failed .. pr_check_result.summary.failed

    if pr_check_result.summary.failed > 0 then
      local decoration = config.options.failure_decorations

      pr_status = pr_status
          .. decoration.separator
          .. decoration.left
          .. table.concat(pr_check_result.failures, decoration.join_string)
          .. decoration.right
    end
  else
    pr_status = pr_status .. pr_status_icons.unknown
  end

  return pr_status
end

return M

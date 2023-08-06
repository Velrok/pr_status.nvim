local M = {}

M.split_string = function(line, separator)
  local sep = separator or "\t"
  local matches = {}
  for token in string.gmatch(line, "[^" .. sep .. "]+") do
    table.insert(matches, token)
  end
  return matches
end

return M

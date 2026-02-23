local M = {}

-- Parse date string and return relative time
function M.relative_date(date_str)
  -- Parse date format: "2026-02-20 16:30+00:00"
  local year, month, day, hour, min = date_str:match("(%d+)-(%d+)-(%d+) (%d+):(%d+)")
  if not year then
    return "unknown"
  end
  
  local email_time = os.time({
    year = tonumber(year),
    month = tonumber(month),
    day = tonumber(day),
    hour = tonumber(hour),
    min = tonumber(min),
    sec = 0
  })
  
  local now = os.time()
  local diff = os.difftime(now, email_time)
  
  local hours = math.floor(diff / 3600)
  local days = math.floor(diff / 86400)
  
  if hours < 24 then
    return string.format("%d hours ago", hours)
  elseif days == 1 then
    return "1 day ago"
  else
    return string.format("%d days ago", days)
  end
end

return M

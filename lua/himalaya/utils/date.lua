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
  local weeks = math.floor(days / 7)
  local months = math.floor(days / 30)
  local years = math.floor(days / 365)
  
  if hours < 1 then
    return "just now"
  elseif hours < 24 then
    return hours == 1 and "1 hour ago" or hours .. " hours ago"
  elseif days < 14 then
    return days == 1 and "1 day ago" or days .. " days ago"
  elseif weeks < 4 then
    return weeks == 1 and "1 week ago" or weeks .. " weeks ago"
  elseif months < 12 then
    return months == 1 and "1 month ago" or months .. " months ago"
  else
    return years == 1 and "1 year ago" or years .. " years ago"
  end
end

-- Get maximum possible width for date display
function M.max_date_width()
  -- Longest possible: "11 months ago" = 13 chars
  return 13
end

return M

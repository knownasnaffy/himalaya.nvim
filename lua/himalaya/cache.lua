local M = {}

-- Cache structure: { folder_name = { page_num = envelopes_data } }
M.envelopes = {}
M.folders = nil

function M.get_envelopes(folder, page)
	if not M.envelopes[folder] then
		return nil
	end
	return M.envelopes[folder][page]
end

function M.set_envelopes(folder, page, data)
	if not M.envelopes[folder] then
		M.envelopes[folder] = {}
	end
	M.envelopes[folder][page] = data
end

function M.get_folders()
	return M.folders
end

function M.set_folders(data)
	M.folders = data
end

function M.adjust_folder_unread(folder_name, delta)
	if not M.folders or not folder_name then
		return
	end
	for _, m in ipairs(M.folders) do
		local name = m.name or m.id
		if name and (name == folder_name or name:lower() == folder_name:lower()) then
			if m.unread and type(m.unread) == "number" then
				m.unread = math.max(0, m.unread + delta)
			elseif delta > 0 then
				m.unread = delta
			end
			break
		end
	end
end

function M.clear()
	M.envelopes = {}
	M.folders = nil
end

return M

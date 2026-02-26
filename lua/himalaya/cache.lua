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

function M.clear()
	M.envelopes = {}
	M.folders = nil
end

return M

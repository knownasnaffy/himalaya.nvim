local date_utils = require("himalaya.utils.date")

describe("Date Utils", function()
	it("parses ISO 8601 timestamps with T separator and Z", function()
		local rel = date_utils.relative_date("2026-09-03T01:10:53Z")
		assert.truthy(rel ~= "unknown", "expected parsed relative date, got unknown")
	end)

	it("parses ISO 8601 with timezone offset", function()
		local rel = date_utils.relative_date("2026-09-03T01:10:53+00:00")
		assert.truthy(rel ~= "unknown")
	end)

	it("handles nil safely", function()
		local rel = date_utils.relative_date(nil)
		assert.equals("unknown", rel)
	end)
end)

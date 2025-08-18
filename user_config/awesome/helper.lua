local naughty = require("naughty")

get_os_name = function()
	local f = io.popen("uname -s")
	local result = f:read("*all")
	f:close()
	return { result:gsub("\n", "") }
end

print_awesome_tree = function()
	local result = {}

	for s in screen do
		table.insert(result, string.format("🖥️ Screen %d", s.index))

		for _, t in ipairs(s.tags) do
			if t.selected then
				table.insert(result, string.format("  🟢 Tag: %s", t.name))
			else
				table.insert(result, string.format("  🔘 Tag: %s", t.name))
			end

			local clients = t:clients()
			for _, c in ipairs(clients) do
				table.insert(
					result,
					string.format("    🪟 Client: %s (class: %s)", c.name or "N/A", c.class or "N/A")
				)
			end
		end
	end

	local output = table.concat(result, "\n")
	   naughty.notify({
	       title = "AwesomeWM Tree",
	       text = output,
	       timeout = 10,
	       width = 600,
		   height = 600,
	   })

	-- Also print to console for debugging
	print(output)
end

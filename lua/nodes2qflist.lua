local plugin_name = "nodes2qflist"
local log_prefix = type(vim.notify) == "table" and "" or ("[%s] "):format(plugin_name)

--- # Private ----------------------------------------------------------------------------------------------------------

--- ## Helpers --------------------------------------------------------------------------

local function sized_string(value)
	return type(value) == "string" and #value > 0
end

local function sized_table(value)
	return type(value) == "table" and next(value) ~= nil
end

local function warning(message)
	if not sized_string(message) then
		message = "Nothing to log. 'message' must be a non-empty string."
	end
	vim.notify(log_prefix .. message, vim.log.levels.WARN, { title = plugin_name })
end

--- ## Core -----------------------------------------------------------------------------

local function ranges2qflist(ranges)
	if not sized_table(ranges) then
		return warning("Unable to set the qflist. 'ranges' must be a non-empty table.")
	end

	local start_row, start_col, line
	local qf_list = {}

	for range_num, range in ipairs(ranges) do
		start_row, start_col = unpack(range)
		line = vim.fn.getline(start_row + 1)

		qf_list[range_num] = {
			text = line,
			bufnr = vim.api.nvim_get_current_buf(),
			lnum = start_row + 1,
			col = start_col + 1,
			end_col = start_col + line:len(),
		}
	end

	if sized_table(qf_list) then
		vim.fn.setqflist(qf_list)
		vim.cmd.copen()
	end
end

local function find_nodes_ranges(parent_node, source, query, capture_name)
	local nodes = {}

	for _, match, _ in query:iter_matches(parent_node, source, 0, vim.fn.line("$")) do
		for id, node in pairs(match) do
			local curr_capture_name = query.captures[id]
			if capture_name == curr_capture_name then
				table.insert(nodes, { node:range() })
			end
		end
	end

	return nodes
end

local function get_root_node(buf_nr, lang)
	local parser = vim.treesitter.get_parser(buf_nr, lang)
	local trees = parser:parse()
	return trees[1]:root()
end

local function get_query_from_file(lang, query_name)
	local _, query = pcall(vim.treesitter.get_query, lang, query_name)
	if sized_table(query) then
		return query
	end
end

local function get_nodes_ranges(capture_name)
	if not sized_string(capture_name) then
		return warning("Unable to get nodes. 'capture_name' must be a non-empty string.")
	end
	capture_name = capture_name:gsub("^@", "")

	local buf_nr = vim.api.nvim_get_current_buf()
	local lang = vim.api.nvim_buf_get_option(buf_nr, "filetype")

	local query = get_query_from_file(lang, plugin_name)
	if not query then
		return warning(("Unable to get nodes. No query found for '%s'"):format(lang))
	end

	local root = get_root_node(buf_nr, lang)
	return find_nodes_ranges(root, buf_nr, query, capture_name)
end

--- # Public -----------------------------------------------------------------------------------------------------------

local M = {}

function M.search(capture_name)
	local ranges = get_nodes_ranges(capture_name)
	if not sized_table(ranges) then
		return warning(("No nodes found for '%s'"):format(capture_name))
	end

	ranges2qflist(ranges)
end

return M

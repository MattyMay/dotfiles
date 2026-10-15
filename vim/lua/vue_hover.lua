-- Volar's rich hover (vue.hover.rich) lists a component's props, events,
-- slots and exposed members as an HTML <table>, which VS Code renders but
-- nvim's markdown hover float shows as raw tags. This rewrites it as markdown.
local M = {}

local plural = { Prop = "Props", Event = "Events", Slot = "Slots" }

local function code(s)
  s = vim.trim(s:gsub("%s+", " "))
  -- Template literal types contain backticks; a double-backtick span holds them.
  return s:find("`") and ("`` " .. s .. " ``") or ("`" .. s .. "`")
end

-- "name <sup><em>required</em></sup>", with <del> around deprecated names.
local function name_md(cell)
  local name, tags = cell:match("^%s*(.-)%s*(<sup>.*)$")
  name = name or vim.trim(cell)
  local deprecated = name:match("^<del>(.-)</del>$")
  local md = deprecated and ("~~" .. code(deprecated) .. "~~") or code(name)
  for tag in (tags or ""):gmatch("<em>(.-)</em>") do
    md = md .. " *(" .. tag .. ")*"
  end
  return md
end

-- "<code>type</code>", or "\n\ndescription<br><code>type</code>".
local function description_md(cell)
  local text, type_ = cell:match("^(.*)<br>%s*<code>(.-)</code>%s*$")
  if not text then
    text, type_ = "", cell:match("<code>(.-)</code>") or ""
  end
  return vim.trim(text), type_
end

--- Returns `html` (a rich hover's markdown value) as markdown lists, or nil
--- if it isn't a rich hover table.
function M.to_markdown(html)
  if not html:match("^%s*<table>") then
    return nil
  end
  local out = {}
  for row in html:gmatch("<tr>(.-)</tr>") do
    local heading = row:match("<th[^>]*>(.-)</th>")
    local cells = {}
    for cell in row:gmatch("<td[^>]*>(.-)</td>") do
      table.insert(cells, cell)
    end
    if heading then
      if #out > 0 then
        table.insert(out, "")
      end
      table.insert(out, "**" .. (plural[heading] or heading) .. "**")
    elseif #cells > 0 then
      local text, type_ = description_md(cells[2] or "")
      local item = "- " .. name_md(cells[1]) .. ": " .. code(type_)
      local default = cells[3] and cells[3]:match("<code>(.-)</code>")
      if default then
        item = item .. " = " .. code(default)
      end
      table.insert(out, item)
      if text ~= "" then
        for line in vim.gsplit(text, "\n") do
          table.insert(out, line == "" and "" or ("  " .. line))
        end
      end
    end
  end
  return #out > 0 and table.concat(out, "\n") or "No type information available."
end

--- Wraps an LSP rpc client so its hover responses get rich tables rewritten.
function M.wrap_rpc(rpc)
  local request = rpc.request
  function rpc.request(method, params, callback, ...)
    if method == "textDocument/hover" then
      local inner = callback
      callback = function(err, result, ...)
        local value = vim.tbl_get(result or {}, "contents", "value")
        local md = type(value) == "string" and M.to_markdown(value)
        if md then
          result.contents.value = md
        end
        return inner(err, result, ...)
      end
    end
    return request(method, params, callback, ...)
  end
  return rpc
end

return M

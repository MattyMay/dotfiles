-- Byte-compiles every Lua config file to catch syntax errors without needing
-- any plugins installed. Run with: nvim --headless --clean -c 'luafile lint.lua'
-- Expects $REPO_ROOT in the environment.

-- Write + flush each line immediately so output streams one by one, even when
-- stdout is buffered (CI logs, pipes), and the last line is never swallowed by :qa.
local function emit(line)
  io.stdout:write(line .. "\n")
  io.stdout:flush()
end

local root = assert(vim.env.REPO_ROOT, "REPO_ROOT not set")
local files = vim.fn.glob(root .. "/vim/lua/**/*.lua", false, true)
table.sort(files)

local errors = 0
for _, file in ipairs(files) do
  local chunk, err = loadfile(file)
  if chunk then
    emit("ok   - " .. file)
  else
    emit("FAIL - " .. file .. "\n       " .. err)
    errors = errors + 1
  end
end

emit(("\n%d file(s) failed to compile"):format(errors))
vim.cmd(errors > 0 and "cq" or "qa")

-- Byte-compiles every Lua config file to catch syntax errors without needing
-- any plugins installed. Run with: nvim --headless --clean -c 'luafile lint.lua'
-- Expects $REPO_ROOT in the environment.

local root = assert(vim.env.REPO_ROOT, "REPO_ROOT not set")
local files = vim.fn.glob(root .. "/vim/lua/**/*.lua", false, true)
table.sort(files)

local errors = 0
for _, file in ipairs(files) do
  local chunk, err = loadfile(file)
  if chunk then
    print("ok   - " .. file)
  else
    print("FAIL - " .. file .. "\n       " .. err)
    errors = errors + 1
  end
end

print(("\n%d file(s) failed to compile"):format(errors))
vim.cmd(errors > 0 and "cq" or "qa")

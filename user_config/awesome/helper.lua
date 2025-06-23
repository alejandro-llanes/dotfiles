
get_os_name = function()
  local f = io.popen("uname -s")
  local result = f:read("*all")
  f:close()
  return { result:gsub("\n", "") }
end

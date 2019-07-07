
function read_capabilities()
  local capabilities_file = nixio.open("/capabilities.json", "r")
  local file_size = capabilities_file:stat("size")
  local read_buffer = capabilities_file:read(file_size)
  local tasks = (luci.jsonc.parse(read_buffer))["ietf-lmap-control:lmap"]["capabilities"]["tasks"]["task"]
  local capabilities_list = {}
  for key, val in pairs(tasks) do
    table.insert(capabilities_list, val['name'])
  end
  return capabilities_list
end

function read_tasks_list()
  local cur = uci.cursor()
  local tasks_list = cur.get("lmapd", "task_lists", "name")
  return tasks_list

capabilities = read_capabilities()
tasks = read_tasks_list()

m = Map("lmapd", "LMAP Daemon")
for i, val in pairs(tasks) do
  
end

return m

function update_uci_from_json()

end

function read_capabilities_json()
  local capabilities_file = nixio.open("/capabilities.json", "r")
  local file_size = capabilities_file:stat("size")
  local read_buffer = capabilities_file:read(file_size)
  local tasks = (luci.jsonc.parse(read_buffer))["ietf-lmap-control:lmap"]["capabilities"]["tasks"]["task"]
  local capabilities_list = {}
  for key, val in pairs(tasks) do
    table.insert(capabilities_list, val)
  end
  return capabilities_list
end

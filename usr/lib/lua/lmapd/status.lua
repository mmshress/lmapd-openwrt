local status = {

}

function status.read_status_json()
    if status.get_lmapd_status() then
      local n = require "nixio"
      local jc = require "luci.jsonc"
      local status_file = n.open("/var/run/lmapd-state.json", "r")
      if status_file ~= nil then
        local json_buffer = status_file:read(status_file:stat("size"))
        local parsed_json = jc.parse(json_buffer)
        return parsed_json
      end
    end
    return nil
end

function status.get_lmapd_status()
  local fs = require "nixio.fs"
  luci.sys.call("lmapctl.sh status > /dev/null") --to generate the status file
  local state_file = fs.access("/var/run/lmapd-state.json")
  if state_file then return true else return false end
end

return status

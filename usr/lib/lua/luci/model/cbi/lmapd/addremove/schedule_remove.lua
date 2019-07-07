function get_schedules_list()
  local uci = require "uci"
  local cur = uci:cursor()
  local schedules_list = {}
  cur:foreach("lmapd", "schedule",
  function (section)
    table.insert(schedules_list, section['.name'])
  end
  )
  return schedules_list
end

f = SimpleForm("lmapd", "Remove a schedule")

f.redirect = luci.dispatcher.build_url("schedules")
f.reset = false
f.submit = "Remove"

del = f:field(ListValue, "_schedule_to_delete", "Schedule to remove")
schedules_list = get_schedules_list()
for _, schedule_name in pairs(schedules_list) do
  del:value(schedule_name)
end

function f.handle(self, state, data)
  if state == FORM_VALID then
    local name_to_delete = data._schedule_to_delete
    local uci = require "uci".cursor()
    uci:delete("lmapd", name_to_delete)
    uci:save("lmapd")
    uci:commit("lmapd")
    luci.http.redirect(luci.dispatcher.build_url("admin/lmapd/schedules"))
  end
  return true
end

return f

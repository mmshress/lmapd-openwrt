f = SimpleForm("lmapd", "Remove an Event")

f.redirect = luci.dispatcher.build_url("admin/lmapd/events")
f.reset=false
f.submit="Remove"

del = f:field(ListValue, "_event_to_delete", "Event to delete", "")

uci = require "uci".cursor()
events_list = uci:get("lmapd", "events", "event_names")
for _, event_name in pairs(events_list) do
  del:value(event_name)
end

function f.handle(self, state, data)
  if state == FORM_VALID then
    local name_to_delete = data._event_to_delete
    local uci = require "uci".cursor()
    local events_list = uci:get("lmapd", "events", "event_names")
    for idx, event_name in pairs(events_list) do
      if event_name == name_to_delete then
        idx_to_delete = idx
      end
    end
    table.remove(events_list, idx_to_delete)
    uci:set("lmapd", "events", "event_names", events_list)
    uci:delete("lmapd", name_to_delete)
    uci:save("lmapd")
    uci:commit("lmapd")
    luci.http.redirect(luci.dispatcher.build_url("admin/lmapd/events"))
  end
  return true
end

return f

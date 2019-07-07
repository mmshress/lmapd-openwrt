f = SimpleForm("lmapd", "Remove a Task Option")

f.redirect = luci.dispatcher.build_url("admin/lmapd/options")
f.reset=false
f.submit="Remove"

del = f:field(ListValue, "_option_to_delete", "Option to delete", "")

uci = require "uci".cursor()
uci:foreach("lmapd", "task_option",
function(s)
  del:value(s['.name'])
end)

function f.handle(self, state, data)
  if state == FORM_VALID then
    local name_to_delete = data._option_to_delete
    local uci = require "uci".cursor()
    uci:delete("lmapd", name_to_delete)
    uci:save("lmapd")
    uci:commit("lmapd")
    luci.http.redirect(luci.dispatcher.build_url("admin/lmapd/options"))
  end
  return true
end

return f

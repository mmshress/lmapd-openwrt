function get_actions_list()
  local uci = require "uci"
  local cur = uci:cursor()
  local actions_list = {}
  cur:foreach("lmapd", "action",
  function (section)
    table.insert(actions_list, section['.name'])
  end
  )
  return actions_list
end

f = SimpleForm("lmapd", "Remove an Action")

f.redirect = luci.dispatcher.build_url("admin/lmapd/actions")
f.reset=false
f.submit="Remove"

del = f:field(ListValue, "_action_to_delete", "Action to delete", "")

actions_list = get_actions_list()
for _, action_name in pairs(actions_list) do
  del:value(action_name)
end

function f.handle(self, state, data)
  if state == FORM_VALID then
    local name_to_delete = data._action_to_delete
    local uci = require "uci".cursor()
    uci:delete("lmapd", name_to_delete)
    uci:save("lmapd")
    uci:commit("lmapd")
    luci.http.redirect(luci.dispatcher.build_url("admin/lmapd/actions"))
  end
  return true
end

return f

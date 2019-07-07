f = SimpleForm("lmapd", "Remove a quick measurement task")

f.reset=false
f.submit="Remove"

del = f:field(ListValue, "_task_to_delete", "Task to delete", "")

uci = require "uci".cursor()
local quick_tasks_list = uci:get("lmapd", "quick_tasks", "task_names")
if quick_tasks_list ~= nil then
  for _, task_name in ipairs(quick_tasks_list) do
    del:value(task_name)
  end
end

function f.handle(self, state, data)
  if state == FORM_VALID then
    local name = data._task_to_delete
    local uci = require "uci".cursor()

    uci:delete("lmapd", "quick_option_" .. name .. "_ping_count")
    uci:delete("lmapd", "quick_option_" .. name .. "_ping_intvl")
    uci:delete("lmapd", "quick_option_" .. name .. "_ping_size")
    uci:delete("lmapd", "quick_option_" .. name .. "_tracert_max_hops")
    uci:delete("lmapd", "quick_option_" .. name .. "_tracert_numeric")

    uci:delete("lmapd", "quick_action_" .. name)
    uci:delete("lmapd", "quick_event_" .. name)
    uci:delete("lmapd", "quick_schedule_" .. name)

    uci:save("lmapd")
    uci:commit("lmapd")
    luci.http.redirect(luci.dispatcher.build_url("admin/lmapd/overview"))
  end
  return true
end

return f

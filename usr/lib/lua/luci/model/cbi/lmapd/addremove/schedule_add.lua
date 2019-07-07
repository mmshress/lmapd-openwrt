local uci = require "uci".cursor()

f = SimpleForm("lmapd", "Add Schedule")
f.redirect = luci.dispatcher.build_url("admin/lmapd/schedules")
f.reset = false
f.submit = "Add"

schedule_name = f:field(Value, "_schedule_name", "Name of the schedule", "")
schedule_name.datatype = "uciname"

sched_start = f:field(ListValue, "_schedule_start", "Start event of the schedule", "Event must be in config")
uci.foreach("lmapd", "event",
function(s)
  sched_start:value(s['.name'])
end
)

exec_mode = f:field(ListValue, "_execution_mode", "Execution mode of the schedule", "Sequential, Parallel or Pipelined")
exec_mode:value("sequential")
exec_mode:value("parallel")
exec_mode:value("pipelined")

actions = f:field(DynamicList, "_actions", "Actions that the schedule triggers", "Must be actions in the config")
function actions:validate(value)
  if value == nil then
    return nil, "Action list cannot be empty"
  end
  for _, action in pairs(value) do
    local uci = require "uci":cursor()
    local action_in_uci = uci:get("lmapd", action)
    if action_in_uci ~= "action" then
      return nil, "Action triggered must be in config"
    end
  end
  return value
end

function f.handle(self, state, data)
  if state == FORM_VALID then
    local name = data._schedule_name
    local schedule_table = {}
    schedule_table['name'] = name
    schedule_table['start'] = data._schedule_start
    schedule_table['execution_mode'] = data._execution_mode
    schedule_table['action'] = data._action
    local json_to_uci = require "lmapd.json_to_uci"
    json_to_uci.add_schedule_uci(schedule_table)
    luci.http.redirect(luci.dispatcher.build_url("admin/lmapd/schedules"))
  end
  return true
end

return f

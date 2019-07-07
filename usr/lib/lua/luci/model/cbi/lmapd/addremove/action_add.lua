local uci = require "uci".cursor()

f = SimpleForm("lmapd", "Add Event")
f.redirect = luci.dispatcher.build_url("admin/lmapd/actions")
f.reset = false
f.submit = "Add"

action_name = f:field(Value, "_action_name", "Name of the action", "")
action_name.datatype = "uciname"
function action_name:validate(value)
  local uci = require "uci":cursor()
  local type = uci:get("lmapd", value)
  if type ~= nil then
    return nil, "The name is already in use for a section of type " .. type
  else
    return value
  end
end

action_task = f:field(ListValue, "_action_task", "Task that the action triggers", "")
uci.foreach("lmapd", "task",
function(s)
  action_task:value(s['.name'])
end
)

report_action = f:field(Flag, "_report_action", "Report Action", "Report actions don't have destination schedules")
action_destinations = f:field(DynamicList, "_action_destination", "Destinations for the action", "Destination must be a schedule name in the config")
action_destinations:depends("_report_action", "")
function action_destinations:validate(value)
  for _, a in pairs(value) do
    local found = true
    local uci = require "uci".cursor()
    local schedule = uci:get("lmapd", a, "name")
    if schedule == nil then
      return nil, "Destination schedule must be in config"
    end
  end
  return value
end

options = f:field(DynamicList, "_task_options", "Task options for the action")
function options:validate(value)
  for idx, option_name in pairs(value) do
    local uci = require "uci".cursor()
    local task_option = uci:get("lmapd", option_name, "id")
    if task_option == nil then
      return nil, "Option not found in config, add option first"
    end
  end
  return value
end

host_name = f:field(Value, "_host_name", "Host name / IP Address of the target")
host_name.datatype="or(hostname, ipaddr)"

function f.handle(self, state, data)
  if state == FORM_VALID then
    local name = data._action_name
    local action_table = {}
    action_table['name'] = name
    action_table['task'] = data._action_task
    action_table['destination'] = data._action_destination
    action_table['option'] = data._task_options
    action_table['hostname'] = data._host_name
    local json_to_uci = require "lmapd.json_to_uci"
    json_to_uci.add_action_to_actions_list(name)
    json_to_uci.add_action_uci(action_table)
    luci.http.redirect(luci.dispatcher.build_url("admin/lmapd/actions"))
  end
  return true
end

return f

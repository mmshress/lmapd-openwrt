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

function get_schedules_list()
  local uci = require "uci"
  local cur = uci:cursor()
  local scheds_list = {}
  cur:foreach("lmapd", "schedule",
  function (section)
    table.insert(scheds_list, section['.name'])
  end
  )
  return scheds_list
end

m = Map("lmapd", "Actions")


local json_to_uci = require "lmapd.json_to_uci"
capabilities_list = json_to_uci.read_tasks_list()
actions_list = get_actions_list()
action_sections = {}
for idx, action_name in pairs(actions_list) do
  action_sections[idx] = m:section(NamedSection, action_name, "action", action_name, "")
end

for idx, action_section in pairs(action_sections) do
  task_opt = action_section:option(ListValue, "task", "Measurement task the action triggers")
  for _, task_name in pairs(capabilities_list) do
    task_opt:value(task_name)
  end

  destination_flag = action_section:option(Flag, "report_action", "Report Action", "Report actions don't have destinations")
  destination = action_section:option(DynamicList, "destination", "Destination",
                        "Destination schedule, must be a schedule in the config")
   destination:depends("report_action", "")
  function destination:validate(value)
    if value == nil then
      return nil, "Destination schedule required"
    end
    for _, a in pairs(value) do
      local found = true
      local uci = require "uci".cursor()
      local schedule = uci:get("lmapd", a) -- gets type name
      if schedule ~= "schedule" then
        return nil, "Destination schedule must be in config"
      end
    end
    return value
  end

  options = action_section:option(DynamicList, "task_options", "Task options for the action")
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
  host_name = action_section:option(Value, "host_name", "Host name or IP address of target")
  host_name:depends("report_action", "")
  host_name.datatype = "or(hostname, ipaddr)"

end

local num_actions = require "lmapd.uci_to_json".get_table_length(action_sections)
btn_add = action_sections[num_actions]:option(Button, "_btn_add", "Add New Action")
function btn_add.write()
  luci.http.redirect(luci.dispatcher.build_url("admin/lmapd/action_add"))
end

btn_remove=action_sections[num_actions]:option(Button, "_btn_remove", "Remove Action")
function btn_remove.write()
  luci.http.redirect(luci.dispatcher.build_url("admin/lmapd/action_remove"))
end

return m

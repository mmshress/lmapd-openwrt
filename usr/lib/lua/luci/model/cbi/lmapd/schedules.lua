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

function get_events_list()
  local uci = require "uci"
  local cur = uci:cursor()
  local events_list = {}
  cur:foreach("lmapd", "event",
  function (section)
    table.insert(events_list, section['.name'])
  end
  )
  return events_list
end

m = Map("lmapd", "Schedules")

local json_to_uci = require "lmapd.json_to_uci"
scheds_list = get_schedules_list()
events_list = get_events_list()
schedule_sections = {}
for idx, sched_name in pairs(scheds_list) do
  schedule_sections[idx] = m:section(NamedSection, sched_name, "schedule", sched_name, "")
end

for idx, sched_section in pairs(schedule_sections) do
  schedule_start = sched_section:option(ListValue, "start", "Start event reference", "Must be a valid event in the config")
  for _, event_name in pairs(events_list) do
    schedule_start:value(event_name)
  end

  exec_mode = sched_section:option(ListValue, "execution_mode", "Execution mode of the schedule", "Sequential, Parallel or Pipelined")
  exec_mode:value("sequential")
  exec_mode:value("parallel")
  exec_mode:value("pipelined")


  actions = sched_section:option(DynamicList, "action", "Actions that the schedule triggers", "Must be actions in the config")
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
end

local num_scheds = require "lmapd.uci_to_json".get_table_length(schedule_sections)
btn_add = schedule_sections[num_scheds]:option(Button, "_btn_add", "Add New Schedule")
function btn_add.write()
  luci.http.redirect(luci.dispatcher.build_url("admin/lmapd/schedule_add"))
end

btn_remove=schedule_sections[num_scheds]:option(Button, "_btn_remove", "Remove Schedule")
function btn_remove.write()
  luci.http.redirect(luci.dispatcher.build_url("admin/lmapd/schedule_remove"))
end

return m

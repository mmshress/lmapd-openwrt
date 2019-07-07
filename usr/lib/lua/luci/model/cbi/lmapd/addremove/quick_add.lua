local uci = require "uci".cursor()

--"task" here does not refer to the task node in the LMAP data model
f = SimpleForm("lmapd", "Quick add a task")

f.redirect = luci.dispatcher.build_url("admin/lmapd/overview")
f.reset=false
f.submit="Add"


name = f:field(Value, "_name", "Generic name of the task", "Generated action will be named quick_action_*, event named quick_event_* and so on")
name.datatype="uciname"
function name:validate(value)
  local event_name = "quick_event_" .. value
  local action_name = "quick_action_" .. value
  local schedule_name = "quick_schedule_" .. value
  if uci:get("lmapd", event_name, "name") ~= nil then
    return nil, "An event named ".. event_name .. " already exists in the config"
  elseif uci:get("lmapd", action_name, "name") ~= nil then
    return nil, "An action named ".. action_name .. " already exists in the config"
  elseif uci:get("lmapd", schedule_name, "name") ~= nil then
      return nil, "A schedule named " .. schedule_name .. " already exists in the config"
  end
  return value
end

action_task = f:field(ListValue, "_action_task", "Which measurement task should be scheduled?", "")
uci:foreach("lmapd", "task",
function(s)
  local task_name = s['.name']
  action_task:value(task_name)
end
)

task_timing = f:field(ListValue, "_event_type", "The timing of the task to be triggered", "")
task_timing:value("periodic")
task_timing:value("calendar")
task_timing:value("one-off")
task_timing:value("immediate")

event_interval = f:field(Value, "_interval", "Interval", "Interval for periodic invocation")
event_interval:depends("_event_type", "periodic")

event_oneoff_time = f:field(Value, "_one_off_time", "Time for one off invocation", "")
event_oneoff_time:depends("_event_type", "one-off")
event_oneoff_time.template="lmapd/datetimepickeradd"

monthAllFlag = f:field(Flag, "_calendar_month_all", "All months", "")
monthAllFlag:depends({_event_type = "calendar"})
month = f:field(DynamicList, "_calendar_month", "Month", "1-12 valid values")
month:depends({_event_type = "calendar", _calendar_month_all = ""})

day_of_week_all_flag = f:field(Flag, "_calendar_day_of_week_all", "All days of the week", "")
day_of_week_all_flag:depends("_event_type", "calendar")
day_of_week = f:field(DynamicList, "_calendar_day_of_week", "Day of Week", "1-7 valid values")
day_of_week.datatype = "range(1,7)"
day_of_week:depends({_event_type = "calendar", _calendar_day_of_week_all = ""})

day_of_month_all_flag = f:field(Flag, "_calendar_day_of_month_all", "All days of the month", "")
day_of_month_all_flag:depends("_event_type", "calendar")
day_of_month = f:field(DynamicList, "_calendar_day_of_month", "Day of Month", "1-30 valid values")
day_of_month.datatype = "range(1, 30)"
day_of_month:depends({_event_type = "calendar", _calendar_day_of_month_all = ""})

every_hour_flag = f:field(Flag, "_calendar_every_hour", "Every hour", "")
every_hour_flag:depends("_event_type", "calendar")
hour = f:field(DynamicList, "_calendar_hour", "Hour", "0-23 valid range")
hour.datatype = "range(0, 23)"
hour:depends({_event_type = "calendar", _calendar_every_hour = ""})

every_minute_flag = f:field(Flag, "_calendar_every_minute", "Every minute", "")
every_minute_flag:depends("_event_type", "calendar")
minute = f:field(DynamicList, "_calendar_minute", "Minute", "0-59 valid range")
minute.datatype = "range(0, 59)"
minute:depends({_event_type = "calendar", _calendar_every_minute = ""})

every_second_flag = f:field(Flag, "_calendar_every_second", "Every second", "")
every_second_flag:depends("_event_type", "calendar")
second = f:field(DynamicList, "_calendar_second", "Second", "0-59 valid range")
second.datatype = "range(0, 59)"
second:depends({_event_type = "calendar", _calendar_every_second = ""})

host_name = f:field(Value, "_host_name", "Host name / IP Address of the target")
host_name.datatype="or(hostname, ipaddr)"

ping_count = f:field(Value, "_ping_count", "Number of pings to send")
ping_count.datatype = "uinteger"
ping_count:depends("_action_task", "ping")

ping_size = f:field(Value, "_ping_pkt_size", "Size of each ping packet")
ping_size.datatype = "uinteger"
ping_size:depends("_action_task", "ping")

ping_interval = f:field(Value, "_ping_interval", "Interval between pings")
ping_interval.datatype = "uinteger"
ping_interval:depends("_action_task", "ping")

tracert_max_hops = f:field(Value, "_tracert_max_hops", "Max number of hops")
tracert_max_hops.datatype = "uinteger"
tracert_max_hops:depends("_action_task", "traceroute")

tracert_numeric = f:field(Flag, "_tracert_numeric", "Numeric addresses")
tracert_numeric:depends("_action_task", "traceroute")

function f.handle(self, state, data)
  if state == FORM_VALID then
    local json_to_uci = require "lmapd.json_to_uci"
    local name = data._name
    local action_table = {}
    local event_table = {}
    local schedule_table = {}
    local options_list = {}

    if(data._action_task == "ping") then
      ping_count_option = {}
      ping_interval_option = {}
      ping_size_option = {}
      if(data._ping_count ~= nil) then
      ping_count_option['id'] = "quick_option_" .. name .. "_ping_count"
      ping_count_option['name'] = "-c"
      ping_count_option['value'] = tonumber(data._ping_count)
      table.insert(options_list, "quick_option_" .. name .. "_ping_count")
      json_to_uci.add_option_uci(ping_count_option)
      end
      if(data._ping_interval ~= nil) then
        ping_interval_option['id'] = "quick_option_" .. name .. "_ping_intvl"
        ping_interval_option['name'] = "-i"
        ping_interval_option['value'] = tonumber(data._ping_interval)
        table.insert(options_list, "quick_option_" .. name .. "_ping_intvl")
        json_to_uci.add_option_uci(ping_interval_option)
      end
      if(data._ping_size ~= nil) then
        ping_size_option['id'] = "quick_option_" .. name .. "_ping_size"
        ping_interval_option['name'] = '-i'
        ping_interval_option['value'] = tonumber(data._ping_pkt_size)
        table.insert(options_list, "quick_option_" .. name .. "_ping_size")
        json_to_uci.add_option_uci(ping_size_option)
      end
    end
    if(data._action_task == "traceroute") then
      tracert_max_hops_option = {}
      tracert_numeric_option = {}
      if(data._tracert_max_hops ~= nil) then
        tracert_max_hops_option['id'] = "quick_option_" .. name .. "tracert_max_hops"
        tracert_max_hops_option['name'] = "-m"
        tracert_max_hops_option['value'] = tonumber(data._tracert_max_hops)
        table.insert(options_list, "quick_option_" .. name .. "_tracert_max_hops")
        json_to_uci.add_option_uci(tracert_max_hops)
      end
      if(data._tracert_numeric == '1') then
        tracert_numeric_option['id'] = "quick_option_" .. name .. "tracert_numeric"
        tracert_numeric_option['name'] = "-n"
        table.insert(options_list, "quick_option_" .. name .. "_tracert_numeric")
        json_to_uci.add_option_uci(tracert_numeric)
      end
    end

    action_table['name'] = "quick_action_" .. name
    action_table['task'] = data._action_task
    action_table['destination'] = "report_primary"
    action_table['hostname'] = data._host_name
    action_table['option'] = options_list

    event_table['name'] = "quick_event_" .. name
    local event_type = data._event_type
    if event_type ~= nil then
      event_table['event-type'] = event_type
    end
    if event_type == "periodic" then
      event_table['periodic'] = {}
      local interval = data._interval
      if interval ~= nil then
        event_table['periodic']['interval'] = tonumber(interval)
      end
    elseif event_type == "calendar" then
      event_table['calendar'] = {}
      if data._calendar_month_all == "1" then
        event_table['calendar']['month'] = {}
        event_table['calendar']['month'][1] = "*"
      else
        event_table['calendar']['month'] = data._calendar_month
      end
      if data._calendar_day_of_week_all == "1" then
        event_table['calendar']['day-of-week'] = {}
        event_table['calendar']['day-of-week'][1] = "*"
      else
        event_table['calendar']['day-of-week'] = data._calendar_day_of_week
      end
      if data._calendar_day_of_month_all == "1" then
        event_table['calendar']['day-of-month'] = {}
        event_table['calendar']['day-of-month'][1] = "*"
      else
        event_table['calendar']['day-of-month'] = data._calendar_day_of_month
      end
      if data._calendar_every_hour == '1' then
        event_table['calendar']['hour'] = {}
        event_table['calendar']['hour'][1] = "*"
      else
        event_table['calendar']['hour'] = data._calendar_hour
      end
      if data._calendar_every_minute == '1' then
        event_table['calendar']['minute'] = {}
        event_table['calendar']['minute'][1] = "*"
      else
        event_table['calendar']['minute'] = data._calendar_minute
      end
      if data._calendar_every_second == '1' then
        event_table['calendar']['second'] = {}
        event_table['calendar']['second'][1] = "*"
      else
        event_table['calendar']['second'] = data._calendar_second
      end
    elseif event_type == "one-off" then
        event_table['one-off'] = {}
        if data._one_off_time ~= nil then
          event_table['one-off']['time'] = data._one_off_time
        end
    end

    schedule_table['name'] = "quick_schedule_" .. name
    schedule_table['start'] = 'quick_event_' .. name
    schedule_table['execution_mode'] = 'sequential'
    schedule_table['action'] = 'quick_action_' .. name

    json_to_uci.add_quick_task_to_list(name)
    json_to_uci.add_action_uci(action_table)
    json_to_uci.add_event_uci(event_table)
    json_to_uci.add_schedule_uci(schedule_table)
    luci.http.redirect(luci.dispatcher.build_url("admin/lmapd/overview"))
  end
end

return f

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

m = Map("lmapd", "LMAP Daemon")

--list of events by name
events_list = get_events_list()
event_sections = {}
for i, val in pairs(events_list) do
  event_sections[i] = m:section(NamedSection, val, "event", val, "")
end

for i, section in pairs(event_sections) do
  section.anonymous=false
  section.addremove=false
  local uci = require "uci"
  local cur = uci:cursor()
  local event_type = cur:get("lmapd", events_list[i], "event_type")
  local random_spread = cur:get("lmapd", events_list[i], "random_spread")
  local cycle_interval = cur:get("lmapd", events_list[i], "cycle_interval")
  if random_spread ~= nil then section:option(Value, "random_spread", "Random Spread", "") end
  if cycle_interval ~= nil then section:option(Value, "cycle_interval", "Cycle Interval", "") end
  if event_type == '0' then --periodic
    section:option(Value, "interval", "Interval between invocations", "")
  elseif event_type == '1' then
    section:option(DynamicList, "month", "Months for invocations", "")
    section:option(DynamicList, "day_of_month", "Days of the month for invocations", "")
    section:option(DynamicList, "day_of_week", "Days of the week for invocations", "")
    section:option(DynamicList, "hour", "Hour of time of invocation", "")
    section:option(DynamicList, "minute", "Minute of time of invocation", "")
    section:option(DynamicList, "second", "Second of time of invocation", "")
  elseif event_type == "2" then -- one-off
    t = section:option(Value, "time", "Time for one-off invocation", "")
    t.template = "lmapd/datetimepicker"
    --functionality for other events to do
  end
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

btn_add = event_sections[tablelength(event_sections)]:option(Button, "_add_event", "Add New Event")
function btn_add.write()
  luci.http.redirect(luci.dispatcher.build_url("admin/lmapd/event_add"))
end

btn_remove = event_sections[tablelength(event_sections)]:option(Button, "_remove_event", "Remove an event")
function btn_remove.write()
  luci.http.redirect(luci.dispatcher.build_url("admin/lmapd/event_remove"))
end

return m

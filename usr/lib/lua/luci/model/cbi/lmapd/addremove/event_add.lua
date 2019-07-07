local uci = require "uci".cursor()

f = SimpleForm("lmapd", "Add Event")
f.redirect = luci.dispatcher.build_url("admin/lmapd/events")
f.reset = false
f.submit = "Add"


event_name = f:field(Value, "_event_name", "Name of the event", "")
event_name.datatype = "uciname"

event_type = f:field(ListValue, "_event_type", "Type of the event", "")
event_type:value("periodic")
event_type:value("calendar")
event_type:value("one-off")
event_type:value("immediate")

random_spread = f:field(Value, "_random_spread", "Random Spread", "Optional")
cycle_interval = f:field(Value, "_cycle_interval", "Cycle Interval", "Optional")

interval = f:field(Value, "_interval", "Interval", "Interval for periodic invocation")
interval:depends("_event_type", "periodic")

time = f:field(Value, "_one_off_time", "Time for one off invocation", "")
time:depends("_event_type", "one-off")
time.template="lmapd/datetimepickeradd"

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


function f.handle(self, state, data)
  if state == FORM_VALID then
    local name = data._event_name
    local event_table = {}
    if name and #name > 0 then
      event_table['name'] = name
      local random_spread = data._random_spread
      local cycle_interval = data._cycle_interval

      if random_spread ~= nil then
        event_table['random-spread'] = tonumber(random_spread)
      end
      if cycle_interval ~= nil then
        event_table['cycle-interval'] = tonumber(cycle_interval)
      end

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
      local json_to_uci = require "lmapd.json_to_uci"
      json_to_uci.add_event_to_event_list_uci(name)
      json_to_uci.add_event_uci(event_table)
    end
    luci.http.redirect(luci.dispatcher.build_url("admin/lmapd/events"))
  end
  return true
end

return f

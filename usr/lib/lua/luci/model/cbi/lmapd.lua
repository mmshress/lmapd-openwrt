m = Map("lmapd", "LMAP Daemon")

sched = m:section(TypedSection, "schedule", "Schedules", "")
sched_name = sched:option(DynamicList, "name", "Name of the schedule", "")
sched_start = sched:option(DynamicList, "start", "Reference to a start node within events", "")
sched_exec_mode = sched:option(DynamicList, "execution_mode", "Execution mode for the schedule", "")
sched_action_ref = sched:option(DynamicList, "action", "Reference to action (keyed by action name)", "")
sched.anonymous=true

acti = m:section(TypedSection, "action", "Actions", "Actions that Schedules invoke")
acti_name = acti:option(DynamicList, "name", "Key of the action list", "")
acti_task = acti:option(DynamicList, "task", "Reference to task invoked by the action", "")
acti_destination = acti:option(DynamicList, "destination", "Destination Schedule for the invoked action", "")
acti.anonymous=true


return m

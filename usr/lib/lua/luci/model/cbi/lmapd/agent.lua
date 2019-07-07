m = Map("lmapd", "Measurement Agent Info")

s = m:section(NamedSection, "agent", "agent", "", "Information pertaining to the Measurement agent")

s:option(DummyValue, "agent_id", "Agent ID", "Universally Unique Identifier for the Agent")
s:option(DummyValue, "group_id", "Group ID", "")
s:option(Flag, "report_agent_id", "Report Agent ID", "")
s:option(Flag, "report_group_id", "Report Group ID", "")
timeout = s:option(Value, "controller_timeout", "Controller Timeout", "")
timeout.datatype = "uinteger"

return m

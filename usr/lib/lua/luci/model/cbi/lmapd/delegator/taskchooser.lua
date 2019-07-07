function get_capabilities()
  local uci = require "uci".cursor()
  local capabilities_list = uci:get("lmapd", "capabilities", "task_names")
  return capabilities_list
end

f = SimpleForm("lmapd", "Choose a task")

caps = get_capabilities()
m_task = f:field(ListValue, "_m_task", "Measurement Task", "Choose a measurement task your device is capable of")
if caps ~= nil then
  for _, task_name in pairs(caps) do
    m_task:value(task_name)
  end
end

function f.handle(self, state, data)
  if state == FORM_VALID then
    
  end
end

return f

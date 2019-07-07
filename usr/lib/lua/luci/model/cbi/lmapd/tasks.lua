local help = require "lmapd.json_to_uci"
capabilities = help:read_capabilities_json()
help.set_tasks_list(capabilities)
--adds tasks that are in the JSON file, but not the UCI config
help.read_tasks_list()

m = Map("lmapd", "LMAP Daemon Capabilities")

task_sections = {}
for i, val in pairs(task_list) do
  task_sections[i] = m:section(NamedSection, val, "task", val, "")
end

for i, val in pairs(task_sections) do
  task_sections[i].anonymous=false
  task_sections[i].addremove=false
  task_sections[i]:option(DummyValue, "version", "Version number", "")
  task_sections[i]:option(DummyValue, "program", "Program path", "")
  task_options = task_sections[i]:option(DynamicList, "task_options", "Options eligible", "")
  function task_options:validate(value)
    for idx, option_name in pairs(value) do
      local uci = require "uci".cursor()
      local task_option = uci:get("lmapd", option_name, "id")
      if task_option ~= nil then
        return value
      else
        return nil, "Option not found in config, add option first"
      end
    end
  end

end

return m

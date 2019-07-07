local uci = require "uci".cursor()

m = Map("lmapd", "Task Options")

options_list = {}
uci:foreach("lmapd", "task_option",
function(s)
  table.insert(options_list, s['.name'])
end)

task_option_sections = {}
for idx, task_name in pairs(options_list) do
  task_option_sections[idx] = m:section(NamedSection, task_name, "task_option", task_name, "")
  task_option_sections[idx]:option(Value, "name", "Option Name", "")
  task_option_sections[idx]:option(Value, "value", "Option Value", "")
end

uci_to_json = require "lmapd.uci_to_json"
local last_idx = uci_to_json.get_table_length(options_list)

btn_add = task_option_sections[last_idx]:option(Button, "_btn_add", "Add an option", "")
function btn_add.write()
  luci.http.redirect(luci.dispatcher.build_url("admin/lmapd/option_add"))
end

btn_remove = task_option_sections[last_idx]:option(Button, "_btn_remove", "Remove an option", "")
function btn_remove.write()
  luci.http.redirect(luci.dispatcher.build_url("admin/lmapd/option_remove"))
end
return m

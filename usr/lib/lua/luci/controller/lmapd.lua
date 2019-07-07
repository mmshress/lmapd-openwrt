module("luci.controller.lmapd", package.seeall)


function adv_toggle()
  local uci = require "uci":cursor()
  local flag = uci:get("lmapd", "advanced", "flag")
  if flag == '' or flag == nil then
    uci:set("lmapd", "advanced", "flag", "1")
  else
    uci:set("lmapd", "advanced", "flag", "")
  end
  uci:save("lmapd")
  uci:commit("lmapd")
  luci.http.redirect(luci.dispatcher.build_url('/admin/lmapd/overview'))
end

function index()
root_level_node = entry({"admin", "lmapd"}, firstchild(), "LMAPD", 60)
root_level_node.dependent=false
root_level_node.sysauth="root"
root_level_node.sysauth_authenticator="htmlauth"

overview = entry({"admin", "lmapd", "overview"}, template("lmapd/overview"), "Overview", 1)

quick_add = entry({"admin", "lmapd", "quick_add"}, form("lmapd/addremove/quick_add"), "Quick Add", 5)
quick_remove = entry({"admin", 'lmapd', 'quick_remove'}, form("lmapd/addremove/quick_remove"), "Quick Remove", 6)
results = entry({"admin", "lmapd", "results"}, template("lmapd/results"), "Results", 7)
results_get = entry({"admin", "lmapd", "results_get"}, post("get_results"), nil)
results_get.leaf=true
get_single_result = entry({"admin", "lmapd", "single_result"}, post("get_single_result"), nil)
get_single_result.leaf=true

advanced_mode = entry({"admin", "lmapd", "adv_toggle"}, call("adv_toggle"), "Toggle Advanced Mode", 99)

local uci = require "uci":cursor()
  if uci:get("lmapd", "advanced", "flag") == '1' then
    actions = entry({"admin", "lmapd", "actions"}, cbi("lmapd/actions", {autoapply=true}), "Actions", 20)
    action_add = entry({"admin", "lmapd", "action_add"}, form("lmapd/addremove/action_add", {hideresetbtn=true, hidesavebtn=true, hideapplybtn=true, autoapply=true}))
    action_add.leaf=true
    action_remove = entry({"admin", "lmapd", "action_remove"}, form("lmapd/addremove/action_remove", {hideresetbtn=true, hidesavebtn=true, hideapplybtn=true, autoapply=true}))
    action_remove.leaf=true

    schedules = entry({"admin", "lmapd", "schedules"}, cbi("lmapd/schedules"), "Schedules", 30)
    schedule_add = entry({"admin", "lmapd", "schedule_add"}, form("lmapd/addremove/schedule_add", {hideresetbtn=true, hidesavebtn=true, hideapplybtn=true, autoapply=true}))
    schedule_add.leaf=true
    schedule_remove = entry({"admin", "lmapd", "schedule_remove"}, form("lmapd/addremove/schedule_remove", {hideresetbtn=true, hidesavebtn=true, hideapplybtn=true, autoapply=true}))
    schedule_remove.leaf=true
    
    entry({"admin", "lmapd", "test"}, call("test"), nil)

    events = entry({"admin", "lmapd", "events"}, cbi("lmapd/events", {autoapply=true}), "Events", 50)
    event_add = entry({"admin", "lmapd", "event_add"}, form("lmapd/addremove/event_add", {hideresetbtn=true, hidesavebtn=true, hideapplybtn=true, autoapply=true}))
    event_add.leaf=true
    event_remove = entry({"admin", "lmapd", "event_remove"}, form("lmapd/addremove/event_remove", {hideresetbtn=true, hidesavebtn=true, hideapplybtn=true, autoapply=true}))
    event_remove.leaf=true

    options = entry({"admin", "lmapd", "options"}, cbi("lmapd/options", {autoapply=true}), "Options", 60)
    option_add = entry({"admin", "lmapd", "option_add"}, form("lmapd/addremove/option_add", {hideresetbtn=true, hidesavebtn=true, hideapplybtn=true, autoapply=true}))
    option_add.leaf=true
    option_remove = entry({"admin", "lmapd", "option_remove"}, form("lmapd/addremove/option_remove", {hideresetbtn=true, hidesavebtn=true, hideapplybtn=true, autoapply=true}))
    option_remove.leaf=true

    entry({"admin", "lmapd", "tasks"}, cbi("lmapd/tasks",{hideresetbtn=true, hidesavebtn=true, hideapplybtn=true, autoapply=true}), "Tasks", 70)
  end
end

function get_single_result()
  local res = require "lmapd.results"
  local helper = require "lmapd.uci_to_json"
  local result_data_path = luci.http.formvalue("result")
  local result_meta_path = result_data_path:gsub(".data", ".meta")
  json_response = {
    data = res.read_results_data(result_data_path),
    meta = res.read_results_data(result_meta_path)
  }
  luci.http.prepare_content("application/json")
  luci.http.write_json(json_response)
end

function get_results()
  local res = require "lmapd.results"
  local helper = require "lmapd.uci_to_json"
  local action_name = luci.http.formvalue("action")
  data_paths = res.get_data_for_action("report_primary", action_name)
  luci.http.prepare_content("text/plain")
  data_paths_list = {}
  for path in data_paths do
    table.insert(data_paths_list, path)
  end
  if helper.get_table_length(data_paths_list) > 0 then
    for _, path in ipairs(data_paths_list) do
      luci.http.write(path)
      luci.http.write("\n")
    end
  else
    luci.http.write("This action has no data.")
  end
end

function test()
  a = require "lmapd.status"
  luci.http.write(a.get_lmapd_status())
end

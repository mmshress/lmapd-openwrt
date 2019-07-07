local uci = require "uci".cursor()

f = SimpleForm("lmapd", "Add Event")
f.redirect = luci.dispatcher.build_url("admin/lmapd/options")
f.reset = false
f.submit = "Add"

option_id = f:field(Value, "_option_id", "Unique identifier of the Task Option", "")
option_id.datatype="and(minlength(1), uciname)"

option_name = f:field(Value, "_option_name", "Name of the Option", "")
option_value = f:field(Value, "_option_value", "Value of the Option", "")

function f.handle(self, state, data)
  if state == FORM_VALID then
    local id = data._option_id
    local option_table = {}
    option_table['id'] = id
    option_table['name'] = data._option_name
    option_table['value'] = data._option_value
    local json_to_uci = require "lmapd.json_to_uci"
    json_to_uci.add_option_uci(option_table)
    luci.http.redirect(luci.dispatcher.build_url("admin/lmapd/options"))
  end
  return true
end

return f

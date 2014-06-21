require "pluto"
require "utils"
require "sandbox"








if ns == nil then ns = {} end
-- Gets the parent of a namespace. "world.town.center" -> "world.town"
function ns.parent(name)
  return name:gsub("%.[^%.]+$","",1)
end
-- Gets the last segment of a namespace. "world.town.center" -> "center"
function ns.member(name)
  local _,_,membername = name:find("%.([^%.]+)$")
  return membername and membername or name
end
function ns.hasdot(name)
  return name:match("^[^%.]+$") == nil
end 
function ns.resolve(name, base)
  if ns.hasdot(name) then
    return name
  else
    return base .. "." .. name
  end
end






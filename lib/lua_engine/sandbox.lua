

function build_coroutine(user_id, mod_id, method_name, err)
  -- Access the module source
  local mod_source = host.get_mod_blob(mod_id)
  if (mod_source == nil) then
    err ("Couldn't find module " .. mod_id)
    return nil
  end

  -- Create the sandboxed environment
  local env  = get_globals()
  env.m = sandbox.create_m(user_id,mod_id)
  env.m.initial_method = method_name
  env.m.info.id = mod_id
  env.stats = sandbox.create_stats(user_id)
  env.require = sandbox.create_require(env)


  -- Load the module
  local mod = sandbox.load_with_env(mod_source,env,err)
  if (mod == nil) then return nil end
  
  -- Execute the module to populate the environment
  local status, result =  pcall(mod)
  if not status then
    err("Error evaluating module " .. mod_id .. "\n"..result)
    return nil
  end

  -- Look up the function from 'name'
  local initial_func = env[method_name]
  if (initial_func == nil) then
    err ("Couldn't find function " .. method_name .. " in module " .. mod_id)
    return nil
  end


  local code = coroutine.create(initial_func)
  -- Save the name so they can be recreated
  return {continuation=code, mod_id =mod_id, method_name=method_name}
end


sandbox = {}
sandbox.env = {
  ipairs = ipairs,
  next = next,
  pairs = pairs,
  pcall = pcall,
  tonumber = tonumber,
  tostring = tostring,
  type = type,
  print = print,
  unpack = unpack,
  --sha2 = {sha256hex = sha2.sha256hex},
  coroutine = { create = coroutine.create, resume = coroutine.resume, 
      running = coroutine.running, status = coroutine.status, 
      wrap = coroutine.wrap, yield = coroutine.yield },
  string = { byte = string.byte, char = string.char, find = string.find, 
      format = string.format, gmatch = string.gmatch, gsub = string.gsub, 
      len = string.len, lower = string.lower, match = string.match, 
      rep = string.rep, reverse = string.reverse, sub = string.sub, 
      upper = string.upper },
  table = { insert = table.insert, maxn = table.maxn, remove = table.remove, 
      sort = table.sort, show = table.show},
  math = { abs = math.abs, acos = math.acos, asin = math.asin, 
      atan = math.atan, atan2 = math.atan2, ceil = math.ceil, cos = math.cos, 
      cosh = math.cosh, deg = math.deg, exp = math.exp, floor = math.floor, 
      fmod = math.fmod, frexp = math.frexp, huge = math.huge, 
      ldexp = math.ldexp, log = math.log, log10 = math.log10, max = math.max, 
      min = math.min, modf = math.modf, pi = math.pi, pow = math.pow, 
      rad = math.rad, random = math.random, sin = math.sin, sinh = math.sinh, 
      sqrt = math.sqrt, tan = math.tan, tanh = math.tanh },
  os = { clock = os.clock, difftime = os.difftime, time = os.time },
  debug = {getlocal = debug.getlocal} -- REMOVE THIS
}

if host then
  sandbox.env.newpage = host.newpage
end

sandbox.create_proxy_access = function(user_id, mod_id)
  local t = {}
  local metatable = {
    __index = function (t,k)
      return host.get_value_by(k,mod_id, user_id)
    end,
    __newindex = function (t,k,v)
      host.set_value_by(k,v,mod_id,user_id)
    end
  }
  setmetatable(t,metatable)
  return t
end

-- get_value_by(key, mod_id = nil, user_id = nil, partition = nil)
-- set_value_by(key, value, mod_id = nil, user_id = nil, partition = nil) 

sandbox.create_m = function(user_id, mod_id)
  local m = {}
  m.u = sandbox.create_proxy_access(user_id,mod_id)
  m.info = {}
  m.settings = sandbox.create_proxy_access(nil, mod_id)
  return m
end
sandbox.create_stats = function(user_id)
  -- TODO, replace raw access with validation and a table per value to offer helper methods
  return sandbox.create_proxy_access(user_id,nil)
end

sandbox.create_require = function(modulename, env)
  return function(modulename)
    local mod_source = host.get_mod_blob(mod_id)
    if mod_source == nil then
      error("Failed to locate module " .. modulename)
    end
    local mod_loaded, message = loadstring(mod_source)
    if (mod_loaded == nil) then
      error("Failed to parse module " .. modulename .. ": ".. message)
    else
      setfenv(mod_loaded,env)
    end
    mod_loaded() -- Execute module without error handling (pcall)
  end
end

-- Loads and parses the specified file into a function, then sets its environment to 'env'. Errors go to the 'err' function.
sandbox.load_with_env = function(luacode, env, error_callback)
  local func, message = loadstring(luacode)
  if (func == nil) then
    error_callback(message)
  else
    setfenv(func,env)
  end
  return func
end

sandbox.env.back_to_caller = function()
  coroutine.yield({status='donehere'})
end

-- update_stat(k,v) set_stats(stats) 
-- newpage() print(tab, template) translate(str)
-- debuglog(str)
-- add_choice(id,label) set_choices(set)

-- get_mod_blob (id)
-- get_value_by(key, mod_id = nil, user_id = nil, partition = nil)
-- set_value_by(key, value, mod_id = nil, user_id = nil, partition = nil) 
-- flowstack_push(v) flowstack_pop() flowstack_peek()




sandbox.persistable = {[math.pi] = math.pi, [math.huge] = math.huge}

-- Creates an environment by copying sandbox.env. Used for sandboxing.
sandbox.get_globals = function()
  local globs =  deepcopy(sandbox.env) -- {pairs = pairs,print = print, type=type, coroutine = {yield=coroutine.yield}} -- sandbox_env
  globs["_G"] = globs
  return globs
end

sandbox.get_persist_perms = function()
  return table.invert(table.flatten_to_functions_array(sandbox.env, sandbox.persistable, print))
end

sandbox.get_unpersist_perms = function ()
  return table.flatten_to_functions_array(sandbox.env, sandbox.persistable,print )
end





-- table.invert, table.flatten_to_functions_array
-- deepcopy(object)

--This function returns a deep copy of a given table. The function below also copies the metatable to the new table 
-- if there is one, so the behaviour of the copied table is the same as the original. But the 2 tables share the 
-- same metatable, you can avoid this by changing this 'getmetatable(object)' to '_copy( getmetatable(object) )'.
function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end



-- Flattens nested tables into a single array of values, dropping any values present in the excluded_values dict.
-- Calls 'err' with a message whenever a value isn't a function. (the value isn't added)
function table.flatten_to_functions_array(tab, excluded_values, err)
  local arr = {}
  for k,v in pairs(tab) do
    
    if (type(v) == 'table' ) then
      -- No immediate cyclic refs, like _G. 
      if (v ~= tab) then
        local child = table.flatten_to_functions_array(v,excluded_values,err)
        for _,cv in ipairs(child) do
          if excluded_values[cv] == nil then
            table.insert(arr,cv)
          end
        end
      end
    else
      if excluded_values[v] == nil then
        if (type(v) ~= 'function') then
          err("Found value " .. v .. " when flatting to array")
        else
          table.insert(arr,v)
        end
      end
    end
  end
  return arr;
end




-- Returns an inverted table where the values are the keys and vice versa. Only safe with arrays, dicts may lose data on duplicate values
function table.invert(tab)
  local t = {}
  for k,v in pairs(tab) do
    t[v] = k
  end
  return t
end
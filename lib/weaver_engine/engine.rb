module WeaverEngine

  class Engine
    include LuaHelpersMixin

    attr_accessor :user_id, :branch_id, :data, :display, :init_module_id, :init_method_name
    def initialize(user_id, branch_id, data_adapter, display_adapter)
      @user_id = user_id
      @branch_id = branch_id
      @data = data_adapter
      @display = display_adapter
      @last_input = nil
      @init_module_id = "newbie"
      @init_method_name = "init"
    end



    def save_checkpoint(title)
      #save display, active input, and clone the flow. Add a secret key
      checkpoint = {title: title, 
        key: ('a'..'z').to_a.shuffle[0,8].join, 
        display: display.get_state,
        input: @last_input, 
        time: Time.new,
        flow: data.flowstack_full}
      data.checkpoints_edit do |d|
        d.push(checkpoint)
      end 
    end

   
    def restore_checkpoint(key)
      checkpoints = list_checkpoints
      checkpoint = checkpoints.find{|c|c[:key] == key}
      raise LuaEngineError.new("no_such_checkpoint",[]) if checkpoint.nil? 

      if key == "init"
        display.set_state(nil)
        data.flowstack_edit do |stack|
          []
        end
        push(@init_module_id, @init_method_name)
        nil
      else

        display.set_state(checkpoint[:display])
        data.flowstack_edit do |stack|
          checkpoint[:flow]
        end
        checkpoint[:input]
      end 
    end

    def has_checkpoints?
      !data.checkpoints_full.empty?
    end

    def list_checkpoints
      data.checkpoints_full + [{key: "init", title: "Home"}]
    end

    def has_flow?
      !data.flowstack_peek.nil?
    end
  

    def request(input = nil)
      @last_input = input
      display.set_state(data.get_value_by("display",nil, user_id))
      
      begin
        if data.get_value_by("recovery_mode",nil, user_id) && input["choice_key"]
          input = restore_checkpoint(input["choice_key"])
          data.set_value_by("recovery_mode",false,nil, user_id)
        end
        if !has_flow?
          if has_checkpoints?
            raise LuaEngineError.new("empty_stack",["Something bad happened"])
          else
            restore_checkpoint("init")
            resume(nil)
          end
        elsif input != nil
          resume(input)
        end
      rescue LuaEngineError => e 
        display.error(e, list_checkpoints)
        data.set_value_by("recovery_mode",true,nil, user_id)
      end
      data.set_value_by("display",display.get_state,nil, user_id)
      display.render
    end

    def resume(input)
      run_lua_function("resume", @user_id, input)
    end

    #function push(user_id, mod_id, method_name)
    #{success=true} - pushed to stack
    #{success=false, reason='start_failed', log=array_of_entries}
    # (goto or call failed (or module syntax error)

    def push(mod_id, method_name)
      run_lua_function("push", @user_id, mod_id, method_name)
    end

    def get_utils_code()
      File.read(File.expand_path('../lua_engine/utils.lua', File.dirname(__FILE__)))
    end
    def get_sandbox_code()
      File.read(File.expand_path('../lua_engine/sandbox.lua', File.dirname(__FILE__)))
    end

    def run_lua_function_direct(name, *params)
      run_lua do |s|
        result = s.eval("return #{name}(" + params.map{|v| to_lua_str(v)}.join(",") + ")",nil, "calling #{name} from ruby");
        result.to_ruby
      end
    end


    def run_lua_function(name, *params)
      #STDERR << "Running #{name}(" + params.join(',') + ")"
      run_lua do |s|
        params_list = params.map{|v| to_lua_str(v)}.join(",")
        source = %{names = {}
                  names.invoke_lua_xpcall = function() 
                    inner_xpcall_target = function() 
                      return } + "#{name}(#{params_list})" + %{
                    end 
                    local err = function(e) return e..debug.traceback() end
                    local flag, result = xpcall(inner_xpcall_target,err)
                    if flag then
                      return result
                    else
                      return {success=false, reason="host_runtime_error", log={result}}
                    end
                  end
                  return names.invoke_lua_xpcall()
                }
        result = s.eval(source, nil, "/invoke_lua_xpcall", 0)
        raise LuaEngineError.new("host_runtime_error", ["nil result from #{name}"]) if result.nil?
        raise LuaEngineError.new(result["reason"], result["log"]) unless result.nil? || result["success"]
        result
      end
    end


    def run_lua_with_vars(input_hash, &block)
      run_lua do |s|
        s.function "host.get_run_param" do |name|
          input_hash[name.to_sym]
        end
        input_hash.each do |k,v|
          s.eval("#{k} = host.get_run_param('#{k}')")
        end
        block.call(s)
      end
    end
    def run_lua(&block)
      s = Rufus::Lua::State.new()
      data.add_to_state(s,"host.")
      display.add_to_state(s,"host.")
      s.function "host.checkpoint" do |message|
        self.save_checkpoint(message)
      end
      s.function "host.stderr" do |message|
        $stderr.puts message
      end
      s.eval(get_utils_code(), nil, 'utils.lua', 0)
      s.eval(get_sandbox_code(), nil, 'sandbox.lua', 0)
      block.call(s)
      s.close
    end
  end 
end


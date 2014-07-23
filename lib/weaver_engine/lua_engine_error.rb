module WeaverEngine

  
  class LuaEngineError < RuntimeError

    attr_accessor :reason, :log
    def initialize(reason, log)
      @reason = reason
      @log = log
    end

    def explanation
      {
        doomed: "The new player area crashed",
        start_failed: "goto/call failed (or module syntax error)",
        empty_stack: "New player, or secondary error went unhandled",
        dead_coroutine: "abrupt_exit went unhandled",
        runtime_error: "An error happened in the module",
        host_runtime_error: "An error occured in the sandbox host",
        abrupt_exit: "Module stopped running without saying goodbye",
        infine_goto: "infinite loop between modules",
        no_such_checkpoint: "No such checkpoint"
      }[reason.to_s.downcase.to_sym]
    end

    def clean_stacktrace(trace)
      trace.map do |str|
        str.gsub(/\[string "([^"\]]+?)(:0)?"\]/, "\\1").gsub(/\n*\s*invoke_lua_xpcall.lua:\d: in function <invoke_lua_xpcall.lua:\d>\n*/,"\n")
      end 
    end

    def all_info
      ["#{reason} - #{explanation}"] + clean_stacktrace(DataAdapterBase.lua_to_ruby(log || []))
    end
  end
end
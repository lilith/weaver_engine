module WeaverEngine
  module LuaHelpersMixin



    def self.lua_to_ruby(v)
      if v.is_a?(Rufus::Lua::Table)
        v = v.to_ruby
      end
      if v.is_a?(Array)
        v = v.map{|p|LuaHelpersMixin.lua_to_ruby(p)}
      elsif v.is_a?(Hash)
        v = Hash[v.to_a.map{|p|LuaHelpersMixin.lua_to_ruby(p)}]
      end
      v
    end

    def lua_to_ruby(v)
      LuaHelpersMixin.lua_to_ruby(v)
    end


    def add_methods_to_state(state, prefix, methods)
      methods.each do |name|
        state.function "#{prefix}#{name}" do |*args|
          signature = "#{name}(#{args.map{|v|v.inspect}.join(',')})"
          result = nil
          begin
            args = lua_to_ruby(args)
            result = self.send(name,*args)
          rescue Exception => e 
            STDERR << "\nError calling C(Ruby) function #{signature}:\n #{e}\n"
          else
            STDERR << "\n#{prefix}#{signature}) invoked, returned #{result.inspect[0..30]}...\n"
          end
          result
        end
      end
    end


    def to_lua_str(v)
      return "nil" if v.nil?
      return escape_lua_string(v.to_s) if v.is_a?(String) || v.is_a?(Symbol)
      return v.to_s if v.is_a?(Boolean) || v.is_a?(Numeric)
      raise "Cannot convert serialize ruby value to lua string #{v.inspect}"
    end

    def escape_lua_string(str)
      escapes = { "\a" => "\\a", "\b" => "\\b", "\f" =>"\\f",
          "\n" => "\\n", "\r" => "\\r", "\v" => "\\v", "\"" => "\\\"", "\'" => "\\'", "[" => "\[", "]" => "\]"}
      "\"" + str.split("").map{|c| escapes[c] || c}.join("") + "\""
    end 
  end
end
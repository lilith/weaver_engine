module WeaverEngine
  class DataAdapterBase 

    attr_reader :user_id, :branch_id

    def user_id
      @user_id
    end
    def branch_id
      @branch_id
    end

 
    def get_mod_blob(mod_id)
    end
    def get_value_by(key, mod_id = nil, user_id = nil, partition = nil)
    end
    def set_value_by(key, value, mod_id = nil, user_id = nil, partition = nil)
    end
    def flowstack_peek()
    end
    def flowstack_pop()
    end
    def flowstack_push(v)
    end



    def self.lua_to_ruby(v)
      if v.is_a?(Rufus::Lua::Table)
        v = v.to_ruby
      end
      if v.is_a?(Array)
        v = v.map{|p|DataAdapterBase.lua_to_ruby(p)}
      elsif v.is_a?(Hash)
        v = Hash[v.to_a.map{|p|DataAdapterBase.lua_to_ruby(p)}]
      end
      v
    end

    def add_to_state(state, prefix)
      [:get_mod_blob, :get_value_by, :set_value_by, 
      :flowstack_push, :flowstack_pop, :flowstack_peek].each do |name|
        state.function "#{prefix}#{name}" do |*args|
          args = DataAdapterBase.lua_to_ruby(args)
          self.send(name,*args)
        end
      end
    end
  end
end

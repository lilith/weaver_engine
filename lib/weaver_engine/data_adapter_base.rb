module WeaverEngine
  class DataAdapterBase
    include LuaHelpersMixin 

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

    def add_to_state(state,prefix)
      add_methods_to_state state, prefix, [:get_mod_blob, :get_value_by, :set_value_by, 
      :flowstack_push, :flowstack_pop, :flowstack_peek]
    end

    def self.lua_to_ruby(v)
      LuaHelpersMixin.lua_to_ruby(v)
    end
  end
end

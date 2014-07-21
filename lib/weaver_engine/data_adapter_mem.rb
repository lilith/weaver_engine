module WeaverEngine
  class MemDataAdapter < DataAdapterBase

    attr_reader :user_id, :branch_id

    def initialize(user_id,branch_id, modules, data = {})
      @user = user_id
      @branch = branch_id
      @modules = modules || {}
      @data = data || {}
    end


    def get_mod_blob(mod_id)
      @modules[mod_id]
    end


    def get_value_by(key, mod_id = nil, user_id = nil, partition = nil)
      obj = load_store(mod_id,user_id,partition)
      obj[key]
    end

    def set_value_by(key, value, mod_id = nil, user_id = nil, partition = nil)
      edit_store(mod_id,user_id,partition) do |store|
        store[key] = value
        store
      end
    end

    def flowstack_peek()
      flowstack_full.last
    end
    def flowstack_pop()
      result = "NORESULT"
      flowstack_edit do |store|
        result = store.pop
        store
      end
      raise "Fault" if result == "NORESULT"
      result
    end
    def flowstack_push(v)
      flowstack_edit do |store|
        store.push v
        store
      end
    end


    def flowstack_full
      store = load_store(nil,@user_id,'flowstack')
      store ? (store[:stack] || []) : []
    end
     def flowstack_edit(&block)
      edit_store(nil,@user_id,'flowstack') do |store|
        store[:stack]  = block.call(store[:stack] || [])
        store
      end
    end

    def checkpoints_full
      store = load_store(nil,@user_id,'checkpoints')
      store ? (store[:checkpoints] || []): []
    end
    def checkpoints_edit(&block)
      edit_store(nil,@user_id,'checkpoints') do |store|
        store[:checkpoints] = block.call(store[:checkpoints] || [])
        store
      end
    end

    def get_key(mod_id = nil, user_id = nil, partition = nil)
      "#{mod_id || 'allmods'},#{user_id || 'allusers'},#{partition || 'default'},#{branch_id || 'master'}"
    end

    def load_store(mod_id = nil, user_id = nil, partition = nil)
      key = get_key(mod_id,user_id,partition)
      @data[key] ||= {}
      @data[key]
    end

    def edit_store(mod_id = nil, user_id = nil, partition = nil, &block)
      key = get_key(mod_id,user_id,partition)
      @data[key] = block.call(@data[key] || {})
    end

    def add_to_state(state,prefix)
      add_methods_to_state state, prefix, [:get_mod_blob, :get_value_by, :set_value_by, 
      :flowstack_push, :flowstack_pop, :flowstack_peek]
    end
  end
end

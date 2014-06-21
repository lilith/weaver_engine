module WeaverEngine
  class FsysDataAdapter < DataAdapterBase

    def initialize(user_id,branch_id, data_dir, module_dir)
      @user = user_id
      @branch = branch_id
      @data_dir = data_dir
      @module_dir = module_dir
    end


 
    def get_mod_blob(mod_id)
      File.read(io.path.join(@module_dir, mod_id, ".lua"))
    end


    def get_value_by(key, mod_id = nil, user_id = nil, partition = nil)
      obj = load_store(mod_id,user_id,partition)
      return nil if obj.nil?
      obj[key]
    end

    def set_value_by(key, value, mod_id = nil, user_id = nil, partition = nil)
      edit_store(mod_id,user_id,partition) do |store|
        store ||= {}
        store[key] = value
        store
      end
    end


    def flowstack_peek()
      flow = load_store(nil,@user_id,'flowstack')
      return nil if flow.nil? || flow[:stack].nil? || flow[:stack].empty?
      flow[:stack].last 
    end
    def flowstack_pop()
      result = nil
      edit_store(nil,@user_id,'flowstack') do |store|
        store ||= {}
        store[:stack] ||= []
        result = store[:stack].pop
        store
      end
    end
    def flowstack_push(v)
      edit_store(nil,@user_id,'flowstack') do |store|
        store ||= {}
        store[:stack] ||= []
        store[:stack].push v
        store
      end
    end

  
    def calc_path(mod_id = nil, user_id = nil, partition = nil)
      io.path.join(@data_dir,"#{mod_id || 'allmods'},#{user_id || 'allusers'},#{partition || 'default'},#{branch_id || 'master'}.data")
    end

    def load_store(mod_id = nil, user_id = nil, partition = nil)
      fname = calc_path(mod_id,user_id,partition)
      if File.exist?(fname)
        Marshal.load(File.read())
      else
        nil
      end
    end

    def edit_store(mod_id = nil, user_id = nil, partition = nil, &block)
      fname = calc_path(mod_id,user_id,partition)
      obj = File.exist?(fname) ? Marshal.load(File.read(fname)) : nil
      obj = block.call(obj)
      Dir.mkdir(File.dirname(fname)) unless File.directory?(File.dirname(fname))
      File.open(fname, 'w') {|f| f.write(Marshal.dump(obj)) }
    end

    # transaction sources [(user,amount,currency)] destinations [(user,amount,currency)]

  end
end

module WeaverEngine
  class MemDisplayAdapter

    
    def initialize(data_adapter)
      @data_adapter = data_adapter
    end


    def set_state(data)
      @data = data || {}
      @data[:stats] ||= {}
      @data[:prose] ||= []
      @data[:choices] ||= {}
      @data[:status] = 200
    end
    def get_state
      Marshal.load(Marshal.dump(@data))
    end

    def stats
      @data[:stats]
    end

    def prose
      @data[:prose]
    end

    def choices
      @data[:choices]
    end

    def update_stat(key, value)
      stat[key] = value
    end 
    def set_stats(stats)
      @data[:stats] = stats
    end

    def newpage()
      prose.clear
      choices.clear
    end

    def add_input(e)
      #Will add the given input element to the form. 
    end

    def add_choice(id, label)
      choices.push({id:id, label:label})
    end

    def set_choices(choices)
      @data[:choices] = choices
    end

    def render()
      @data
    end

    def error(error,checkpoints)
      @data[:prose] = error.all_info
      @data[:choices] = checkpoints.map{|c| {id: c[:key], label: c[:title]}} #todo add time ago.
      @data[:status] = 500
    end

    def print(var_table, template)
      if template.nil? && var_table.is_a?(String)
        template = var_table
        var_table = nil
      end
      var_table.each do |k, v|
        template = template.replace('{{'  + k + '}}', v)
      end if var_table && var_table.is_a?(Hash)
      prose.push(template)
    end
    def translate(str)
      str
    end

    def debuglog(str)
    end
    #inventory? 

    # For ajax, we eventually would want to diff the tree, i.e compare current against saved.

    def add_to_state(state, prefix)
      [:update_stat, :set_stats, :newpage, 
      :print, :translate, :debuglog, :add_choice, :set_choices].each do |name|
        state.function "#{prefix}#{name}" do |*args|
          args = FsysDataAdapter.lua_to_ruby(args)
          self.send(name,*args)
        end
      end
    end
  end
end

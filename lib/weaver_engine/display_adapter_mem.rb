module WeaverEngine
  class MemDisplayAdapter
    include LuaHelpersMixin
    
    def initialize(data_adapter)
      @data_adapter = data_adapter
      set_state(nil)
    end

    def ensure_data
      @data ||= {}
      @data[:stats] ||= {}
      @data[:prose] ||= []
      @data[:choices] ||= []
    end

    def set_state(data)
      @data = data
      ensure_data
      @data[:status] = 200
    end

    def get_state
      Marshal.load(Marshal.dump(@data))
    end

    def stats
      ensure_data
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

    def add_choice(id, label=nil)
      choices.push({id:id, label: (label || id)})
    end

    def set_choices(choices)
      @data[:choices] = choices.map{|c| c.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}}
    end

    def get_choices
      @data[:choices] || []
    end

    def safe_hex_digest(str)
      "h" + Digest::SHA256.new.hexdigest(str)[0..12]
    end

    def render()
      raise "No choices provided by game" if @data[:choices].empty?
      choices.each do |c|
        c[:safe_id] = safe_hex_digest(c[:id])
      end
      @data
    end

    def filter_input(input)
      return nil if input.nil?
      by_id = Hash[choices.map{|c| [safe_hex_digest(c[:id]), c]}]

      key = input.keys.find{|k| by_id[k]}
      return by_id[key]
    end

    def error(error,checkpoints)
      @data[:prose] = error.all_info
      @data[:choices] = checkpoints.map{|c| {id: c[:key], label: c[:title]}} #todo add time ago.
      @data[:status] = 500
      @data[:error] = error.all_info.join("\n")
    end

    def print(var_table, template = nil)
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
    def add_to_state(state,prefix)
      add_methods_to_state state, prefix, [:update_stat, :set_stats, :newpage, 
      :print, :translate, :debuglog, :get_choices, :add_choice, :set_choices]
    end

    
  end
end

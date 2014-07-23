module WeaverEngine
  class HtmlDisplayAdapter < MemDisplayAdapter

    def initialize(data_adapter)
      @data_adapter = data_adapter
      set_state({})
    end

  end
end

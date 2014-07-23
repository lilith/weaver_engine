module WeaverEngine
  describe Engine do

    before do 
      @user_id = 'tester'
      @branch_id = 'master'
      @modules = {}
      @modules["newbie"] = %{
        function init()
          newpage()
          p[[Init Room]]
          coroutine.yield({status='prompt'})
          goto("gotos", "room2")
        end
        function room2()
          newpage()
          p[[Room2]]
          coroutine.yield({status='prompt'})
          goto("gotos", "init")
        end
      }
      @data = MemDataAdapter.new(@user_id,@branch_id, @modules)
      @display = MemDisplayAdapter.new(@data)
      @engine = Engine.new(@user_id, @branch_id, @data, @display)
    end

    it 'adds a default choice' do 
      response = @engine.request
      assert_equal response[:choices], [{id: "continue", label: "Continue"}]
      @engine = nil
    end

  end


end
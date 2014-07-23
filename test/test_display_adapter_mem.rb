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
          add_choice("Continue")
          wait()
          goto("gotos", "room2")
        end
        function room2()
          newpage()
          p[[Room2]]
          add_choice("Continue")
          wait()
          goto("gotos", "init")
        end
      }
      @data = MemDataAdapter.new(@user_id,@branch_id, @modules)
      @display = MemDisplayAdapter.new(@data)
      @engine = Engine.new(@user_id, @branch_id, @data, @display)
    end

    it 'Throws an error when there are no choices' do 
      response = @engine.request
      assert_equal response[:choices], [{id: "Continue", label: "Continue", safe_id: "h31fbef162594d"}]
      @engine = nil
    end

   it 'Adds a safe id' do 
      response = @engine.request
      assert_equal response[:choices], [{id: "Continue", label: "Continue", safe_id: "h31fbef162594d"}]
      @engine = nil
    end

  end


end
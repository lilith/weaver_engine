module WeaverEngine
  describe Engine do

    before do 
      @user_id = 'tester'
      @branch_id = 'master'
      @modules = {}
      @modules["newbie"] = %{
        function init()
            p[[Hello]]
            coroutine.yield({status='prompt'})
            room()
        end
        function room()
          p[[You are in a room]]
          coroutine.yield({status='prompt'})
          init()
        end
      }
      @modules["gotos"] = %{
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

    it 'serialized_roundtrip' do 
      @engine.push("newbie", "init")
      @data.flowstack_peek()["binary"].length.must_be(:>, 100) 
      @engine = nil
    end

    it 'can_initialize' do
      response = @engine.request
      assert_equal 200, response[:status], response[:error]
      @engine = nil
    end

    it 'test_can_print' do
      response = @engine.request
      assert_equal ["Hello"], response[:prose], response[:error]
      @engine = nil
    end

    it 'test_can_resume' do
      response = @engine.request
      response = @engine.request({})
      assert_equal ["Hello", "You are in a room"], response[:prose], response[:error]
      @engine = nil
    end

    it 'test_can_goto' do
      @engine.init_module_id = "gotos"
      response = @engine.request
      assert_equal ["Init Room"], response[:prose], response[:error]
      response = @engine.request({})
      assert_equal ["Room2"], response[:prose], response[:error]
      response = @engine.request({})
      assert_equal ["Init Room"], response[:prose], response[:error]
      @engine = nil
    end


  end


end
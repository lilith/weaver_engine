module WeaverEngine
  describe Engine do

    before do 
      @user_id = 'tester'
      @branch_id = 'master'
      @modules = {}
      @modules["newbie"] = %{
        function init()
            p[[Hello]]
            add_choice("continue","Continue")
            wait()
            room()
        end
        function room()
          p[[You are in a room]]
          add_choice("continue","Continue")
          wait()
          init()
        end
      }
      @modules["gotos"] = %{
        function init()
          newpage()
          p[[Init Room]]
          add_choice("continue","Continue")
          wait()
          goto("gotos", "room2")
        end
        function room2()
          newpage()
          p[[Room2]]
          add_choice("continue","Continue")
          wait()
          goto("gotos", "init")
        end
      }
      @modules["badsyntax"] = "[["
      @modules["runtimerror"] = "function init() error(\"fail\") end"
      @data = MemDataAdapter.new(@user_id,@branch_id, @modules)
      @display = MemDisplayAdapter.new(@data)

      @engine = Engine.new(@user_id, @branch_id, @data, @display)
    end

    it 'serialized_roundtrip' do 
      @engine.push("newbie", "init")
      @data.flowstack_peek()["binary"].length.must_be(:>, 100) 
      @engine = nil
    end

    it 'can initialize' do
      response = @engine.request
      assert_equal 200, response[:status], response[:error]
      @engine = nil
    end

    it 'can print' do
      response = @engine.request
      assert_equal ["Hello"], response[:prose], response[:error]
      @engine = nil
    end

    it 'can resume' do
      response = @engine.request
      response = @engine.request({response[:choices][0][:safe_id] => true})
      assert_equal ["Hello", "You are in a room"], response[:prose], response[:error]
      @engine = nil
    end

    it 'can goto' do
      @engine.init_module_id = "gotos"
      response = @engine.request
      assert_equal ["Init Room"], response[:prose], response[:error]
      response = @engine.request({})
      assert_equal ["Room2"], response[:prose], response[:error]
      response = @engine.request({})
      assert_equal ["Init Room"], response[:prose], response[:error]
      @engine = nil
    end

    it 'has detailed module syntax errors' do
      @engine.init_module_id = "badsyntax"
      response = @engine.request
      assert response[:error].include?("badsyntax:1: unfinished long string near '<eof>'"), response[:error]
    end

    it 'has detailed runtime errors' do
      @engine.init_module_id = "runtimerror"
      response = @engine.request
      assert !response[:error].include?("xpcall"), response[:error]
      assert  response[:error].include?("runtimerror:1: fail"), response[:error]
    end

  end


end
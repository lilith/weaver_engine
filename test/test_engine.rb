module WeaverEngine
  describe Engine do

    before do 
      @user_id = 'tester'
      @branch_id = 'master'
      @modules = {}
      @modules["newbie"] = %{
        function init()
            p[[Hello]]
            await_user()
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
      assert_equal 200, response[:status]
      @engine = nil
    end

    it 'test_can_print' do
      response = @engine.request
      assert_equal ["Hello"], response[:prose]
      @engine = nil
    end

  end


end
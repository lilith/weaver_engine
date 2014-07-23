module WeaverEngine
  describe LuaHelpersMixin do
    before :each do
      a  = Class.new do
        include LuaHelpersMixin 
      end
      @h = a.new 
    end

    it 'serialize a ruby hash to lua syntax' do
      @h.to_lua_str({a: "b"}).must_equal '{["a"] = "b"}' 
    end

    it 'serialize a ruby array to lua syntax' do
      @h.to_lua_str(["a",3,"b"]).must_equal '{[1] = "a", [2] = 3, [3] = "b"}' 
    end

    it 'serialize a ruby string with escape characters to lua syntax' do
      @h.to_lua_str("\\\n\t\b\"").must_equal '"\\\\\n\t\b\""' 
    end


  end
end

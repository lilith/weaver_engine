
class TestCouroutinePersist < MiniTest::Test

  def test_coroutines_persist
    luatest = File.read(File.expand_path('continuation.lua', File.dirname(__FILE__)))
    
     
      s = Rufus::Lua::State.new()

      result = s.eval(luatest)
      #STDERR << "RESULT: #{result.inspect}"

      assert_equal(5, result["a"][5])
      assert_equal(6, result["b"][1])
      assert_equal(10,result["b"][5])
          s.close
        
    
  end

end

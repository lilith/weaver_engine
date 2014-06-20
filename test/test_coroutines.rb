
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

  def test_dotfunctions
    s = Rufus::Lua::State.new()
    s.function 'hash.func' do 
      5
    end

    result = s.eval("return hash.func()")
    assert_equal(5, result)
    s.close
  end

  def test_coroutine_complete_results

    lua = %{
      function multisucceed()
        return 1,2
      end
      function succeed()
        return true
      end
      function fail()
        error("fail")
      end
      function void()
      end
      results = {}} + 
      ["multisucceed", "succeed", "fail", "void"].map do |name|
        "local was_started, result = coroutine.resume(coroutine.create(#{name}))\n" +
        "results.#{name} = {was_started,result}\n"
      end * "\n" + "return results"


    s = Rufus::Lua::State.new()
    results = WeaverEngine::FsysDataAdapter.lua_to_ruby(s.eval(lua))
    assert_equal([true, 1.0], results["multisucceed"])
    assert_equal([true, true], results["succeed"])
    assert_equal([false, '[string "line"]:9: fail'], results["fail"])
    assert_equal([true], results["void"])
    s.close
  end
  def test_coroutine_end_results

    lua = %{
      function void()
      end
      co = coroutine.create(void)
      local a, b = coroutine.resume(co)
      local a, b = coroutine.resume(co)
      return {a,b}}

    s = Rufus::Lua::State.new()
    results = WeaverEngine::FsysDataAdapter.lua_to_ruby(s.eval(lua))

    assert_equal([false, "cannot resume dead coroutine"], results)
    s.close
  end

end

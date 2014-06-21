
class TestCouroutinePersist < MiniTest::Test

  def test_coroutines_persist
    luatest = File.read(File.expand_path('continuation.lua', File.dirname(__FILE__)))
    
     
    s = Rufus::Lua::State.new()

    result = s.eval(luatest)

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

  def test_persisted_coroutine
    output = {}
    s = Rufus::Lua::State.new()
    s.function "save_out" do |k, v|
      output[k] = v
    end
    s.function "pull_in" do |k|
      output[k]
    end
    s.eval(%{
      require "pluto"
      function sequence() 
        coroutine.yield(77)
      end
      co = coroutine.create(sequence)
      serialized = pluto.persist({},co)
      save_out("length",string.len(serialized))
      save_out("byte0", string.byte(serialized,1))
      save_out("byte1", string.byte(serialized,2))
      save_out("byte2", string.byte(serialized,3))
      save_out("binary",serialized)})

    #assert_equal 312.0, output["length"] 
    
    assert_equal 1.0, output["byte0"], "byte0"
    assert_equal 0.0, output["byte1"], "byte1"
    assert_equal 0.0, output["byte2"], "byte2"

    assert_equal output["length"], output["binary"].length.to_f, "Original vs ported length"

    assert_equal 77, s.eval(%{return coroutine.resume(pluto.unpersist({},pull_in("binary")))})

    s.close
  end


end

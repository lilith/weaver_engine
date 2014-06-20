
class TestPersistSpeed < MiniTest::Test

  def setup
    @large_string = "Hello" * 10000
  end

  def test_persist_speed
      
    s = Rufus::Lua::State.new()

    s.eval("require 'pluto'")
    s.eval("blob = '#{@large_string}'")

    time = Benchmark.realtime { 
      s.eval("persisted = pluto.persist({},blob)")
    }
    puts " - 50kb string persist time taken: #{time * 1000} milliseconds"

    time = Benchmark.realtime { 
      s.eval("blob2 = pluto.unpersist({},persisted)")
    }
    puts " - 50kb string unpersist time taken: #{time * 1000} milliseconds"

    s.close
        
  end

end

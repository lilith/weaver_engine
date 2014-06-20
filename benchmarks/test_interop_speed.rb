
class TestInteropSpeed < MiniTest::Test


  def test_simple_interop_speed
    s = Rufus::Lua::State.new()
    s.function 'add' do |x, y|
      x + y
    end
    time = Benchmark.realtime {
      s.eval(%{
          for i=1,1000 do add(5,5) end
        })
    }
    puts " - Simple call out to ruby x 1,000: #{time * 1000} milliseconds"
    s.close
  end

  def test_large_interop_outcall_speed
    s = Rufus::Lua::State.new()
    s.function 'length' do |var|
      var.length
    end
    str = "hello" * 10000
    time = Benchmark.realtime {
      s.eval("local s = \"#{str}\"\n" + %{
          for i=1,1000 do length(s) end
        })
    }
    puts " - Heavy call out (save 50kb) x 1,000: #{time * 1000} milliseconds"
    s.close
  end

  def test_large_interop_return_speed
    s = Rufus::Lua::State.new()
    str = "hello" * 10000
    s.function 'loadstr' do
      str
    end
    
    time = Benchmark.realtime {
      s.eval(%{
          for i=1,1000 do loadstr() end
        })
    }
    puts " - Heavy return in (load 50kb) x 1,000: #{time * 1000} milliseconds"
    s.close
  end

   def test_large_interop_eval_speed
    s = Rufus::Lua::State.new()
    s.eval(%{
          function l(s)
            return string.len(s)
          end
        })
    str = "hello" * 10000
    
    
    time = Benchmark.realtime {
      
      1000.times do 
        s.eval("l('#{str}')")
      end
    }
    puts " - Heavy eval (eval 50kb string) x 1,000: #{time * 1000} milliseconds"
    s.close
  end

  

end

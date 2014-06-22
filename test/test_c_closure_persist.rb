describe 'pluto persistence of C closures' do 

  before :each do
    @s = Rufus::Lua::State.new
    @s.function "host_function" do
      "success"
    end
    @s.eval(%{
      require "pluto"

      function table.invert(tab)
        local t = {}
        for k,v in pairs(tab) do
          t[v] = k
        end
        return t
      end})
  end
  after :each do
    @s.close
  end

  it 'should fail to persist a C closure' do
    @s.eval(%{
      env = {coroutine = {yield=coroutine.yield},hostfunc=host_function}
      env["_G"] = en

      function routine()
        coroutine.yield()
        retval = hostfunc()
        coroutine.yield(retval) -- "success"
      end

      setfenv(routine, env)
      co = coroutine.create(routine)
      coroutine.resume(co)

      unpersist = {coroutine.yield,hostfunc}

      binary = pluto.persist(table.invert(unpersist),co)
      co2 = pluto.unpersist(unpersist,binary)
      local success, result = coroutine.resume(co2)
      return result
      }).must_equal "success"
  end


    it 'should not convert a string into a function' do
      @s.eval(%{
        function hf()
          return host_function()
        end
        env = {tostring=tostring,cy = coroutine.yield,hostfunc=hf}
        env["_G"] = env

        function routine()
          local retval = hostfunc()
          cy(retval)
        end
        setfenv(routine, env)
        co = coroutine.create(routine)
        a, b = coroutine.resume(co)
        return {a,b}}).to_ruby.must_equal [true,"success"]

  end


  it 'should correctly persist a lua closure on a C function' do
    @s.eval(%{
      function hf()
        local retval = host_function()
        return retval()
      end
      env = {tostring=tostring,cy = coroutine.yield,hostfunc=hf}
      env["_G"] = env

      function routine()
        local retval = hostfunc()
        cy(tostring(retval))
        retval = hostfunc()
        cy(tostring(retval))
        retval = hostfunc()
        cy(tostring(retval))
      end

      setfenv(routine, env)
      co = coroutine.create(routine)

      a, b = coroutine.resume(co)

      unpersist = {coroutine.yield, host_function, env.hostfunc,tostring}

      binary = pluto.persist(table.invert(unpersist),co)
      co2 = pluto.unpersist(unpersist,binary)

      c, d = coroutine.resume(co2)
      e, f = coroutine.resume(co2)})

    results = [@s.eval("return {a,b}").to_ruby,
                @s.eval("return {c,d}").to_ruby,
                @s.eval("return {d,f}").to_ruby]

    results.must_equal [[true,"success"],[true,"success"],[true,"success"]]
  end

end
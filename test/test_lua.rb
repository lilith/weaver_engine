
class CheckLuaSyntax < MiniTest::Test



  def test_sandbox_syntax
    test_syntax('../lib/lua_engine/sandbox.lua')
  end


  def test_sandbox_methods
    source = File.read(File.expand_path('../lib/lua_engine/sandbox.lua', File.dirname(__FILE__)))
    s = Rufus::Lua::State.new()
    s.eval(source)
    s.close
  end

private
  def test_syntax(path)
    source = File.read(File.expand_path(path, File.dirname(__FILE__)))
    s = Rufus::Lua::State.new()
    s.eval(source)
    s.close
  end
end
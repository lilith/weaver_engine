
class TestNullBytesInterop < MiniTest::Test


  def test_null_bytes_ffi_out
    output = {}
    s = Rufus::Lua::State.new()
    s.function "save_out" do |k, v|
      output[k] = v
    end
    s.function "pull_in" do |k|
      output[k]
    end
    s.eval(%{
      s = string.char(32,0,32)
      save_out("length",string.len(s))
      save_out("byte0", string.byte(s,1))
      save_out("byte1", string.byte(s,2))
      save_out("byte2", string.byte(s,3))
      save_out("binary",s)})

    assert_equal 32.0, output["byte0"], "byte0"
    assert_equal 0.0, output["byte1"], "byte1"
    assert_equal 32.0, output["byte2"], "byte2"
    assert_equal output["length"], output["binary"].length.to_f, "Original vs ported length"

    s.close
  end

  def test_null_bytes_fetch
    s = Rufus::Lua::State.new()
    str = s.eval("return string.char(32,0,0,32)")
    byte4 = s.eval("return string.byte(string.char(32,0,0,32),4)")
    assert_equal 4, str.length
    assert_equal 32, byte4
    s.close
  end

  def is_fail
    assert (false)
  end

  def test_null_bytes_push
    s = Rufus::Lua::State.new()
    nullstr = "\x20\x00\x00\x20"
    assert_equal 4, nullstr.size
    assert_equal 32, nullstr.getbyte(3)
    s.function "get_null_string" do
      nullstr
    end
    assert_equal 4, s.eval("return string.len(get_null_string())")
    assert_equal 32, s.eval("return string.byte(get_null_string(),4)")

    assert_equal true, s.eval("return (get_null_string() == string.char(32,0,0,32))")
    str = s.eval("return string.char(32,0,0,32)")
    assert_equal 4, str.length
    assert_equal nullstr, str
    s.close
  end

  def test_ruby_bytesize
    assert_equal 4, "\x32\x00\x00\x32".bytesize
  end

end

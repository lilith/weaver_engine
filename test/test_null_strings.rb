
describe 'lua strings' do


  before :each do
    @s = Rufus::Lua::State.new
  end
  after :each do
    @s.close
  end

  it 'are not truncated when returned to Ruby' do

    s = @s.eval('return string.char(1, 0, 0)')

    s.bytes.to_a.must_equal [ 1, 0, 0 ]
  end

  it 'are not truncated when passed from Ruby to Lua and back' do

    s = [ 65, 66, 0, 67, 68 ].pack('c*')

    f = @s.eval(%{
      f = function(s)
        return { s = s, l = string.len(s) }
      end
      return f
    })

    f.call(s).to_h.must_equal({ 's' => s, 'l' => 5 })
  end

  it 'fetch nully strings from stack' do 
    @s.eval("return string.char(32,0,0,32)").must_equal "\x20\x00\x00\x20"
    @s.eval("return string.char(32,0,0,32)").length.must_equal 4
  end

  it 'verify ruby string behavior' do
    nullstr = "\x20\x00\x00\x20"
    nullstr.size.must_equal 4
    nullstr.getbyte(3).must_equal 32
  end 

  it 'push nully strings to stack' do 
    nullstr = "\x20\x00\x00\x20"
    @s.function "get_null_string" do
      nullstr
    end
    @s.eval("return string.len(get_null_string())").must_equal 4
    @s.eval("return string.byte(get_null_string(),4)").must_equal 32

    @s.eval("return (get_null_string() == string.char(32,0,0,32))").must_equal true
    
    str = @s.eval("return string.char(32,0,0,32)")
    str.length.must_equal 4
    str.must_equal nullstr
  end

  it 'roundtrips null bytes' do
    #Here we verify roundtripping from both sides
    #Note that length checking is just to make sure the nullcounters don't activate
    output = {}
    @s.function "save_out" do |k, v|
      output[k] = v
    end
    @s.function "pull_in" do |k|
      output[k]
    end
    @s.eval(%{
      s = string.char(32,0,32)
      save_out("copy",s)
      s = pull_in("copy")
      save_out("length",string.len(s))
      save_out("byte0", string.byte(s,1))
      save_out("byte1", string.byte(s,2))
      save_out("byte2", string.byte(s,3))
      save_out("copy2",s)})
    output["copy2"].must_equal "\x20\x00\x20"
    output["byte0"].must_equal 32.0
    output["byte1"].must_equal 0.0
    output["byte2"].must_equal 32.0
    output["length"].must_equal 3
  end

end


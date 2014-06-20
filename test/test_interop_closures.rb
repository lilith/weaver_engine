require 'minitest/autorun'
require 'rufus-lua'
require 'benchmark'

describe "rufus-lua interop" do
  it 'runs tests' do
    true.must_equal true
  end
  it 'manual closures succeed' do 
    s = Rufus::Lua::State.new()
    c = Cl.new(10)

    [:getval].each do |name|
      s.function name.to_s do |*args|
        c.send(name, *args)
      end
    end

    result = s.eval("return getval()")
    result.must_equal 10
    s.close
  end

end

class Cl
  def initialize(val)
    @val = val
  end

  def getval
    @val
  end
  
end
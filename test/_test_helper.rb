require 'bundler/setup'
require 'minitest/autorun'
require 'minitest/benchmark'
#ENV["LUA_LIB"]="/Users/nathanael/Documents/weaver-projects/weaver_engine/lib_lua/liblua.dylib"
#ENV["LUA_CPATH"]="/Users/nathanael/Documents/weaver-projects/weaver_engine/lib_lua/?.so"


require 'rufus-lua'
require 'benchmark'
require "weaver_engine"

STDERR << "Using liblua #{Rufus::Lua::Lib.path}\n"
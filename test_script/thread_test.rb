#!ruby -Ks
# -*- mode: ruby; encoding: sjis -*-
# Last updated: <2013/08/02 13:20:58 +0900>
#
# Threadのテスト

puts "Test start"

puts "Thread create"

t = Thread.new do
  puts "Start thread"
  sleep 3
  puts "End thread"
end

puts "wait"
t.join

puts "Test complete."



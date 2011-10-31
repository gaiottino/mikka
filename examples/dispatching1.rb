# encoding: utf-8

$: << File.expand_path('../../lib', __FILE__)

require 'bundler/setup'
require 'mikka'

class One < Mikka::Actor
  dispatcher :event_driven, :name => 'unique', :core_pool_size => 1, :max_pool_size => 1

  def receive(msg)
    sleep 1
    puts "I share a dispatcher with Two"
  end
end

class Two < Mikka::Actor
  dispatcher :event_driven, :name => 'unique' # since the name is the same we can just retrieve it. no need for the other options if One is started created first
  
  def receive(msg)
    sleep 1.2
    puts "I share a dispatcher with One"
  end
end

class Threaded < Mikka::Actor
  dispatcher :thread_based

  def receive(msg)
    sleep 0.5
    puts "I have my own dispatcher bounded to a single thread"
  end
end

one = Mikka.actor_of(One).start
two = Mikka.actor_of(Two).start
threaded = Mikka.actor_of(Threaded).start

5.times do
  one << 'message'
  two << 'message'
  threaded << 'message'
end

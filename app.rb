require 'rubygems'
require 'sinatra'
require 'json/pure'

get '/' do

  #Simulate work
  case rand*100
  when 0...10              #v1 - slow + errors 10% of the time
#  when 0...15             #v2 - should be better
#  when 0...5              #v3 - is actually better
    sleep rand(5..10)
    status 503
  else 
    sleep rand(0.1..1)
  end

  rand(0..1000).to_s
end

get '/some-error' do
  $stderr.puts "This is an error log"
end

require 'rubygems'
require 'sinatra'
require 'haml'
require 'pack'

get "/" do
  haml :index
end
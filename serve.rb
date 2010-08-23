require 'rubygems'
require 'sinatra'
require 'haml'
require 'pack'

get "/" do
  haml :index
end

get "/displaybox" do
  @dropbox = Dropbox.new
  error = false
  params[:text].split("LB").each do |line|
    a , b = line.split(" ").map{|n| n.to_i}
    if (a.nil? || b.nil?)
      error = true
      break
    end
    @dropbox.boxes << (a > b ? Box.new(a , b) : Box.new(b , a))
  end
  return "error." if error
  @dropbox.calculate_best_fill(params[:type].to_sym)
  haml :boxdisplay, :layout => false
end
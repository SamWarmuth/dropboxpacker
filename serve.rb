require "rubygems"
require "haml"
require "sass"
require "sinatra"
require "pack"

get "/" do
  haml :index
end

get "/displaybox" do
  @dropbox = Dropbox.new
  error = false
  if params[:text]
    params[:text].split("LB").each do |line|
      a , b = line.split(" ").map{|n| n.to_i}
      if (a.nil? || b.nil?)
        error = true
        break
      end
      @dropbox.add_box(a > b ? Box.new(a , b) : Box.new(b , a))
    end
  else
    min = params[:min].to_i
    min = 1 if min < 1
    max = params[:max].to_i
    difference = max-min
    params[:number].to_i.times do
      a = rand(difference)+min
      b = rand(difference)+min
      @dropbox.add_box(a > b ? Box.new(a , b) : Box.new(b , a))
    end
  end
  return "error." if error
  haml :boxdisplay, :layout => false
end
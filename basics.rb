require 'pack'

print "# Boxes: "
number_of_boxes = gets.to_i
return "Not an int" if number_of_boxes.nil?
db = Dropbox.new
number_of_boxes.times do
  a , b = gets.split(" ").map{|n| n.to_i}
  next if (a.nil? || b.nil?)
  area = a*b
  db.boxes << Box.new((a > b ? [a,b] : [b,a]))
  puts "Box: #{a} x #{b} => #{area}u : #{db.area}u total"
end

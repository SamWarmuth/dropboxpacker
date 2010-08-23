#!/usr/bin/ruby

require 'pack'

number_of_boxes = gets.to_i
return "Error. Number of boxes is not an int" if number_of_boxes.nil?
db = Dropbox.new
number_of_boxes.times do
  a , b = gets.split(" ").map{|n| n.to_i}
  next if (a.nil? || b.nil?)
  area = a*b
  db.boxes << ((a > b ? Box.new(a,b) : Box.new(b,a)))
end
puts db.calculate_best_fill(:best_duplex).actual_area.to_s

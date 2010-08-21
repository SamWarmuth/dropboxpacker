number_of_boxies = gets.to_i
return "Not an int" if total_boxes.nil?
puts "Boxes: #{total_boxes}"
boxes = []
total_area = 0
number_of_boxes.times do
  a , b = gets.split(" ").map{|n| n.to_i}
  return "input error" if (a.nil? || b.nil?)
  area = a*b
  puts "Box: #{a} x #{b} - #{area}u : #{total_area += area}u total"
  boxes << [a,b]
end
inspect boxes
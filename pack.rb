total_boxes = gets.to_i
return "Not an int" if total_boxes.nil?
puts "Boxes: #{total_boxes}"
total_area = 0
total_boxes.times do
  a , b = gets.split(" ").map{|n| n.to_i}
  return "input error" if (a.nil? || b.nil?)
  area = a*b
  puts "Box: #{a} x #{b} - #{area}u : #{total_area += area}u total"
  
end
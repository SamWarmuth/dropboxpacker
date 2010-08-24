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

best = 1.0/0
[:stack, :stack_foldback, :foldback_skinny_settle, :reversing_skinny_settle, :conservative_duplex, :presort_duplex, :dual_rotate_duplex, :skinny_triplex].each do |method|
  db.calculate_best_fill(method)
  
  if db.actual_area < best
    best = db.actual_area
  end
end
puts best
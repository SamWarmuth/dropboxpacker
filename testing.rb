require 'pack'

iterations = 1000
wins = {}
average_time = {}
waste = {:best => 0}
[:stack, :stack_foldback, :foldback_with_skinny, :foldback_skinny_settle, :reversing_skinny_settle, :naive_duplex, :conservative_duplex, :presort_duplex, :dual_rotate_duplex, :skinny_triplex].each{|m| wins[m] = 0; average_time[m] = 0; waste[m] = 0}
iterations.times do |i|
  dropbox = Dropbox.new
  current_best = 1.0/0
  least_waste = 0
  best_method = nil
  (rand(100)+1).times {dropbox.add_box(Box.new(rand(100)+1, rand(100)+1))}
  [:stack, :stack_foldback, :foldback_with_skinny, :foldback_skinny_settle, :reversing_skinny_settle, :naive_duplex, :conservative_duplex, :presort_duplex, :dual_rotate_duplex, :skinny_triplex].each do |method|
    #puts "--"+method.to_s
    time = Time.now
    dropbox.calculate_best_fill(method)
    puts "COLLLLLLLLLLLLLLLLLLLLLLLLLLLLISION!!!!!" if dropbox.collision?
    
    time = Time.now - time
    average_time[method] += (time / iterations)
    waste[method] += (dropbox.waste / iterations)
    if dropbox.actual_area < current_best
      best_method = method
      least_waste = dropbox.waste
      current_best = dropbox.actual_area
    end
  end
  puts "Round #{i}: " +best_method.to_s
  waste[:best] += (least_waste / iterations)
  wins[best_method] += 1
end
puts "\nWINS"
wins.each_pair{|key, val| puts "#{key}: #{val} (#{(val/iterations.to_f)*100}%)"}
puts "\nAVG WASTE"
waste.each_pair{|key, val| puts "#{key}: #{val}%"}
puts "\nAVG TIME"
average_time.each_pair{|key, val| puts "#{key}: #{val}"}
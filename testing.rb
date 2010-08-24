require 'pack'

iterations = 20
wins = {}
average_time = {}
iterations.times do |i|
  dropbox = Dropbox.new
  current_best = 10000000000.0
  best_method = nil
  (rand(100)+1).times {dropbox.add_box(Box.new(rand(100)+1, rand(100)+1))}
  [:stack, :stack_foldback, :foldback_with_skinny, :reversing_skinny_settle, :naive_duplex, :conservative_duplex, :presort_duplex, :dual_rotate_duplex, :skinny_triplex].each do |method|
    #puts "--"+method.to_s
    time = Time.now
    dropbox.calculate_best_fill(method)
    puts "EXPLOSION EXPLOSION EXPLOSION EXPLOSION BARKJAKLSJFSDFJDSKJG" if dropbox.collision?
    
    time = Time.now - time
    average_time[method] ||= 0
    average_time[method] += (time / iterations)
    if dropbox.actual_area < current_best
      best_method = method
      current_best = dropbox.actual_area
    end
  end
  puts "Round #{i}: " +best_method.to_s
  wins[best_method] ||= 0
  wins[best_method] += 1
end
puts "\nWINS"
wins.each_pair{|key, val| puts "#{key}: #{val} (#{(val/iterations.to_f)*100}%)"}
puts "\nAVG. TIME"
average_time.each_pair{|key, val| puts "#{key}: #{val}"}
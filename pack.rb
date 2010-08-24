class Dropbox
  attr_accessor :boxes
  attr_reader :width, :height, :absolute_area, :actual_area
  attr_accessor :dropbox
  def initialize
    @boxes = []
  end
  def collision?(test_box = nil)
    valid_boxes = @boxes.find_all{|b| !b.x.nil?}
    test_box = test_box.nil? ? valid_boxes : Array(test_box)
    test_box.each do |box|
      valid_boxes.each do |b|
        next if b == box
        if (box.x < (b.x + b.width) && b.x < (box.x+box.width)) && (box.y < (b.y + b.height) && (b.y < (box.y + box.height)))
          return true
        end
      end
    end
    return false
  end
  def reset_box_orientations
    @boxes.each{|box| box.width, box.height = box.height, box.width if box.height > box.width}
  end
  def add_box(box)
    @boxes << box if @boxes.find{|b| b == box}.nil?
  end
  def waste
    ((@actual_area-@absolute_area)/@actual_area.to_f)*100
  end
  def calculate_best_fill(method)
    @width = 0
    @height = 0
    @absolute_area = @boxes.inject(0){|sum, box| sum + box.width*box.height}
    @boxes.each{|b| b.x = nil; b.y = nil}
    by_width = @boxes.sort_by{|box| box.width * -1}
    reset_box_orientations
    case method
    when :stack
      by_width.each do |box|
        box.x, box.y = 0, @height
        @width = box.width if box.width > @width
        @height+= box.height
      end
    when :stack_foldback
      max = by_width.first.width.to_f
      total_height = @boxes.inject(0){|sum, box| sum + box.height}
      offset = 0
      max_height = 0
      by_width.each_with_index do |box, i|
        if @height > (total_height/4)
          offset = @width
          max_height = @height if @height > max_height
          @height = 0
        end
        box.x, box.y = offset, @height
        
        @width = (box.x + box.width) if (box.x + box.width) > @width
        @height+= box.height
      end
      @height = max_height if max_height > @height
      breakpoints = []
      current_height = 0
      by_width.each do |box|
        current_height += box.height
      end
    when :foldback_with_skinny
      columns = 5
      total_height = @boxes.inject(0){|sum, box| sum + box.height}
            
      max = by_width.first.width.to_f
      skinny_width = 0
      skinny_height = 0

      by_width.sort_by{|b| 1/(b.height / b.width.to_f)}.reverse.each do |box|
        break if (skinny_height+box.height) > (total_height / (columns-1))
        box.width, box.height = box.height, box.width
        box.x, box.y = 0, skinny_height
        @width = box.width if box.width > @width
        skinny_width = @width
        skinny_height += box.height
      end
      by_width = by_width.find_all{|b| b.x.nil?}
      max = by_width.first.width.to_f
      

      offset = skinny_width
      max_height = skinny_height
      by_width.each_with_index do |box, i|
        if @height > (total_height/(columns-1))
          offset = @width
          max_height = @height if @height > max_height
          @height = 0
        end
        box.x, box.y = offset, @height
        @width = (box.x + box.width) if (box.x + box.width) > @width
        @height+= box.height
      end
      @height = max_height if max_height > @height
    when :foldback_skinny_settle
      columns = 5
      total_height = @boxes.inject(0){|sum, box| sum + box.height}
      
      max = by_width.first.width.to_f
      skinny_width = 0
      skinny_height = 0

      by_width.sort_by{|b| 1/(b.height / b.width.to_f)}.reverse.each do |box|
        break if (skinny_height+box.height) > (total_height / (columns-1))
        box.width, box.height = box.height, box.width
        box.x, box.y = 0, skinny_height
        @width = box.width if box.width > @width
        skinny_width = @width
        skinny_height += box.height
      end
      max = by_width.find_all{|b| b.x.nil?}.first.width.to_f
      
      offset = skinny_width
      max_height = skinny_height
      by_width.find_all{|b| b.x.nil?}.each_with_index do |box, i|
        if (@height+box.height) > (total_height/(columns-1))
          offset = @width
          max_height = @height if @height > max_height
          @height = 0
        end
        box.x, box.y = offset, @height
        jump = max/10
        while (collision?(box) == false) && (box.x > 0)
          box.x -= jump
        end
        box.x += jump
        while (collision?(box) == false) && (box.x > 0)
          box.x -= 4
        end
        box.x += 4
        while (collision?(box) == false) && (box.x > 0)
          box.x -= 1
        end
        box.x += 1
        @width = (box.x + box.width) if (box.x + box.width) > @width
        @height+= box.height
      end
      @height = max_height if max_height > @height
    when :reversing_skinny_settle
      columns = 4
      total_height = @boxes.inject(0){|sum, box| sum + box.height}


      max = by_width.first.width.to_f
      skinny_width = 0
      skinny_height = 0

      by_width.sort_by{|b| 1/(b.height / b.width.to_f)}.reverse.each do |box|
        break if (skinny_height + box.height) > (total_height*0.95 / (columns-1))
        box.width, box.height = box.height, box.width
        box.x, box.y = 0, skinny_height
        @width = box.width if box.width > @width
        skinny_width = @width
        skinny_height += box.height
      end
      by_width = by_width.find_all{|b| b.x.nil?}
      max = by_width.first.width.to_f

      offset = skinny_width
      max_height = skinny_height
      iterations = 0
      while !by_width.empty?
        by_width.each_with_index do |box, i|
          iterations += 1
          #puts "bh #{box.height} - @h #{@height} - th #{total_height} - col-1 #{columns-1}"
          if ((box.height + @height) > ((total_height*1.02)/(columns-1))) && iterations < 300
            offset = @width
            max_height = @height if @height > max_height
            @height = 0
            by_width = by_width.find_all{|b| b.x.nil?}
            retry
          end
          box.x, box.y = offset, @height
          jump = max/10
          while (collision?(box) == false) && (box.x > 0)
            box.x -= jump
          end
          box.x += jump
          while (collision?(box) == false) && (box.x > 0)
            box.x -= 4
          end
          box.x += 4
          while (collision?(box) == false) && (box.x > 0)
            box.x -= 1
          end
          box.x += 1
          @width = (box.x + box.width) if (box.x + box.width) > @width
          @height+= box.height
        end
        by_width = by_width.find_all{|b| b.x.nil?}.reverse
      end
      @height = max_height if max_height > @height
    when :x_stack
      by_width.each do |box|
        box.x, box.y = @width, 0
        @width += box.width
        @height = box.height if box.height > @height
      end
    when :naive_duplex
      by_width.each_with_index do |box, i|
        next unless box.x.nil?
        box.x, box.y = 0, @height
        width = box.width
        height = box.height
        partner = by_width[(by_width.size - i)-1]
        unless partner.nil? || (by_width.size - i == i)
          partner.x = (box.x+box.width) 
          partner.y = @height
          width = partner.width + box.width
          height = (box.height > partner.height ? box.height : partner.height)
        end
        @width = width if width > @width
        @height += height
      end
    when :conservative_duplex
      max = by_width.first.width.to_f
      by_width.each_with_index do |box, i|
        next unless box.x.nil?
        box.x, box.y = 0, @height
        width = box.width
        height = box.height
        partner = by_width.find_all{|b| b.x.nil?}.sort_by{|b| ((b.width - box.height + max/8).abs * 10) + (((box.width + b.height)-max +10).abs * 10)}.first
        
        if !partner.nil? && (partner.width.to_f / partner.height.to_f < 4.0) && ((partner.width / box.height) < 2.5) && (partner.height + box.width < max)
          partner.width, partner.height = partner.height, partner.width
          partner.x = (box.x+box.width) 
          partner.y = @height
          width = partner.width + box.width
          height = (box.height > partner.height ? box.height : partner.height)
        end
        @width = width if width > @width
        @height += height
      end
    when :presort_duplex
      max = by_width.first.width.to_f
      sorted = by_width.sort_by{|box| by_width.map{|b| ((b.width - box.height + max/8).abs * 10) + (((box.width + b.height) - max + 5).abs * 10)}.min}
      sorted.each_with_index do |box, i|
        next unless box.x.nil?
        box.x, box.y = 0, @height
        width = box.width
        height = box.height
        partner = by_width.find_all{|b| b.x.nil?}.sort_by{|b| ((b.width - box.height + max/8).abs * 10) + (((box.width + b.height)-max +5 ).abs * 10)}.first
      
        if !partner.nil? && (partner.width.to_f / partner.height.to_f < 4.0) && ((partner.width / box.height) < 2.5)
          partner.width, partner.height = partner.height, partner.width
          partner.x = (box.x+box.width) 
          partner.y = @height
          width = partner.width + box.width
          height = (box.height > partner.height ? box.height : partner.height)
        end
        @width = width if width > @width
        @height += height
      end
    when :dual_rotate_duplex
      max = by_width.first.width.to_f
      sorted = by_width.find_all{|b| b.x.nil?}.sort_by{|box| [by_width.map{|b| ((b.width - box.height + max/8).abs * 10) + (((box.width + b.height) - max + 5).abs * 10)}.min, by_width.map{|b| (((b.height - box.height + max/8).abs * 10) + ((box.width + b.width - max +5).abs * 10))}.min].min}
      sorted.each_with_index do |box, i|
        next unless box.x.nil?
        box.x, box.y = 0, @height
        width = box.width
        height = box.height
        partnerA = by_width.find_all{|b| b.x.nil?}.map{|b| [b, ((b.height - box.height + max/8).abs * 10) + (((box.width + b.width)-max +5 ).abs * 10)]}.min{|a,b| a[1] <=> b[1]}
        partnerB = by_width.find_all{|b| b.x.nil?}.map{|b| [b, ((b.width - box.height + max/8).abs * 10) + (((box.width + b.height)-max +5 ).abs * 10)]}.min{|a,b| a[1] <=> b[1]}
        partner = nil
        rotate = false
        if !partnerA.nil? && !partnerB.nil? && partnerA[1] < partnerB[1] && (box.height / partnerA[0].height < 1.3) && (box.width + partnerA[0].width < max)
          partner = partnerA[0]
        elsif !partnerA.nil? && !partnerB.nil? && !(box.height / partnerB[0].width < 0.25) && (box.width + partnerB[0].height < max)
          rotate = true
          partner = partnerB[0]
        end
        
        if !partner.nil?
          partner.width, partner.height = partner.height, partner.width if rotate
          partner.x = (box.x+box.width) 
          partner.y = @height
          width = partner.width + box.width
          height = (box.height > partner.height ? box.height : partner.height)
        end
        @width = width if width > @width
        @height += height
      end
    when :skinny_triplex
      max = by_width.first.width.to_f
      by_width.each{|b| b.x = -1 if b.height < b.width / 10.0}
      if by_width.find_all{|b| b.x.nil?}.empty? #all of them are skinny. Bail.
        by_width.each{|b| b.x = nil}
      end
      max = by_width.find_all{|b| b.x.nil?}.first.width.to_f
      skinny_width = 0
      skinny_height = 0
      sorted = by_width.find_all{|b| b.x.nil?}.sort_by{|box| by_width.map{|b| ((b.width - box.height + max/8).abs * 10) + (((box.width + b.height) - max + 5).abs * 10)}.min}
      by_width.find_all{|b| b.x == -1}.sort_by{|b| b.height}.reverse.each do |box|
        box.width, box.height = box.height, box.width
        box.x, box.y = 0, skinny_height
        @width = box.width if box.width > @width
        skinny_width = @width
        skinny_height += box.height
      end
      sorted.each_with_index do |box, i|
        next unless box.x.nil?
        actual_skinny_width = skinny_width
        actual_skinny_width = 0 if @height > skinny_height
        
        box.x, box.y = actual_skinny_width, @height
        width = box.width+actual_skinny_width
        height = box.height
        partner = by_width.find_all{|b| b.x.nil?}.sort_by{|b| ((b.width - box.height + max/8).abs * 10) + (((box.width + b.height)-max +5 ).abs * 10)}.first
      
        if !partner.nil? && (partner.width.to_f / partner.height.to_f < 4.0) && ((partner.width / box.height) < 2.5)
          partner.width, partner.height = partner.height, partner.width
          partner.x = (box.x+box.width) 
          partner.y = @height
          width = partner.width + box.width + actual_skinny_width
          height = (box.height > partner.height ? box.height : partner.height)
        end
        @width = width if width > @width
        @height += height
      end
      @height = skinny_height if skinny_height > @height
    end
    @actual_area = @width*@height
    return self
  end
end

class Box
  attr_accessor :width, :height, :x, :y
  def ==(other_box)
    return false if other_box.nil?
    return true if (@width == other_box.width && @height == other_box.height) || (@width == other_box.height && @height == other_box.width)
    return false
  end
  def initialize(width,height)
    @width = width
    @height = height
  end
end
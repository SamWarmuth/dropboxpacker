class Dropbox
  attr_accessor :boxes
  attr_reader :width, :height, :absolute_area, :actual_area
  attr_accessor :dropbox
  def initialize
    @boxes = []
  end
  def collision?
    collision = false
    @boxes.each do |box|
      @boxes.find_all{|b| b != box}.each do |box2|
        if (box.x < (box2.x + box2.width) && box2.x < (box.x+box.width)) && (box.y < (box2.y + box2.height) && (box2.y < (box.y + box.height)))
          collision = true
        end
      end
    end
    return collision
  end
  def reset_box_orientations
    @boxes.each{|box| box.width, box.height = box.height, box.width if box.height > box.width}
  end
  def calculate_best_fill(method)
    @width = 0
    @height = 0
    @absolute_area = @boxes.inject(0){|sum, box| sum + box.width*box.height}
    @boxes.each{|b| b.x = nil; b.y = nil}
    reset_box_orientations
    case method
    when :y_stack
      by_width = @boxes.sort_by{|box| box.width * -1}
      by_width.each do |box|
        box.x, box.y = 0, @height
        @width = box.width if box.width > @width
        @height+= box.height
      end
    when :x_stack
      by_width = @boxes.sort_by{|box| box.width * -1}
      by_width.each do |box|
        box.x, box.y = @width, 0
        @width += box.width
        @height = box.height if box.height > @height
      end
    when :naive_duplex
      by_width = @boxes.sort_by{|box| box.width * -1}
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
    when :better_duplex
      by_width = @boxes.sort_by{|box| box.width * -1}
      max = by_width.first.width.to_f
      by_width.each_with_index do |box, i|
        next unless box.x.nil?
        box.x, box.y = 0, @height
        width = box.width
        height = box.height
        partner = by_width.find_all{|b| b.x.nil?}.sort_by{|b| ((b.width - box.height + max/8).abs * 10) + (((box.width + b.height)-max +10).abs * 10)}.first
        
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
    when :best_duplex
      by_width = @boxes.sort_by{|box| box.width * -1}
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
    when :skinny_triplex
      by_width = @boxes.sort_by{|box| box.width * -1}
      max = by_width.first.width.to_f
      by_width.each{|b| b.x = -1 if b.height < b.width / 10.0}
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
      puts skinny_width
      sorted.each_with_index do |box, i|
        next unless box.x.nil?
        box.x, box.y = skinny_width, @height
        width = box.width+skinny_width
        height = box.height
        partner = by_width.find_all{|b| b.x.nil?}.sort_by{|b| ((b.width - box.height + max/8).abs * 10) + (((box.width + b.height)-max +5 ).abs * 10)}.first
      
        if !partner.nil? && (partner.width.to_f / partner.height.to_f < 4.0) && ((partner.width / box.height) < 2.5)
          partner.width, partner.height = partner.height, partner.width
          partner.x = (box.x+box.width) 
          partner.y = @height
          width = partner.width + box.width + skinny_width
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
  def initialize(width,height)
    @width = width
    @height = height
  end
end
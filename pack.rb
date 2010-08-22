class Dropbox
  attr_accessor :boxes
  attr_reader :vertices
  attr_accessor :dropbox
  def initialize
    @boxes = []
    @dropbox = Array.new(0, [])
  end
  def calculate_best_fill
    db.boxes.uniq!
    db.boxes = db.boxes.sort_by{|box| box[0]*-1}
    @boxes.each_with_index do |box, i|
      @vertices[i] = [i*10, 0]
    end
  end
  def area
    return 0 if @boxes.nil?
    return @boxes.inject(0){|area, box| area + box[0]*box[1]}
  end
end

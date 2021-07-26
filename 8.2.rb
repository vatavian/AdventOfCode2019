# Advent of Code 2019 Day 8 part 2 https://adventofcode.com/2019/day/8#part2
# Space Image Format: Stacking

class Image
  attr_accessor :layers
  def initialize(width, height, input)
    @width = width
    @height = height
    @layer_length = width * height
    @layers = []
    begin
      while input
        @layers << input.readpartial(@layer_length)
        if @layers[@layers.length - 1].length < 2
          @layers.pop
          break
        end
      end
    rescue EOFError
      puts "Read #{@layers.length} layers before EOF"
      input = nil
    end
    puts "Initialized #{@layers.length} #{@width} x #{@height} layers"
  end

  def print_layer(layer)
    i = 0
    (1..@height).each do |row|
      print "#{row}:  "
      (1..@width).each do |col|
        if layer[i] == '0'
          print "   "
        else
          print "#{layer[i]}  "
        end
        i += 1
      end
      puts
    end
  end

  def stack_layers
    stacked_image = Array.new(@layer_length)
    stacked_image.fill('2')
    @layers.each do |layer|
      layer.each_char.with_index do |pixel, index|
        if stacked_image[index] == '2'
          stacked_image[index] = pixel
        end
      end
    end
    stacked_image
  end
end

input = File.open('8-input.txt')
img = Image.new(25, 6, input)

img.print_layer(img.stack_layers)

# Advent of Code 2019 Day 8 part 1 https://adventofcode.com/2019/day/8
# Space Image Format

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
        print "#{layer[i]}  "
        i += 1
      end
      puts
    end
  end

end

input = File.open('8-input.txt')
img = Image.new(25, 6, input)

layer_with_min_zeroes = nil
min_zeroes = 100

img.layers.each_with_index do |layer, index|
  zeroes = layer.count('0')
  if zeroes < min_zeroes
    min_zeroes = zeroes
    layer_with_min_zeroes = layer
  end
end

ones = layer_with_min_zeroes.count('1')
twos = layer_with_min_zeroes.count('2')
puts "Layer with minimum zeroes had #{min_zeroes} zeroes, #{ones} ones, #{twos} twos, 1s x 2s = #{ones * twos}"

img.print_layer(layer_with_min_zeroes)

# Advent of Code 2019 Day 16 Part One https://adventofcode.com/2019/day/16
# Flawed Frequency Transmission

class FlawedFT
  attr_accessor :list
  
  def initialize(filename)
    @list = File.readlines(filename)[0].chomp.chars.map { |n| n.to_i }
    @base_pattern = [0, 1, 0, -1]
    @time_step = 0
  end

  def to_s
    return "After phase #{@time_step}: #{@list[0..7].join('')}"
  end

  def next_phase
    @time_step += 1
    next_list = []
    list_len = @list.length
    @list.each_with_index do |n, new_index|
      next_list[new_index] = 0
      old_index = new_index
      position = new_index + 1
      pattern = @base_pattern.cycle
      pattern.next
      while old_index < list_len
        pattern_digit = pattern.next
        position.times do
          next_list[new_index] += @list[old_index] * pattern_digit
          # print "#{@list[old_index]}*#{pattern_digit} + "
          old_index += 1
          break if old_index >= list_len
        end
      end
      new_digit = next_list[new_index].to_s.chars[-1].to_i
      # puts " = #{next_list[new_index]} => #{new_digit}"
      next_list[new_index] = new_digit
    end
    @list = next_list
  end
  
end

fft = FlawedFT.new('16-input.txt')
puts "Input signal #{fft.to_s}"
100.times {
  fft.next_phase
}
puts fft.to_s

# Advent of Code 2019 Day 3 Part Two https://adventofcode.com/2019/day/3#part2

require 'csv'

MAX = 2147483647

def run_wire(wire_moves, other_wire_path)
  if other_wire_path
    closest = MAX
  else
    wire_path = Hash.new
    wire_path.default = MAX/2
  end
  x = 0
  y = 0
  steps = 0
  wire_moves.each do |move|
    direction = move[0]
    distance = move[1..-1].to_i
    case direction
    when 'R'
      dx = 1; dy = 0
    when 'L'
      dx = -1; dy = 0
    when 'U'
      dx = 0; dy = 1
    when 'D'
      dx = 0; dy = -1
    else
      p 'Error: found direction ' + direction
      return 
    end
    for step in 1..distance
      steps += 1
      x += dx
      y += dy
      key = x.to_s + "," + y.to_s
      if other_wire_path
        distance = steps + other_wire_path[key]
        if distance < closest
          closest = distance
        end
      else
        wire_path[key] = steps
      end
    end
  end
  other_wire_path ? closest : wire_path
end

  paths = CSV.read('3-input-sample1.txt', converters: :numeric)
  path1 = run_wire(paths[0], nil)
  p run_wire(paths[1], path1)

  paths = CSV.read('3-input-sample2.txt', converters: :numeric)
  path1 = run_wire(paths[0], nil)
  p run_wire(paths[1], path1)


#(1..12).each do |mass|
#  p mass.to_s + ' needs ' + calc_fuel_needed(mass).to_s + ' fuel'
#end

#loop do
  paths = CSV.read('3-input.txt', converters: :numeric)
  path1 = run_wire(paths[0], nil)
  p run_wire(paths[1], path1)
#end

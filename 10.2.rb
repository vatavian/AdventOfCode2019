# Advent of Code 2019 Day 10 part 2
# https://adventofcode.com/2019/day/10#part2
# Complete Vaporization by Giant Laser
# Find the last asteroid that will be destroyed

class Asteroids
  attr_accessor :all_asteroids
  attr_reader :num_asteroids

  def initialize(initial_occupancy)
    @all_asteroids = initial_occupancy
    @max_row = @all_asteroids.length - 1
    @max_col = @all_asteroids[0].length - 1
    @num_asteroids = 0 # gets set in find_max_seen
    @directions = []
    (0..@max_row).each do |row_delta|
      (0..@max_col).each do |col_delta|
        if row_delta != 0 || col_delta != 0
          @directions.append [row_delta, col_delta] 
          @directions.append [-row_delta, col_delta] 
          @directions.append [row_delta, -col_delta] 
          @directions.append [-row_delta, -col_delta] 
        end
      end
    end
  end

  def find_in_direction(row, col, row_dir, col_dir, found_slopes)
    if col_dir == 0
      slope = row_dir > 0 ? :up : :down
    elsif row_dir == 0
      slope = col_dir > 0 ? :right : :left
    else
      if col_dir > 0
        quadrant = row_dir > 0 ? 1 : 4
      else
        quadrant = row_dir > 0 ? 2 : 3
      end
      slope = [Rational(row_dir, col_dir), quadrant]
    end
    
    return 0 if found_slopes[slope]

    check_row = row + row_dir
    check_col = col + col_dir
    while check_row >= 0 &&
          check_col >= 0 &&
          check_row <= @max_row &&
          check_col <= @max_col
      if @all_asteroids[check_row][check_col] == '#'
        found_slopes[slope] = true
        return 1
      end
      check_row += row_dir
      check_col += col_dir
    end
    return 0
  end

  def num_seen_from(row, col, found_slopes)
    num_seen = 0
    @directions.each do |direction|
      num_seen += self.find_in_direction(row, col, direction[0], direction[1], found_slopes)
    end
    num_seen
  end

  def find_max_seen
    @num_asteroids = 0
    num_slopes = 0
    max_seen = 0
    best_coords = [-1, -1]
    @all_asteroids.each_with_index do |row_values, row_index|
      row_values.each_char.with_index do |map_char, col_index|
        if map_char == '#'
          @num_asteroids += 1
          found_slopes = Hash.new
          num_seen = num_seen_from(row_index, col_index, found_slopes)
          if num_seen > max_seen
            max_seen = num_seen
            best_coords = [col_index, row_index]
            num_slopes = found_slopes.length
          end
        end
      end
    end
    p "#{max_seen} seen from #{best_coords} (#{num_slopes} directions)"
    p "#{@num_asteroids} total asteroids searched"
    best_coords
  end

  def print_all
    @all_asteroids.each {|row| p row}
  end

  def angle_clockwise_from_vertical(x1, y1, x2, y2)
    angle = Math.atan2(x2 - x1, y2 - y1)
    angle < 0 ? angle + Math::PI * 2 : angle
  end
  
  def find_all_direction_and_distance(col, row)
    found = Hash.new
    @all_asteroids.each_with_index do |row_values, search_row|
      row_values.each_char.with_index do |map_char, search_col|
        if map_char == '#' && (search_row != row || search_col != col)
          angle = angle_clockwise_from_vertical(col, @max_row - row, search_col, @max_row - search_row)
          # Manhattan distance works for this grid
          distance = (search_row - row).abs + (search_col - col).abs
          found[angle] ||= Hash.new
          found[angle][distance] = [search_col, search_row]
        end
      end
    end
    found
  end

end

field = Asteroids.new(IO.readlines('10-input.txt', chomp: true))

#[[0,1],[1,1],[2,1],[1,0],[1,-1],[0,-1],[-1,-1],[-1,0],[-1,1]].each do |pt2|
#  p pt2, field.angle_clockwise_from_vertical(0,0,pt2[0],pt2[1])
#end

laser_col, laser_row = field.find_max_seen
all_directions = field.find_all_direction_and_distance(laser_col, laser_row)
asteroid_index = 0
angles = all_directions.keys.sort
max_asteroid_index = field.num_asteroids - 1 # Will not be destroying the one with the laser
while asteroid_index < max_asteroid_index
  angles.each do |angle|
    if asteroids = all_directions[angle]
      distance, coords = asteroids.min
      if coords
        asteroid_index += 1
        if [1,2,3,10,20,50,100,199,200,201,299].include?(asteroid_index)
          p "Destroy \# #{asteroid_index} #{coords} direction: #{angle} " +
            "distance: #{distance} X*100+y=#{coords[0]*100+coords[1]}"
        end
        asteroids.delete distance
        break if asteroid_index >= max_asteroid_index
      end
    end
  end
end
#field.print_all

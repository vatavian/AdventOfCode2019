# Advent of Code 2019 Day 10 part 1
# Asteroid Monitoring Station
# Find the asteroid that can see the most other asteroids in a 2-d grid
# 395 is too high
require 'prime'

class Asteroids
  attr_accessor :all_asteroids

  def initialize(initial_occupancy)
    @all_asteroids = initial_occupancy
    @max_row = @all_asteroids.length - 1
    @max_col = @all_asteroids[0].length - 1
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
    num_asteroids = 0
    num_slopes = 0
    max_seen = 0
    best_coords = [-1, -1]
    @all_asteroids.each_with_index do |row_values, row_index|
      row_values.each_char.with_index do |map_char, col_index|
        if map_char == '#'
          num_asteroids += 1
          found_slopes = Hash.new
          num_seen = num_seen_from(row_index, col_index, found_slopes)
          #p "#{num_seen} seen (#{found_slopes.length} directions)"
          if num_seen > max_seen
            max_seen = num_seen
            best_coords = [col_index, row_index]
            num_slopes = found_slopes.length
          end
        end
      end
    end
    p "#{max_seen} seen from #{best_coords} (#{num_slopes} directions)"
    p "#{num_asteroids} total asteroids searched"
  end

  def print_all
    @all_asteroids.each {|row| p row}
  end
end

field = Asteroids.new(IO.readlines('10-input.txt', chomp: true))
field.find_max_seen
#field.print_all

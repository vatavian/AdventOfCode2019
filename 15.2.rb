# Advent of Code 2019 Day 15 Part Two https://adventofcode.com/2019/day/15#part2
# Oxygen System Repaired: How many steps does it take for all the floor to fill with oxygen?

class Board
  attr_accessor :tiles
  
  def initialize(filename)
    @tiles = File.readlines(filename).map { |bs| bs.chomp.chars }
    @time_step = 0
  end

  def spread_oxygen_throughout
    @time_step = 0
    frontier = self.find_frontier
    p "Initial frontier: #{frontier}"
    while frontier.length > 0
      @time_step += 1
      frontier = self.next_minute(frontier)
      self.print_tiles
    end
  end

  # Expand oxygen north, south, east, and west from tiles in frontier.
  # Return the new frontier of tiles oxygen just now spread into.
  def next_minute(frontier)
    new_frontier = []
    frontier.each do |x, y|
      [[x-1, y], [x+1, y], [x, y-1], [x, y+1]].each do |newx, newy|
        if @tiles[newy][newx] == '.'
          @tiles[newy][newx] = 'O'
          new_frontier << [newx, newy]
        end
      end
    end
    new_frontier
  end

  def find_frontier
    frontier = []
    @tiles.each_with_index do |line, y|
      line.each_with_index do |tile, x|
        frontier << [x, y] if tile == 'O'
      end
    end
    frontier
  end
  
  def print_tiles
    puts "At time #{@time_step}"
    @tiles.each do |line|
      puts line.join('')
    end
  end
end

board = Board.new('15-board.txt')
board.spread_oxygen_throughout




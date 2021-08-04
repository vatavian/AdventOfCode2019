# Advent of Code 2019 Day 15 Part One https://adventofcode.com/2019/day/15
# Oxygen System: Intcode-driven repair droid in an unknown maze
class Integer
  def split_digits
    return [0] if zero?
    res = []
    quotient = self.abs #take care of negative integers
    until quotient.zero? do
      quotient, modulus = quotient.divmod(10) #one go!
      res.unshift(modulus) #put the new value on the first place, shifting all other values
    end
    res # done
  end
end

class Program < Array
  def initialize( init_array )
    super( init_array )
  end

  def get(index)
    index >= self.length ? 0 : self[index]
  end
end

class Board
  Max_moves = 9999999
  Tile_char = { :unknown => '?', :floor => '.', :wall => '#', :goal => 'O', :droid => '@' }
  attr_accessor :tiles
  
  def initialize
    self.set_defaults
  end

  def set_defaults
    @pc = 0
    @relative_base = 0
    @program = []
    @debug = false
    @tiles = Hash.new(:unknown) # keys are coordinate pairs, values are Tile_char keys (:unknown, :floor, :wall, :goal)
    @min_distance = Hash.new(Max_moves) # keys are coordinate pairs, values are how many moves it takes to get to that tile
    @dirs = {north: [0,1], west: [-1,0], south: [0,-1], east: [1,0]} # each is the [dx, dy] to go in that direction
    @left_turns = {@dirs[:north] => @dirs[:west], @dirs[:west] => @dirs[:south], @dirs[:south] => @dirs[:east], @dirs[:east] => @dirs[:north]}
    @right_turns = @left_turns.invert
    @moves = [] # contains [position, direction] pairs already visited on current path
    @position = [0,0] # start at the origin
    @tiles[@position] = :floor # start on a floor tile
    @next_position = nil
    @direction = nil
    @input_dir_from_value = { 1 => :north, 2 => :south, 3 => :west, 4 => :east }
    @input_value_from_char = { 'n' => 1, 's' => 2, 'w' => 3, 'e' => 4 }
  end
  
  def param_val(param_modes, param_index)
    if param_index <= param_modes.length
      mode = param_modes[param_index-1]
    else
      mode = 0
    end
    param_int = @program[@pc+param_index]
    case mode
    when 0
      p 'param[' + param_index.to_s + '] = ' + param_int.to_s + ' mode ' + mode.to_s + ' -> ' + @program.get(param_int).to_s if @debug
      return @program.get(param_int)
    when 1
      p 'param[' + param_index.to_s + '] = ' + param_int.to_s + ' mode ' + mode.to_s if @debug
      return param_int
    when 2
      p 'param[' + param_index.to_s + '] = ' + param_int.to_s + ' mode ' + mode.to_s + ' -> ' + @program.get(@relative_base + param_int).to_s if @debug
      return @program.get(@relative_base + param_int)
    else
      p 'Error: found param mode ' + mode.to_s + ' at instruction index ' + @pc.to_s + ' parameter ' + param_index.to_s
    end
  end

  def param_address(param_modes, param_index)
    if param_index <= param_modes.length
      mode = param_modes[param_index-1]
    else
      mode = 0
    end
    param_int = @program[@pc+param_index]
    case mode
    when 0
      p "param_address[#{param_index}] = #{param_int} mode #{mode} Replaces #{@program.fetch(param_int, "uninitialized")}" if @debug
      return param_int
    when 2
      p "param_address[#{param_index}] = #{param_int} + relative base #{@relative_base} = #{@relative_base + param_int} Replaces #{@program.fetch(@relative_base + param_int, "uninitialized")}" if @debug 
      return @relative_base + param_int
    else
      p 'Error: found param mode ' + mode.to_s + ' at instruction index ' + @pc.to_s + ' parameter ' + param_index.to_s
    end
  end

  def run(program, first_moves = [])
    self.set_defaults
    @program = Program.new(program)
    loop do
      instruction = @program[@pc]
      modesint, opcode = instruction.divmod 100
      param_modes = modesint.split_digits.reverse
      p 'pc ' + @pc.to_s + ' instruction ' + instruction.to_s + ' modesint ' + modesint.to_s + ' modes ' + param_modes.to_s + ' opcode ' + opcode.to_s if @debug

      case opcode
      when 1 # add first two params, put result at program address of third param
        p1 = param_val(param_modes, 1)
        p2 = param_val(param_modes, 2)
        p3 = param_address(param_modes, 3)
        p "Add: #{p1} + #{p2} = #{p1 + p2} -> [#{p3}] (replaces #{@program.fetch(p3, 'uninitialized')})" if @debug
        @program[p3] = p1 + p2
        @pc += 4
      when 2 # multiply first two params, put result at program address of third param
        p1 = param_val(param_modes, 1)
        p2 = param_val(param_modes, 2)
        p3 = param_address(param_modes, 3)
        p "Multiply: #{p1} * #{p2} = #{p1 * p2} -> [#{p3}] (replaces #{@program.fetch(p3, 'uninitialized')})" if @debug
        @program[p3] = p1 * p2
        @pc += 4
      when 3 # takes a single integer as input and saves it to the position given by its only parameter
        save_address = param_address(param_modes, 1)
        #self.print_tiles
        #print 'Enter: n, s, e, or w: '
        #STDOUT.flush
        #move = gets.chomp
        #if move == 'q'
        #  puts "Quit Game with Score: #{@score} after #{@moves.length} Moves: \n#{@moves}"
        #  return @program
        #end
        #move = @input_value_from_char[move] || move.to_i
        #p "Move = #{move}"
        return @program if @moves.length >= Max_moves
        move = rand(4) + 1
        direction = @dirs[@input_dir_from_value[move]]
        @next_position = [@position[0] + direction[0], @position[1] + direction[1]]
        @program[save_address] = move
        #p 'input -> [' + save_address.to_s + '] = ' + @program[save_address].to_s
        @moves << @program[save_address]
        @pc += 2
      when 4 # outputs the value of its only parameter
        p1 = param_val(param_modes, 1)
        if p1 == 0 # hit a wall, position has not changed
          @tiles[@next_position] = :wall
        else # moved in requested direction and found floor if p1 == 1 or goal if p1 == 2
          # @min_distance[@next_position] = [@min_distance[@next_position], @min_distance[@location] + 1].min
          @tiles[@next_position] = (p1 == 1) ? :floor : :goal
          @position = @next_position
        end
        @moves << Tile_char[@tiles[@next_position]]
        @pc += 2
      when 5 # jump-if-true
        if param_val(param_modes, 1) != 0
          p2 = param_val(param_modes, 2)
          p "Jump to #{p2} because test was true" if @debug
          @pc = p2
        else
          p "Jump skipped because test was false" if @debug
          @pc += 3
        end
      when 6 # jump-if-false
        if param_val(param_modes, 1) == 0
          @pc = param_val(param_modes, 2)
        else
          @pc += 3
        end
      when 7 # less than
        p3 = param_address(param_modes, 3)
        @program[p3] = param_val(param_modes, 1) < param_val(param_modes, 2) ? 1 : 0
        p "Less Than -> #{@program[p3]}" if @debug
        @pc += 4
      when 8 # equals
        p3 = param_address(param_modes, 3)
        @program[p3] = param_val(param_modes, 1) == param_val(param_modes, 2) ? 1 : 0
        p "Equals -> #{@program[p3]}" if @debug
        @pc += 4
      when 9 # adjust relative base
        @relative_base += param_val(param_modes, 1).to_i
        p 'relative_base -> ' + @relative_base.to_s if @debug
        @pc += 2
      when 99
        puts "Game over! Score: #{@score} after #{@moves.length} Moves: \n#{@moves}"
        return @program
      else
        p 'Error: found opcode ' + @program[@pc].to_s + ' at ' + @pc.to_s
        return @program
      end
    end
  end

  def print_tiles
    min_x = 9999
    min_y = 9999
    max_x = -9999
    max_y = -9999
    #puts "#{@tiles.length} tiles have been drawn"
    @tiles.each_key do |coords|
      min_x = coords[0] if coords[0] < min_x
      min_y = coords[1] if coords[1] < min_y
      max_x = coords[0] if coords[0] > max_x
      max_y = coords[1] if coords[1] > max_y
    end
    #puts "Y values range from #{min_y} to #{max_y}"
    #puts "X values range from #{min_x} to #{max_x}"
    puts "At position #{@position} Move: #{@moves.length}"
    print ' '
    (min_x..max_x).each { |x| print x >= 0 ? x % 10 : '-' }
    puts
    y = max_y
    while y >= min_y
      print y >= 0 ? y % 10 : '-'
      (min_x..max_x).each do |x|
        print (x == 0 && y == 0) ? '@' : Tile_char[@tiles[[x, y]]]
      end
      puts
      y -= 1
    end
  end
end

require 'csv'
program = CSV.read('15-input.txt', converters: :numeric)[0]
first_moves = []
#first_moves = CSV.read('15-moves.txt', converters: :numeric)[0]
game = Board.new
game.run(program, first_moves)
game.print_tiles


# Advent of Code 2019 Day 17 Part Two https://adventofcode.com/2019/day/17#part2
# Set and Forget: Direct Intcode-driven robot to traverse scaffolding
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
  attr_accessor :tiles
  
  def initialize
    self.set_defaults
  end

  def set_defaults
    @pc = 0
    @relative_base = 0
    @program = []
    @debug = false
    @tiles = []
    @width = false
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
        #puts 'Input: '
        #STDOUT.flush
        #move = gets.chomp
        #if move == 'q'
        #  puts "Quit\n#{@moves}"
        #  return @program
        #else
        #  move = move.to_i
        #end
        move = first_moves.shift.ord
        @program[save_address] = move
        @pc += 2
      when 4 # outputs the value of its only parameter
        p1 = param_val(param_modes, 1)
        puts "Output: #{p1}"
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
        puts "Game over!" # Score: #{@score} after #{@moves.length} Moves: \n#{@moves}"
        return @program
      else
        p 'Error: found opcode ' + @program[@pc].to_s + ' at ' + @pc.to_s
        return @program
      end
    end
  end

  def is_junction(x, y)
    neighbors = 0
    if @tiles[x + y * @width] == '#'
      neighbors += 1 if y > 0 && @tiles[x + (y - 1) * @width] == '#'
      neighbors += 1 if x > 0 && @tiles[(x - 1) + y * @width] == '#'
      neighbors += 1 if x < (@width - 1) && @tiles[(x + 1) + y * @width] == '#'
      neighbors += 1 if y + @width < @tiles.length && @tiles[x + (y + 1) * @width] == '#'
    end
    neighbors > 2
  end
  
  def compute_alignment_parameters
    @tiles&.length > 0 || run
    alignment_sum = 0
    @tiles.each_with_index do |tile, index|
      x = index % @width
      y = (index - x) / @width
      #puts if x == 0
      if is_junction(x, y)
        alignment = x * y
        alignment_sum += alignment
        puts "#{index}: (#{x},#{y}) is an intersection. Alignment = #{alignment}, sum = #{alignment_sum}"
      end
      #break if y > 2
    end
    puts
  end

  def print_tiles
    #puts "At position #{@position} Move: #{@moves.length}"
    #width = @tiles.index("\n")
    puts @tiles.join('')
  end
end

require 'csv'
program = CSV.read('17-input.txt', converters: :numeric)[0]
program[0] = 2
session = Board.new
main_movement = "A,B,A,B,C,C,B,C,B,A\n"
a_movement = "R,12,L,8,R,12\n"
b_movement = "R,8,R,6,R,6,R,8\n"
c_movement = "R,8,L,8,R,8,R,4,R,4\n"
video_y_n = "n\n"
first_moves = main_movement + a_movement + b_movement + c_movement + video_y_n
session.run(program, first_moves.chars)
#session.print_tiles


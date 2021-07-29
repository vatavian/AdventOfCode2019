# Advent of Code 2019 Day 11 Part One https://adventofcode.com/2019/day/11
# Space Police: Intcode-driven painting robot
# Provide Intcode input indicating current paint color of panel robot is on,
# Listen for two outputs:
# First a color the robot will paint (0=black, 1=white)
# Next a direction to turn (0=left 90 degrees, 1=right)
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

class RobotPainter
  attr_accessor :panel_color
  
  def initialize
    self.set_defaults
  end

  def set_defaults
    @pc = 0
    @relative_base = 0
    @program = []
    @debug = false
    @panel_color = Hash.new(0) # keys are coordinate pairs, values are most recently painted color, default value = 0 (black)
    @position = [0,0] # start at the origin
    @dirs = {up: [0,1], left: [-1,0], down: [0,-1], right: [1,0]} # each is the [dx, dy] to go in that direction
    @direction = @dirs[:up]
    @left_turns = {@dirs[:up] => @dirs[:left], @dirs[:left] => @dirs[:down], @dirs[:down] => @dirs[:right], @dirs[:right] => @dirs[:up]}
    @right_turns = @left_turns.invert
    @turns = [@left_turns, @right_turns] # turn left on zero, right on one
    @ready_to_move = false
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

  def run(program)
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
        @program[save_address] = @panel_color[@position]
        @pc += 2
      when 4 # outputs the value of its only parameter
        p1 = param_val(param_modes, 1)
        if @ready_to_move
          @direction = @turns[p1][@direction] # p1 chooses a left turn (0) or right turn (1)
          # Move once in the new direction
          @position[0] += @direction[0]
          @position[1] += @direction[1]
        else # ready to paint
          @panel_color[[@position[0], @position[1]]] = p1
        end
        @ready_to_move = !@ready_to_move
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
        return @program
      else
        p 'Error: found opcode ' + @program[@pc].to_s + ' at ' + @pc.to_s
        return @program
      end
    end
  end
end

#[[104,1125899906842624,99],[1102,34915192,34915192,7,4,7,99,0],[109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]].each do |program|
#  p program.to_s
#  IntcodeMachine.new.run(program).to_s
#end

require 'csv'
program = CSV.read('11-input.txt', converters: :numeric)[0]
robot = RobotPainter.new
robot.run(program)
p "Painted #{robot.panel_color.length} panels at least once."

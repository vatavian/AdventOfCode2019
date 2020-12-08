# Advent of Code 2019 Day 7 part 2 https://adventofcode.com/2019/day/7#part2
# Chain the amplifiers in loop mode, output of the last one feeding into input of the first
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

class Machine
  attr_accessor :program
  attr_accessor :pc
  attr_accessor :halted

  def initialize(program)
    @program = program
    @pc = 0
    @halted = false
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
      # p 'param[' + param_index.to_s + '] = ' + param_int.to_s + ' mode ' + mode.to_s + ' -> ' + @program[param_int].to_s
      return @program[param_int]
    when 1
      # p 'param[' + param_index.to_s + '] = ' + param_int.to_s + ' mode ' + mode.to_s
      return param_int
    else
      p 'Error: found param mode ' + mode.to_s + ' at instruction index ' + @pc.to_s + ' parameter ' + param_index.to_s
    end
  end

  def run(inputs, pause_on_output)
    if @halted
      p 'Tried to run after halting'
      return nil 
    end
    input_index = 0
    output = nil
    loop do
      instruction = @program[@pc]
      modesint, opcode = instruction.divmod 100
      param_modes = modesint.split_digits.reverse
      # p 'pc ' + @pc.to_s + ' instruction ' + instruction.to_s +
      #   ' modesint ' + modesint.to_s + ' modes ' + param_modes.to_s + ' opcode ' + opcode.to_s

      case opcode
      when 1
        @program[@program[@pc+3]] = param_val(param_modes, 1) + param_val(param_modes, 2)
        @pc += 4
      when 2
        @program[@program[@pc+3]] = param_val(param_modes, 1) * param_val(param_modes, 2)
        @pc += 4
      when 3 # takes a single integer as input and saves it to the position given by its only parameter
        save_address = @program[@pc+1]
        if inputs && input_index < inputs.length
          input = inputs[input_index]
          input_index += 1
        else
          p 'Input an integer: '
          input = gets.chomp.to_i
        end
        @program[save_address] = input
        # p 'input -> [' + save_address.to_s + '] = ' + @program[save_address].to_s
        @pc += 2
      when 4 # outputs the value of its only parameter
        output = param_val(param_modes, 1)
        p 'output --------------------------> ' + output.to_s
        @pc += 2
        return output if pause_on_output
      when 5 # jump-if-true
        if param_val(param_modes, 1) != 0
          @pc = param_val(param_modes, 2) 
        else
          @pc += 3
        end
      when 6 # jump-if-false
        if param_val(param_modes, 1) == 0
          @pc = param_val(param_modes, 2)
        else
          @pc += 3
        end
      when 7 # less than
        @program[@program[@pc+3]] = param_val(param_modes, 1) < param_val(param_modes, 2) ? 1 : 0
        @pc += 4
      when 8 # equals
        @program[@program[@pc+3]] = param_val(param_modes, 1) == param_val(param_modes, 2) ? 1 : 0
        @pc += 4
      when 99
        @halted = true
        return output
      else
        p 'Error: found opcode ' + @program[@pc].to_s + ' at ' + @pc.to_s
        return nil
      end
    end
  end
end

require 'csv'

max_output = 0

[5,6,7,8,9].permutation.each do |phases|
  p phases.to_s
  output = 0
  machines = [Machine.new(CSV.read('7-input.txt', converters: :numeric)[0])]
  machines[1] = Machine.new(machines[0].program.dup)
  machines[2] = Machine.new(machines[0].program.dup)
  machines[3] = Machine.new(machines[0].program.dup)
  machines[4] = Machine.new(machines[0].program.dup)

  # Init each machine with its phase and first input
  phases.each_with_index do |phase, index|
    output = machines[index].run([phase, output], true)
  end

  while !machines[0].halted
    machines.each {|machine| output = machine.run([output], true) }
    if output && (output > max_output)
      p "Increas max output from #{max_output} to #{output}"
      max_output = output 
    end
  end
end

p max_output
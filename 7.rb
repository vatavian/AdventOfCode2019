# Advent of Code 2019 Day 7 part 1 https://adventofcode.com/2019/day/7

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

def param_val(program, pc, param_modes, param_index)
  if param_index <= param_modes.length
    mode = param_modes[param_index-1]
  else
    mode = 0
  end
  param_int = program[pc+param_index]
  case mode
  when 0
    # p 'param[' + param_index.to_s + '] = ' + param_int.to_s + ' mode ' + mode.to_s + ' -> ' + program[param_int].to_s
    return program[param_int]
  when 1
    # p 'param[' + param_index.to_s + '] = ' + param_int.to_s + ' mode ' + mode.to_s
    return param_int
  else
    p 'Error: found param mode ' + mode.to_s + ' at instruction index ' + pc.to_s + ' parameter ' + param_index.to_s
  end
end

def run_ip(program, inputs)
  pc = 0
  input_index = 0
  output = nil
  loop do
    instruction = program[pc]
    modesint, opcode = instruction.divmod 100
    param_modes = modesint.split_digits.reverse
    # p 'pc ' + pc.to_s + ' instruction ' + instruction.to_s + ' modesint ' + modesint.to_s + ' modes ' + param_modes.to_s + ' opcode ' + opcode.to_s
    
    case opcode
    when 1
      program[program[pc+3]] = param_val(program, pc, param_modes, 1) + param_val(program, pc, param_modes, 2)
      pc += 4
    when 2
      program[program[pc+3]] = param_val(program, pc, param_modes, 1) * param_val(program, pc, param_modes, 2)
      pc += 4
    when 3 # takes a single integer as input and saves it to the position given by its only parameter
      save_address = program[pc+1]
      if inputs && input_index < inputs.length
        input = inputs[input_index]
        input_index += 1
      else
        p 'Input an integer: '
        input = gets.chomp.to_i
      end
      program[save_address] = input
      p 'input -> [' + save_address.to_s + '] = ' + program[save_address].to_s
      pc += 2
    when 4 # outputs the value of its only parameter
      output = param_val(program, pc, param_modes, 1)
      p 'output --------------------------> ' + output.to_s
      pc += 2
    when 5 # jump-if-true
      if param_val(program, pc, param_modes, 1) != 0
        pc = param_val(program, pc, param_modes, 2) 
      else
        pc += 3
      end
    when 6 # jump-if-false
      if param_val(program, pc, param_modes, 1) == 0
        pc = param_val(program, pc, param_modes, 2)
      else
        pc += 3
      end
    when 7 # less than
      program[program[pc+3]] = param_val(program, pc, param_modes, 1) < param_val(program, pc, param_modes, 2) ? 1 : 0
      pc += 4
    when 8 # equals
      program[program[pc+3]] = param_val(program, pc, param_modes, 1) == param_val(program, pc, param_modes, 2) ? 1 : 0
      pc += 4
    when 99
      return output
    else
      p 'Error: found opcode ' + program[pc].to_s + ' at ' + pc.to_s
      return nil
    end
  end
end

require 'csv'

max_output = 0

[0,1,2,3,4].permutation.each do |phases|
  p phases.to_s
  output = 0
  phases.each do |phase|
    program = CSV.read('7-input.txt', converters: :numeric)[0]
    output = run_ip(program, [phase, output])
  end
  max_output = output if output > max_output
end

p max_output
# Advent of Code 2019 Day 5 https://adventofcode.com/2019/day/5

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
  p 'param[' + param_index.to_s + '] = ' + param_int.to_s + ' mode ' + mode.to_s
  case mode
  when 0
    return program[param_int]
  when 1
    return param_int
  else
    p 'Error: found param mode ' + mode.to_s + ' at instruction index ' + pc.to_s + ' parameter ' + param_index.to_s
  end
end

def run_ip(program)
  pc = 0
  loop do
    instruction = program[pc]
    modesint, opcode = instruction.divmod 100
    param_modes = modesint.split_digits.reverse
    p 'pc ' + pc.to_s + ' instruction ' + instruction.to_s + ' modesint ' + modesint.to_s + ' modes ' + param_modes.to_s + ' opcode ' + opcode.to_s
    
    case opcode
    when 1
      program[program[pc+3]] = param_val(program, pc, param_modes, 1) + param_val(program, pc, param_modes, 2)
      pc += 4
    when 2
      program[program[pc+3]] = param_val(program, pc, param_modes, 1) * param_val(program, pc, param_modes, 2)
      pc += 4
    when 3 # takes a single integer as input and saves it to the position given by its only parameter
      p 'Input an integer: '
      save_address = program[pc+1]
      program[save_address] = gets.chomp.to_i
      p 'input -> [' + save_address.to_s + '] = ' + program[save_address].to_s
      pc += 2
    when 4 # outputs the value of its only parameter
      p 'output --------------------------> ' + param_val(program, pc, param_modes, 1).to_s
      pc += 2
    when 99
      return program
    else
      p 'Error: found opcode ' + program[pc].to_s + ' at ' + pc.to_s
      return program
    end
  end
end

#[[1,9,10,3,2,3,11,0,99,30,40,50], [1,0,0,0,99], [2,3,0,3,99], [2,4,4,5,99,0], [1,1,1,4,99,5,6,0,99]].each do |program|
#  p program.to_s
#  run_ip(program).to_s
#  p ' -> ' + program.to_s
#end
#(1..12).each do |mass|
#  p mass.to_s + ' needs ' + calc_fuel_needed(mass).to_s + ' fuel'
#end

require 'csv'

program = CSV.read('5-input.txt', converters: :numeric)[0]
run_ip(program)

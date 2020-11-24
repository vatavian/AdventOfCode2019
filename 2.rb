# Advent of Code 2019 Day 2

def run_ip(program)
  pc = 0
  loop do
    case program[pc]
    when 1
      program[program[pc+3]] = program[program[pc+1]] + program[program[pc+2]]
    when 2
      program[program[pc+3]] = program[program[pc+1]] * program[program[pc+2]]
    when 99
      return program
    else
      p 'Error: found opcode ' + program[pc].to_s + ' at ' + pc.to_s
      return program
    end
     pc += 4
  end
end

[[1,9,10,3,2,3,11,0,99,30,40,50], [1,0,0,0,99], [2,3,0,3,99], [2,4,4,5,99,0], [1,1,1,4,99,5,6,0,99]].each do |program|
  p program.to_s + ' -> ' + run_ip(program).to_s
end
#(1..12).each do |mass|
#  p mass.to_s + ' needs ' + calc_fuel_needed(mass).to_s + ' fuel'
#end

require 'csv'
program = CSV.read('2-input.txt', converters: :numeric)[0]
p "Initial program: " + program.to_s
program[1] = 12
program[2] = 2
p "After running: " + run_ip(program).to_s
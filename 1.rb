# Advent of Code 2019 Day 1

def calc_fuel_needed(mass)
  (mass / 3).floor - 2
end

[12, 14, 1969, 100756].each do |mass|
  p mass.to_s + ' needs ' + calc_fuel_needed(mass).to_s + ' fuel'
end

num_modules = 0
total_fuel_needed = 0
File.open('1-input.txt') do |infile|
  while line = infile.gets
    total_fuel_needed += calc_fuel_needed(line.chomp.to_i)
    num_modules += 1
  end
end

p 'Total fuel needed for ' + num_modules.to_s + ' modules is ' + total_fuel_needed.to_s
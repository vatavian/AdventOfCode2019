# Advent of Code 2019 Day 6 https://adventofcode.com/2019/day/6

def count_orbits(body, orbits)
  body ? 1 + count_orbits(orbits[body], orbits) : 0
end

orbits = Hash.new
orbits.default = false

File.open('6-input.txt') do |infile|
  while line = infile.gets&.chomp
    orbitee, orbiter = line.split(')')
    orbits[orbiter] = orbitee
    # p orbiter + ' orbits ' + orbitee
  end
end
#total_orbits = Hash.new
num_orbits = 0
orbits.each do | orbiter, orbitee |
  num_orbits += count_orbits(orbitee, orbits)
end

p 'Total orbits = ' + num_orbits.to_s
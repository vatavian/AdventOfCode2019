# Advent of Code 2019 Day 6 Part Two https://adventofcode.com/2019/day/6#part2

def count_orbits(body, orbits)
  body ? 1 + count_orbits(orbits[body], orbits) : 0
end

def set_distances_down_from(orbits, distances, from_node, from_node_distance)
  distances[from_node] = from_node_distance
  next_orbit = orbits[from_node]
  if next_orbit
    set_distances_down_from(orbits, distances, next_orbit, from_node_distance + 1)
  end
end

orbits = Hash.new
orbits.default = false

you_start = nil
san_start = nil
File.open('6-input.txt') do |infile|
  while line = infile.gets&.chomp
    orbitee, orbiter = line.split(')')
    case orbiter
    when 'YOU'
      you_start = orbitee
    when 'SAN'
      san_start = orbitee
    else
      orbits[orbiter] = orbitee
    end
    # p orbiter + ' orbits ' + orbitee
  end
end
if !you_start
  p "YOU starting position not found"
elsif !san_start
  p "SAN starting position not found"
else
  num_orbits = 0
  distance_down_from_you = Hash.new
  set_distances_down_from(orbits, distance_down_from_you, you_start, 0)
  # p 'Distances down from YOU: ' + distance_down_from_you.to_s

  distance_down_from_san = Hash.new
  set_distances_down_from(orbits, distance_down_from_san, san_start, 0)
  # p 'Distances down from SAN: ' + distance_down_from_san.to_s

  distance_down_from_you.each do | body, distance |
    if ds = distance_down_from_san[body]
      p 'node ' + body + ' is ' + distance.to_s + ' from YOU + ' + ds.to_s + ' from SAN = ' + (distance + ds).to_s
      break
    end
  end
end

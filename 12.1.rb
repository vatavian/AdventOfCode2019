# Advent of Code 2019 Day 12 Part One https://adventofcode.com/2019/day/12
# The N-Body Problem
# What is the total energy in the system after simulating the moons given in your scan for 1000 steps?

Axes = [0, 1, 2] # X, Y, Z

class Body
  attr_accessor :position, :velocity
  def initialize(input_text)
    @position = [input_text[0].split('=')[1].to_i,
                 input_text[1].split('=')[1].to_i,
                 input_text[2].split('=')[1].chomp('>').to_i]
    @velocity = [0, 0, 0]
  end

  def potential_energy
    energy = 0
    Axes.each do |axis|
      energy += self.position[axis].abs
    end
    energy
  end

  def kinetic_energy
    energy = 0
    Axes.each do |axis|
      energy += self.velocity[axis].abs
    end
    energy
  end

  def total_energy
    potential_energy * kinetic_energy
  end
  
  def dump
    print "Position: #{@position[0].to_s.rjust(3)}, #{@position[1].to_s.rjust(3)}, #{@position[2].to_s.rjust(3)}, \t"
    puts "Velocity: #{@velocity[0].to_s.rjust(3)}, #{@velocity[1].to_s.rjust(3)}, #{@velocity[2].to_s.rjust(3)}"
  end
end

class NBodies
  attr_accessor :bodies
  attr_reader :time_step
  def initialize(csv_reader)
    @bodies = csv_reader.map{|line| Body.new(line)}
    @time_step = 0
  end

  def next_step
    apply_gravity
    apply_velocity
    @time_step += 1
  end
    
  def apply_gravity
    @bodies.combination(2).each do |b1, b2|
      Axes.each do |axis|
        if b1.position[axis] > b2.position[axis]
          b1.velocity[axis] -= 1
          b2.velocity[axis] += 1
        elsif b2.position[axis] > b1.position[axis]
          b1.velocity[axis] += 1
          b2.velocity[axis] -= 1
        end
      end
    end
  end

  def apply_velocity
    @bodies.each do |body|
      Axes.each do |axis|
        body.position[axis] += body.velocity[axis]
      end
    end
  end

  def total_energy
    @bodies.reduce(0) { |sum, body| sum + body.total_energy }
  end

  def dump
    puts "At time step #{@time_step}:"
    @bodies.each { |moon| moon.dump }
  end
end

require 'csv'
system = NBodies.new(CSV.read('12-input.txt'))
1000.times { system.next_step }
#system.dump
puts "System Total Energy after step #{system.time_step}: #{system.total_energy}"

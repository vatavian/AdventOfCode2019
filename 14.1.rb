# Advent of Code 2019 Day 14 Part One https://adventofcode.com/2019/day/14
# Space Stoichiometry
# Equations for producing fuel from ore and intermediate chemicals

class Ingredient
  attr_accessor :num
  attr_accessor :chem

  def initialize(str)
    numstr, @chem = str.split(' ')
    @num = numstr.to_i
  end

  def to_s
    "#{@num} #{@chem} "
  end
end

class Equation
  attr_accessor :inputs
  attr_accessor :output
  def initialize(str)
    inputstr, outputstr = str.split(' => ')
    @output = Ingredient.new(outputstr)
    @inputs = inputstr.split(', ').map{ |str| Ingredient.new(str) }
  end

  def to_s
    @inputs.reduce('') { |sum, input| sum += input.to_s } + "=> #{output.to_s}"
  end
end

class Reactions
  attr_accessor :eqns

  def initialize(filename)
    @eqns = Hash.new
    @have_leftover = Hash.new(0)
    File.open(filename) do |infile|
      while line = infile.gets&.chomp
        eqn = Equation.new(line)
        eqns[eqn.output.chem] = eqn
      end
    end
  end

  # How many times we need to run a reaction that produces num_per to get num_needed
  def reaction_times(num_needed, num_per)
    (num_needed + num_per - 1) / num_per
  end

  def compute_cost(num_needed, chem)
    if chem == 'ORE'
      return num_needed
    elsif num_needed < 1
      p "Did not need any #{chem} (num_needed = #{num_needed})"
      return 0
    else
      output_eqn = @eqns[chem]
      have_chem = @have_leftover[chem]
      if have_chem > 0
        if have_chem >= num_needed
          @have_leftover[chem] -= num_needed
          p "Already had at least #{num_needed} #{chem}, no need to make more. Now have #{@have_leftover[chem]} remaining."
          return 0
        else
          num_needed -= have_chem
          p "Using #{have_chem} leftover #{chem}, still need to make #{num_needed}"
          @have_leftover[chem] = 0
        end
      end
      times_needed = self.reaction_times(num_needed, output_eqn.output.num)
      p "To get #{num_needed} #{chem}, need to run reaction #{times_needed} times: #{output_eqn}"
      cost = output_eqn.inputs.reduce(0) { |sum, i| sum += self.compute_cost(i.num * times_needed, i.chem)}
      @have_leftover[chem] += times_needed * output_eqn.output.num - num_needed
      p "Total cost for #{num_needed} #{chem} = #{cost} ORE, leaving #{@have_leftover[chem]} #{chem} unused"
      return cost
    end
  end
end

all_eqns = Reactions.new('14-input.txt')
#eqns.each_value { |eqn| puts eqn.to_s }
p all_eqns.compute_cost(1, 'FUEL')


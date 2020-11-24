# Advent of Code 2019 Day 4 https://adventofcode.com/2019/day/4

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

num_possible = 0
for pw in 284639..748759
  digits = pw.split_digits
  if digits[0] <= digits[1] &&
     digits[1] <= digits[2] &&
     digits[2] <= digits[3] &&
     digits[3] <= digits[4] &&
     digits[4] <= digits[5]
     num_possible += 1 if digits[0] == digits[1] || digits[1] == digits[2] || digits[2] == digits[3] || digits[3] == digits[4] || digits[4] == digits[5]
  end
end
p num_possible.to_s

require 'byebug'
class SevenSegmentSearch
  def self.part_one
    count = 0
    data.each do |d, acc|
      commands = d.split("|").last.split(" ")
      commands.each do |c|
        count += 1 if [2, 4, 3, 7].include?(c.length)
      end
    end
    count
  end

  def self.part_two(slow = true)
    total = 0
    total += if slow
      SlowRandomPermutationTester.new(data)
    else
      subtotal = 0
      data.each do |d|
        inputs = d.split(" | ").first
        outputs = d.split(" | ").last
        deducer = Deducer.new(inputs)
        subtotal += deducer.calculate_output(outputs).to_i
      end
      subtotal
    end
    total
  end

  class SlowRandomPermutationTester
    def initialize(data)
      total = 0
      digits = {
        "0" => "abcefg",
        "1" => "cf",
        "2" => "acdeg",
        "3" => "acdfg",
        "4" => "bcdf",
        "5" => "abdfg",
        "6" => "abdefg",
        "7" => "acf",
        "8" => "abcdefg",
        "9" => "abcdfg"
      }
      data.each do |d|
        inputs = d.split(" | ").first.split
        outputs = d.split(" | ").last.split
  
        (0..8).to_a.permutation.each do |perm|
          dict = {}
          (0..8).each do |i|
            dict[("a".ord+i).chr] = (("a".ord)+perm[i]).chr
          end
          do_break = false
          inputs.each do |input|
            str = ""
            input.chars.each do |char|
              str += dict[char]
            end
            unless digits.values.include?(str.chars.sort.join)
              do_break = true
              break
            end
          end
          next if do_break
          
          ret = ""
          outputs.each do |output|
            str = ""
            output.chars.each do |c|
              str += dict[c]
            end
            ret << digits.key(str.chars.sort.join)
            puts ret if ret.size == 4
            do_break = true
          end
          total += ret.to_i
          break if do_break
        end
      end
      total
    end
  end

  class Deducer
    attr_accessor :dict
    def initialize(data) 

      digits = {
        "0" => "abcefg", # 6
        "1" => "cf",     # 2
        "2" => "acdeg",  # 5
        "3" => "acdfg",  # 5
        "4" => "bcdf",   # 4
        "5" => "abdfg",  # 5
        "6" => "abdefg", # 6
        "7" => "acf",    # 3
        "8" => "abcdefg",# 7
        "9" => "abcdfg"  # 6
      }

      # CF from 1 (no order)
      # A from 7
      # BD from 4 (no order)
      # 6 is missing one of CF. F is present; C is missing
      # Finished A, C, F. Know BD but not order. E, G are unused letters
      # 0 is length 6 and missing one of b/d. B is present; D is missing
      # 9 is length 6 and missing one of e/g. G is present; E is missing
      @dict = {}
      cf = ""
      data = data.split

      data.each { |w| cf = w if w.size == 2 } # 1

      data.each do |w| # 6
        if w.size == 6 && (!w.include?(cf[0]) || !w.include?(cf[1])) # 9 and 0 both have C and F, 6 only has one
          # it's a six
          if w.include? cf[0]
            dict[cf[0]] = 'f'
            dict[cf[1]] = 'c'
          else
            dict[cf[1]] = 'f'
            dict[cf[0]] = 'c'
          end
        end
      end

      data.each do |w|
        if w.size == 3 # a seven
          w.chars.each do |char|
            if !cf.include?(char)
              dict[char] = 'a'
            end
          end
        end
      end


      bd = ""
      data.each do |w|
        if w.size == 4 # a four
          w.chars.each do |char|
            unless cf.include?(char)
              bd << char # can't get the order
            end
          end
        end
      end

      data.each do |w| # get 0
        if w.size == 6 && (!w.include?(bd[0]) || !w.include?(bd[1])) # 9 has both B and D, 0 only has one
          if w.include? bd[0]
            dict[bd[0]] = 'b'
            dict[bd[1]] = 'd'
          else
            dict[bd[1]] = 'b'
            dict[bd[0]] = 'd'
          end
        end
      end

      eg = ""
      ("a".."g").to_a.each do |letter|
        eg += letter unless dict[letter]
      end

      data.each do |w| # get 9
        if w.size == 6 && (!w.include?(eg[0]) || !w.include?(eg[1])) # 9 is missing e
          if w.include? eg[0]
            dict[eg[0]] = 'g'
            dict[eg[1]] = 'e'
          else
            dict[eg[1]] = 'g'
            dict[eg[0]] = 'e'
          end
        end
      end
    end      

    def calculate_output(outputs)
      digits = {
        "0" => "abcefg",
        "1" => "cf",
        "2" => "acdeg",
        "3" => "acdfg",
        "4" => "bcdf",
        "5" => "abdfg",
        "6" => "abdefg",
        "7" => "acf",
        "8" => "abcdefg",
        "9" => "abcdfg"
      }
      num = ""
      outputs.split.each do |word|
        num << digits.key(word.chars.map {|char| dict[char] }.sort.join)
      end
      num
    end
  end

  def self.data
    @data ||= File.open("./spec/#{__FILE__.match(/day_\d+/)}.txt", "r+").readlines
  end
end

RSpec.describe SevenSegmentSearch do
  it "solves" do
    expect(SevenSegmentSearch.part_one).to eq 342
    expect(SevenSegmentSearch.part_two(false)).to eq 1068933
  end
end

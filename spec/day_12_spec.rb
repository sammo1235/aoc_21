require 'byebug'
require 'set'
class PassagePathing
  def self.part_one(p2 = false)
    GraphTraversal.new(data).answer
  end

  class GraphTraversal
    attr_reader :dict, :answer
    def initialize(data, p2 = false)
      @dict = Hash.new {|k, v| k[v] = [] }
      @answer = 0
      data.each do |line|
        a, b = line.split("-")
        dict[b].push(a)
        dict[a].push(b)
      end
      
      if p2
        queue = ["start", ["start"], nil]
      else
        queue = ["start", ["start"]]
      end
      while queue.any?
        if p2
          pos, small, twice = queue.shift(3)
        else
          pos, small = queue.shift(2)
        end

        if pos == "end"
          @answer += 1
          next
        end
        dict[pos].each do |poss|
          if !small.include? poss
            new_small = Set.new(small)
            if poss.downcase == poss
              new_small.add(poss)
            end
            queue << poss
            queue << new_small
            queue << twice if p2
          elsif p2 && small.include?(poss) && twice.nil? && !["start", "end"].include?(poss)
            queue << poss
            queue << small
            queue << poss
          end
        end
      end
      return @answer
    end
  end

  def self.part_two
    GraphTraversal.new(data, true).answer
  end

  def self.data()
    @data ||= File.open("./spec/#{__FILE__.match(/day_\d+/)}.txt", "r+").readlines.map(&:chomp)
  end
end

RSpec.describe PassagePathing do
  it "solves" do
    expect(PassagePathing.part_one).to eq 3485
    expect(PassagePathing.part_two).to eq 85062
  end
end

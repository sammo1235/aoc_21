require 'byebug'
module Whales
  def self.part_one
    find_min_fuel
  end

  def self.part_two
    find_min_fuel(true)
  end

  def self.find_min_fuel(p2 = false)
    (data.min..data.max).reduce({}) do |acc, idx|
      fuel = []
      data.each do |crab|
        if crab > idx
          if p2
            fuel << (0..(crab - idx)).sum
          else
            fuel << crab - idx
          end
        elsif crab < idx
          if p2
            fuel << (0..(idx - crab)).sum
          else
            fuel << idx - crab
          end
        else
          fuel << 0
        end
      end
      acc[idx] = fuel.sum
      acc
    end.sort_by {|k, v| v}.first[1]
  end

  def self.run_days(number, fish)
  end

  def self.data
    @data ||= File.open("./spec/#{__FILE__.match(/day_\d+/)}.txt", "r+").readline.split(",").map(&:to_i)
  end
end

RSpec.describe Whales do
  it "solves" do
    expect(Whales.part_one).to eq 337833
    expect(Whales.part_two).to eq 96678050
  end
end
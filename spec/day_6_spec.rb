require 'byebug'
module LanternFish
  def self.part_one
    run_days(80, data.tally).values.sum
  end

  def self.part_two
    run_days(256, data.tally).values.sum
  end

  def self.run_days(number, fish)
    number.times do |idx|
      hash = Hash.new(0)
      fish.each do |k, val|
        if k == 0
          hash[8] = val
          hash[6] += val
        else
          hash[k-1] += val
        end
      end

      fish = hash
      fish
    end
    fish
  end

  def self.data
    @data ||= File.open("./spec/#{__FILE__.match(/day_\d+/)}.txt", "r+").readline.split(",").map(&:to_i)
  end
end

RSpec.describe LanternFish do
  it "solves" do
    expect(LanternFish.part_one).to eq 355386
    expect(LanternFish.part_two).to eq 1613415325809
  end
end
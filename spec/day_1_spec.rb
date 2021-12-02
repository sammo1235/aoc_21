module Depth
  def self.part_one
    (1..data.length-1).inject(0) {|acc, idx| acc += 1 if data[idx-1] < data[idx]; acc}
  end

  def self.part_two
    (1..data.length-1).inject(0) {|acc, idx| acc += 1 if data[idx-1..idx+1].sum < data[idx..idx+2].sum; acc}
  end

  def self.data
    @data ||= File.open("./spec/#{__FILE__.match(/day_[1-25]/)}.txt", "r").readlines.map(&:chomp).map(&:to_i)
  end
end

RSpec.describe Depth do
  it "solves" do
    expect(Depth.part_one).to eq 1342
    expect(Depth.part_two).to eq 1378
  end
end
module Navigate
  def self.part_one
    x = y = 0
    data.each { |d| dir = d.split.first; qu = d.split.last.to_i; dir == "forward" ? x += qu : dir == "down" ? y += qu : dir == "up" ? y -= qu : nil }
    x*y
  end

  def self.part_two
    x = y = a = 0
    data.each {|d| dir = d.split.first; qu = d.split.last.to_i; dir == "forward" ? (x += qu; y += a * qu) : dir == "down" ? a += qu : dir == "up" ? a -= qu : nil }
    x*y
  end

  def self.data
    @data ||= File.open("./spec/#{__FILE__.match(/day_[1-25]/)}.txt", "r").readlines.map(&:chomp)
  end
end

RSpec.describe Navigate do
  it "solves" do
    expect(Navigate.part_one).to eq 2039256
    expect(Navigate.part_two).to eq 1856459736
  end
end
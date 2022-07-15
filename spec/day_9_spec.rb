require 'byebug'
class SmokeBasin
  def self.part_one
    lowpoints = []
    data.each_with_index do |l, yidx|
      (0..l.length-1).each do |xidx|
        left = l[xidx-1] if xidx > 0
        right = l[xidx+1] if xidx < l.length-1
        down = data[yidx+1][xidx] if yidx < data.length-1
        up = data[yidx-1][xidx] if yidx > 0
        lowpoints << (l[xidx] + 1) if [*(left), *(right), *(down), *(up)].all? {|n| n > l[xidx]}
      end
    end
    lowpoints.sum
  end

  @coords = []
  class << self
    attr_accessor :coords
  end

  def self.part_two
    basins = {}
    basin = 1
    data.each_with_index do |l, yidx|
      (0..l.length-1).each do |xidx|
        left = l[xidx-1] if xidx > 0
        right = l[xidx+1] if xidx < l.length-1
        down = data[yidx+1][xidx] if yidx < data.length-1
        up = data[yidx-1][xidx] if yidx > 0
        if [*(left), *(right), *(down), *(up)].all? {|n| n > l[xidx]}
          basins[basin] = DiscernBasinCoords.new(data, yidx, xidx).get_total_all_coords
          basin += 1
        end
      end
    end
    basins.values.sort.reverse[0..2].inject(:*)
  end

  class DiscernBasinCoords
    attr_reader :data, :coords
    def initialize(data, starting_yidx, starting_xidx)
      @data = data
      @coords = []
      find_neighbors(starting_yidx, starting_xidx)
    end

    def get_total_all_coords
      coords.count
    end

    def find_neighbors(yidx, xidx) # dir = don't check behind you
      return if data[yidx][xidx] == 9 || coords.include?([yidx, xidx])
      coords << [yidx, xidx]
      find_neighbors(yidx-1, xidx) if yidx > 0 && data[yidx-1][xidx] < 9
      find_neighbors(yidx+1, xidx) if yidx < data.length-1 && data[yidx+1][xidx] < 9
      find_neighbors(yidx, xidx-1) if xidx > 0 && data[yidx][xidx-1] < 9
      find_neighbors(yidx, xidx+1) if xidx < data[0].length-1 && data[yidx][xidx+1] < 9
    end
  end

  def self.data
    @data ||= File.open("./spec/#{__FILE__.match(/day_\d+/)}.txt", "r+").readlines.map(&:chomp).map {|l| l.chars.map(&:to_i) }
  end
end

RSpec.describe SmokeBasin do
  it "solves" do
    expect(SmokeBasin.part_one).to eq 491
    expect(SmokeBasin.part_two).to eq 1075536
  end
end

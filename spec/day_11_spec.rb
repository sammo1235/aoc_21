require 'byebug'
class DumboOctopus
  def self.part_one(p2 = false)
    round = 0
    flash_count = 0
    data = self.data
    round_limit = p2 ? 800 : 100
    all_flash_round = 0
    do_break = false
    while round < round_limit
      data = data.map {|line| line.map {|c| c += 1 } }
      found_nine = false
      first_miniround = true
      flashed = []
      miniround = 1
      while data.flatten.select{|c| c > 9 }.any? || first_miniround

        first_miniround = false
        (0..data.length-1).each do |yidx|
          (0..data[0].length-1).each do |xidx|
            if data[yidx][xidx] > 9
              flash_count += 1
              inc_surr(data, yidx, xidx)
              found_nine = true
              data[yidx][xidx] = 0
            end
          end
          
        end
        if p2 && data.flatten.select {|d| d==0}.length == data.length*data[0].length
          all_flash_round = round+1
          do_break = true
          break
        end
        break if do_break
        miniround += 1 
      end
      break if do_break
      flash_count += flashed.size
      round += 1
    end

    p2 ? all_flash_round : flash_count
  end

  def self.inc_surr(data, yidx, xidx)
    ((yidx == 0 ? 0 : (yidx - 1))..(yidx == data.length-1 ? (data.length-1) : (yidx + 1))).each do |y|
      ((xidx == 0 ? 0 : (xidx -1))..(xidx == data[0].length-1 ? data[0].length-1 : (xidx +1))).each do |x|
        data[y][x]  = data[y][x] + 1 unless data[y][x] == 0
      end
    end
  end

  def self.part_two
    part_one(true)
  end

  def self.data
    @data ||= File.open("./spec/#{__FILE__.match(/day_\d+/)}.txt", "r+").readlines.map(&:chomp).map {|l| l.chars.map(&:to_i) }
  end
end

RSpec.describe DumboOctopus do
  it "solves" do
    expect(DumboOctopus.part_one).to eq 1683
    expect(DumboOctopus.part_two).to eq 788
  end
end

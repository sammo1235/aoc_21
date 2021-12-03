require 'byebug'
module BinaryDiagnostic
  def self.part_one
    res = data.map {|b| b.split("") }.transpose.reduce(["", ""]) do |acc, bits|
      t = bits.tally.sort_by {|k, v| v}
      acc[0] << t.last[0]
      acc[1] << t.first[0]
      acc
    end
    res[0].to_i(2) * res[1].to_i(2)
  end

  def self.part_two
    oxy = calculate(data, "last", "1")
    co2 = calculate(data, "first", "0")
    oxy.to_i(2) * co2.to_i(2)
  end

  def self.calculate(dat, method, precidence)
    until dat.size == 1 do
      (0..dat.size-1).each do |idx|
        t = dat.map {|b| b.split("")}.transpose[idx].tally.sort_by {|k, v| v}
        if t.last[1] == t.first[1]
          dat = dat.select {|b| b[idx] == precidence}
        else
          dat = dat.select {|b| b[idx] == t.send(method).first }
        end
        break if dat.size == 1
      end
    end
    dat[0]
  end

  def self.data
    @data ||= File.open("./spec/#{__FILE__.match(/day_\d+/)}.txt", "r+").readlines.map(&:chomp)
  end
end

RSpec.describe BinaryDiagnostic do
  it "solves" do
    expect(BinaryDiagnostic.part_one).to eq 775304
    expect(BinaryDiagnostic.part_two).to eq 1370737
  end
end
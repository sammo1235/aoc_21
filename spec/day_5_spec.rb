require 'byebug'
module Hydrothermal
  def self.part_one
    coords = data.map {|v| v.split(" -> ")
      .map {|coords| coords.split(",").map(&:to_i)} }
      .select {|line| line[0][0] == line[1][0] || line[0][1] == line[1][1] }

    coords.map do |line|
      # if vertical line
      if line[0][0] == line[1][0] 
        line.sort!
        x = line[0][0]
        ys = line[0][1]
        (line[1][1] - ys - 1).times do 
          line << [x, ys + 1]
          ys += 1
        end
      else
        line.sort!
        y = line[0][1]
        xs = line[0][0]
        (line[1][0] - xs - 1).times do
          line << [xs + 1, y]
          xs += 1
        end
      end
      line
    end.reduce([]) do |acc, line|
      line.each do |coord| acc << coord
      end
      acc
    end.tally.select {|k, v| v > 1 }.count
  end

  def self.part_two
    coords = data.map {|v| v.split(" -> ")
      .map {|coords| coords.split(",").map(&:to_i)} }

    coords.map do |line|
      # if vertical line
      if line[0][0] == line[1][0] 
        line.sort!
        x = line[0][0]
        ys = line[0][1]
        (line[1][1] - ys - 1).times do 
          line << [x, ys + 1]
          ys += 1
        end
      elsif line[0][1] == line[1][1]
        line.sort!
        y = line[0][1]
        xs = line[0][0]
        (line[1][0] - xs - 1).times do
          line << [xs + 1, y]
          xs += 1
        end
      else # diagonal
        line.sort!
        xs = line[0][0]
        ys = line[0][1]
        xe = line[1][0]
        ye = line[1][1]
        if ys > ye # going up
          (xe - xs - 1).times do
            line << [xs + 1, ys - 1]
            xs += 1
            ys -= 1
          end
        elsif ys < ye # going down
          (xe - xs - 1).times do
            line << [xs + 1, ys + 1]
            xs += 1
            ys += 1
          end
        end
      end
      line
    end.reduce([]) do |acc, line|
      line.each do |coord| acc << coord
      end
      acc
    end.tally.select {|k, v| v > 1 }.count
  end

  def self.data
    @data ||= File.open("./spec/#{__FILE__.match(/day_\d+/)}.txt", "r").readlines.map(&:chomp)
  end
end

RSpec.describe Hydrothermal do
  it "solves" do
    expect(Hydrothermal.part_one).to eq 5306
    expect(Hydrothermal.part_two).to eq 17787
  end
end
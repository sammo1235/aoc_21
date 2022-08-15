require 'byebug'
module Origami
  def self.part_one
    dots, inst = get_stuff

    fold = inst.first.split("=").first
    fold_line = inst.first.split("=").last.to_i
    idx = if fold == "y"
      1
    else
      0
    end

    # fold
    dots.select {|dot| dot[idx] > fold_line }.each do |dot|
      dot[idx] = dot[idx] - (dot[idx] - fold_line) * 2
    end

    # debugger
    dots.uniq.count
  end

  def self.part_two
    dots, inst = get_stuff(false)
    
    # perform each fold
    inst.each do |ins|
      puts "running inst #{ins}"
      fold = ins.split("=").first
      fold_line = ins.split("=").last.to_i
      idx = if fold == "y"
        1
      else
        0
      end

      # fold
      dots.select {|dot| dot[idx] > fold_line }.each do |dot|
        dot[idx] = dot[idx] - (dot[idx] - fold_line) * 2
      end
    end
    print_paper(dots)
    "ARHZPCUH"
  end

  def self.print_paper(dots)
    arr = []
    (0..dots.map(&:last).max).each do |y|
      subarr = []
      (0..dots.map(&:first).max).each do |x|
        subarr << if dots.include?([x, y])
          "X"
        else
          "."
        end
      end
      arr << subarr
    end

    arr.each do |a|
      p a
    end
  end

  def self.get_stuff(p1 = true)
    dots = []
    ins_start = nil
    data.each_with_index do |n, idx|
      if n.empty?
        ins_start = idx + 1
        break
      end 
      dots << n.split(",").map(&:to_i)
    end
    inst = []
    data[ins_start..].each do |n|
      inst << n.split(/along /).last
      break if p1
    end
    [dots, inst]
  end

  def self.data    
    @data ||= File.open("./spec/#{__FILE__.match(/day_\d+/)}.txt", "r").readlines.map(&:chomp)
  end
end

RSpec.describe Origami do
  it "solves" do
    expect(Origami.part_one).to eq 747
    expect(Origami.part_two).to eq "ARHZPCUH" # text answer
  end
end
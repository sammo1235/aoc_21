require 'byebug'

module Boards
  module Grabber
    def self.grab_boards(data)
      n=0
      boards= Hash.new {|k, v| k[v] = Array.new }
      data[1..].map {|l| l.split.map {|n| [n, false]}}.each do |l|
        if l == []
          n += 1
          next
        else
          boards[n] << l
        end
      end
      boards
    end
  end

  class << self
    Grabber.singleton_methods.each do |m|
      define_method m, Grabber.method(m).to_proc
    end
  end

  def self.winning_line_or_column(line, lines, idx)
    line.map {|num| num[1] }.uniq.all? || lines[:data].transpose[idx].map {|num| num[1] }.uniq.all?
  end
end

class Module
  def include_module_methods(mod)
    mod.singleton_methods.each do |m|
      (class << self; self; end).send :define_method, m, mod.method(m).to_proc
    end
  end
end

module Bingo
  include_module_methods Boards
  # same as this ^
  # class << self
  #   Boards.singleton_methods.each do |m|
  #     define_method m, Boards.method(m).to_proc
  #   end
  # end
  
  def self.part_one
    called = data[0].split(",")
    boards = {}
    grab_boards(data).each { |k, v| boards[k]={data: v, won: false}}
    bingo = false
    total = 0
    winning_no = 0
    called.each do |call|
      boards.each do |b, lines|
        lines[:data].each do |line|
          line.each_with_index do |num, idx|
            if num[0] == call
              num[1] = true
            end
            if winning_line_or_column(line, lines, idx)
              winning_no = call.to_i
              total = get_total(lines[:data])
              bingo = true
            end
            break if bingo
          end
          break if bingo
        end
        break if bingo
      end
      break if bingo
    end  
    total * winning_no
  end

  def self.part_two
    called = data[0].split(",")
    boards = {}
    Boards::Grabber.grab_boards.each { |k, v| boards[k]={data: v, won: false}}
    board_count = boards.keys.length
    total = 0
    winning_no = 0
    called.each do |call|
      boards.each do |b, lines|
        next if lines[:won]
        lines[:data].each do |line|
          line.each_with_index do |num, idx|
            if num[0] == call
              num[1] = true
            end
            if winning_line_or_column(line, lines, idx)
              lines[:won] = true
              if boards.map {|b, lines| lines[:won]}.uniq.all?
                winning_no = call.to_i
                total = get_total(lines[:data])
              end
            end
          end
        end
      end
    end  
    total * winning_no
  end

  def self.get_total(lines)
    lines.reduce(0) do |acc, line|
      acc += line.reduce(0) do |ac, num|
        ac += num[0].to_i unless num[1]
        ac
      end
      acc
    end
  end

  def self.data
    @data ||= File.open("./spec/#{__FILE__.match(/day_\d+/)}.txt", "r").readlines.map(&:chomp)
  end
end

RSpec.describe Bingo do
  it "solves" do
    expect(Bingo.part_one).to eq 38594
    # expect(Bingo.part_two).to eq 21184
  end
end
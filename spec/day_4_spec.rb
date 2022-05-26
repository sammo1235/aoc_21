require 'byebug'
module A
  BAR_A = 'Bar A!'
  module B
    BAR_B = 'Bar B!'
      class Foo
        p BAR_A
        p BAR_B
      end
  end
end

class A::B::Baz
  # p BAR_A these will not work
  # p BAR_B
end

module Boards
  def prepare_boards
    new_boards = {}
    boards.each { |k, v| new_boards[k]={data: v, won: false}}
    new_boards
  end

  module Grabber
    def default_boards
      Hash.new {|k, v| k[v] = Array.new }
    end

    class Boing
      attr_reader :data, :boards
      attr_accessor :no
      # despite being namespaced within both these modules, we need to include them
      include Grabber
      include Boards
      
      def initialize(data)
        @data = data
        @boards = default_boards
        @no = 0
        @boards = grab_boards
      end

      def grab_boards
        data[1..].map {|l| l.split.map {|n| [n, false]}}.each do |l|
          if l == []
            self.no += 1
            next
          else
            boards[no] << l
          end
        end
        boards
      end
    end
  end
  
  # class << self
  #   Grabber.singleton_methods.each do |m|
  #     define_method m, Grabber.method(m).to_proc
  #   end
  # end

  def self.winning_line_or_column(line, lines, idx)
    line.map {|num| num[1] }.uniq.all? || lines[:data].transpose[idx].map {|num| num[1] }.uniq.all?
  end
end

class Module
  # use this to share singleton methods across different modules
  def include_module_methods(mod)
    mod.singleton_methods.each do |m|
      (class << self; self; end).send :define_method, m, mod.method(m).to_proc
    end
  end
end

class CalledNumbers
  attr_reader :data
  def initialize(data)
    @data = data
  end

  module Access
    def access_numbers
      data[0].split(",")
    end
  end
end

class CalledBingoNumbers < CalledNumbers
  include Access

  def initialize(data)
    super
  end

  def get_numbers
    access_numbers
  end
end

module Totalizer
  def self.get_total(lines)
    lines.reduce(0) do |acc, line|
      acc += line.reduce(0) do |ac, num|
        ac += num[0].to_i unless num[1]
        ac
      end
      acc
    end
  end
end

module Bingo
  module Solver
    # here we are converting singleton methods in a module to instance methods in a class
    [Boards, Totalizer].each do |mod|
      mod.singleton_methods.each do |m|
        self.define_method(m, mod.method(m).to_proc)
      end
    end

    class PartOne
      include Solver
      
      attr_reader :called, :boards
      def initialize(called, boards)
        @called = called
        @boards = boards
      end

      def solve
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
    end

    class PartTwo
      include Solver

      attr_reader :called, :boards
      def initialize(called, boards)
        @called = called
        @boards = boards
      end

      def solve
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
    end
  end
  
  def self.part_one
    Solver::PartOne.new(CalledBingoNumbers.new(data).get_numbers, Boards::Grabber::Boing.new(data).prepare_boards).solve
  end

  def self.part_two
    Solver::PartTwo.new(CalledBingoNumbers.new(data).get_numbers, Boards::Grabber::Boing.new(data).prepare_boards).solve
  end

  def self.data
    @data ||= File.open("./spec/#{__FILE__.match(/day_\d+/)}.txt", "r").readlines.map(&:chomp)
  end
end

RSpec.describe Bingo do
  it "solves" do
    expect(Bingo.part_one).to eq 38594
    expect(Bingo.part_two).to eq 21184
  end
end
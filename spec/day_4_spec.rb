require 'byebug'

module Boards
  def prepare_boards
    boards.each_with_object({}) { |(k, v), new_boards| new_boards[k]={data: v, won: false}}
  end

  module Grabber
    def default_boards
      Hash.new {|k, v| k[v] = Array.new }
    end

    class Boing
      attr_reader :data, :boards
      # despite being namespaced within both these modules, we need to include them
      include Grabber
      include Boards
      
      def initialize(data)
        @data = data
        @boards = grab_boards(default_boards)
      end

      def grab_boards(boards)
        no = 0
        data[1..].map {|l| l.split.map {|n| [n, false]}}.each do |l|
          if l == []
            no += 1
            next
          else
            boards[no] << l
          end
        end
        boards
      end
    end
  end

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

  def get_numbers
    access_numbers
  end
end

module Totalizer; end

Totalizer.class_eval do # module_eval and class_eval are aliases for each other
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

default_called = <<-RUBY
  def default_called
    CalledBingoNumbers.new(data).get_numbers
  end
RUBY

class Part; end # Original definition of Part, notice it's outside of the modules

Part.class_eval(default_called) # add one method

module Bingo
  SOLVER_PROCS = {
    default: Proc.new { |line, lines, idx| winning_line_or_column(*[line, lines, idx]) } # we can spread the array into 3 args with *[]
  } # you can't put return in here ^ because it will return out of the calling method (LocalJumpError)

  SOLVER_LAMBDAS = {
    default: -> line, lines, idx { winning_line_or_column(line, lines, idx) },
    other_style: lambda { |line, lines, idx| return winning_line_or_column(line, lines, idx) }
  } # lamdas treat return as a local return, so you can do this ^

  include_module_methods Boards

  def self.data
    @data ||= File.open("./spec/#{__FILE__.match(/day_\d+/)}.txt", "r").readlines.map(&:chomp)
  end

  module Solver
    # here we are converting singleton methods in a module to instance methods in a method (to be included in a class)
    [Bingo, Totalizer].each do |mod|
      mod.singleton_methods.each do |m|
        self.define_method(m, mod.method(m).to_proc)
      end
    end


    Part.class_eval do # add the rest of the methods
      include Solver

      attr_reader :called, :boards, :block
      def initialize(block = SOLVER_PROCS[:default]) # default block so we can switch them out
        @called = default_called
        @boards = default_boards
        @block = block
      end

      def default_boards
        Boards::Grabber::Boing.new(data).prepare_boards
      end

      def default_solver
        SOLVER_PROCS[:default]
      end
    end

    class PartOne < Part      
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
                if block.call(line, lines, idx)
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

    class PartTwo < Part
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
                if block.call(line, lines, idx)
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
    Solver::PartOne.new.solve
  end

  def self.part_two
    Solver::PartTwo.new(SOLVER_LAMBDAS[:default]).solve
  end
end

RSpec.describe Bingo do
  it "solves" do
    expect(Bingo.part_one).to eq 38594
    expect(Bingo.part_two).to eq 21184
  end
end
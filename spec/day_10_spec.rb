require 'byebug'
class SyntaxScoring
  def self.part_one
    errors = []
    data.each_with_index do |line|
      nline = rebuild_line(line)
      line.chars.each_with_index do |char, idx|
        errors << char unless nline[idx] == char
      end
    end

    errors.map {|ic| illegal_char(ic) }.sum
  end

  def self.rebuild_line(line)
    nline = []
    line.chars.each_with_index do |char, idx|
      if [")", "}", "]", ">"].include?(char)
        next
      else
        leftover = nline[idx..]
        nline[idx] = char
        nline[idx+1] = reflection(char)
        leftover.each_with_index do |left, index|
          nline[idx+index+2] = left
        end
      end
    end
    nline
  end

  def self.illegal_char(char)
    case char
    when ")"
      3
    when "]"
      57
    when "}"
      1197
    when ">"
      25137
    end
  end

  def self.reflection(char)
    case char
    when "("
      ")"
    when "["
      "]"
    when "<"
      ">"
    when "{"
      "}"
    end
  end
  
  def self.part_two
    completes = []
    data.each_with_index do |line|
      nline = rebuild_line(line)
      do_break = false
      line.chars.each_with_index do |char, idx|
        do_break = true unless nline[idx] == char
      end
      next if do_break
      completes << nline[line.length..]
    end

    totals = completes.map do |c|
      total = 0
      c.each do |char|
        total *= 5
        total += case char
        when ")"
          1
        when "]"
          2
        when "}"
          3
        when ">"
          4
        end
      end
      total
    end
    totals.sort[totals.length/2]
  end

  def self.data
    @data ||= File.open("./spec/#{__FILE__.match(/day_\d+/)}.txt", "r+").readlines.map(&:chomp)
  end
end

RSpec.describe SyntaxScoring do
  it "solves" do
    expect(SyntaxScoring.part_one).to eq 413733
    expect(SyntaxScoring.part_two).to eq 3354640192
  end
end

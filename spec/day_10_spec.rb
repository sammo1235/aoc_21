require 'byebug'
class SyntaxScoring
  def self.part_one
    # ([])
    data.each_with_index do |line|
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
          p nline
          sleep(0.2)
        end
      end

      line.chars.each_with_index do |char, idx|
        # find incomplete
      end
      if line.chars.zip(nline).all? {|el| el[0] == el[1] }
        # find corrupted
      end
    end
  end

  def self.find_chunk(line, char, idx)
    if line[idx] == reflection(char) # end of chunk
      return true
    else
      find_chunk(line, char, idx+3)
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
  end

  def self.data
    @data ||= File.open("./spec/#{__FILE__.match(/day_\d+/)}_test.txt", "r+").readlines.map(&:chomp)
  end
end

RSpec.describe SyntaxScoring do
  it "solves" do
    expect(SyntaxScoring.part_one).to eq 26397
    expect(SyntaxScoring.part_two).to eq 1075536
  end
end

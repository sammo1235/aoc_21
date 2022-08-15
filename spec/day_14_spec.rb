require 'byebug'
module ExtendedPolymerisation
  def self.part_one
    # p1 uses the dumb brute force approach of actually generating each string
    rules = data[2..].each_with_object({}) {|rule, rules| rules[rule.split(" -> ").first] = rule.split(" -> ").last }

    t = data[0].split("")
    tc = data[0].split("")
    10.times do |step|
      t = tc.clone if step > 0
      tc = t.clone
      inserted = 0
      (0..t.length-2).each do |n|
        pair = t[n..n+1]
        rest = t[n+1..]
        tc[n+1+inserted] = rules[pair.join]
        tc[n+2+inserted..] = rest
        inserted += 1
      end
    end
    counts = tc.tally.sort_by {|k, v| v }
    counts.last[1] - counts.first[1]
  end

  def self.part_two
    # p2 uses a dynamic programming approach, which only cares about the counts of each element pair
    rules = data[2..].each_with_object({}) {|rule, rules| rules[rule.split(" -> ").first] = rule.split(" -> ").last }

    t = data[0].split("")
    counts = Hash.new(0)
    # get initial count
    (0..t.length-2).each do |n|
      pair = t[n..n+1].join
      counts[pair] += 1
    end

    40.times do |step|
      counts.select {|k, v| v > 0 }.each do |pair, count|
        counts[pair] -= count
        mut = rules[pair]
        first = pair[0] + mut
        counts[first] += count
        last = mut + pair[1]
        counts[last] += count

      end
    end

    elc = Hash.new(0)
    # add 1 to the count of the last letter from the template
    counts[t[-1]] += 1
    counts.each do |comp, count|
      elc[comp[0]] += count
    end
    sort_counts = elc.sort_by {|k, v| v }
    sort_counts.last[1] - sort_counts.first[1]
  end

  def self.data    
    @data ||= File.open("./spec/#{__FILE__.match(/day_\d+/)}.txt", "r").readlines.map(&:chomp)
  end
end

RSpec.describe ExtendedPolymerisation do
  it "solves" do
    expect(ExtendedPolymerisation.part_one).to eq 2657
    expect(ExtendedPolymerisation.part_two).to eq 2911561572630
  end
end
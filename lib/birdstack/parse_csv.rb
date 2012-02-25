module Birdstack::ParseCSV
  require 'csv'

  def self.code_note(row, obj)
    obj.code = row[9]
    obj.note = row[10]
  end

  def parse_ioc_csv(filename)
    orders = []
    header = false
    CSV.open(filename, 'r') do |row|
      unless header then
        header = true
        next
      end

      if(row[0]) then
        o = Order.new
        o.latin_name = row[0]
        code_note(row, o)
        orders << o
        puts o.latin_name
      elsif(row[1]) then
        f = Family.new
        f.latin_name = row[1]
        f.english_name = row[2]
        code_note(row, f)
        orders.last.families << f
        f.order = orders.last # Because we don't save, Rails doesn't do this for us
        puts "\t#{f.english_name}"
      elsif(row[3]) then
        g = Genus.new
        g.latin_name = row[3]
        code_note(row, g)
        orders.last.families.last.genera << g
        g.family = orders.last.families.last # Because we don't save, Rails doesn't do this for us
      elsif(row[4]) then
        s = Species.new
        s.latin_name = row[4]
        s.english_name = row[5]
        row[6].split(', ').each {|r| s.regions << Region.find_by_code!(r) }
        s.breeding_subregions = row[7]
        s.nonbreeding_regions = row[8]
        code_note(row, s)
        orders.last.families.last.genera.last.species << s
        s.genus = orders.last.families.last.genera.last # Because we don't save, Rails doesn't do this for us
      else
        raise "row confusion!: #{row.join(', ')}"
      end
    end

    return orders
  end

  module_function :parse_ioc_csv
end

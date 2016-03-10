require 'slop'

opts = Slop.parse do |o|
  o.banner = 'Usage: ruby give_name.rb -n prefix.txt,suffix.txt -r used.txt'

  names_desc = 'Paths to files containing a list of names to generate from. '\
  'Multiple files can be seperated using comma to create prefixes/suffixes.'
  o.array '-n', '--names', names_desc

  reserved_desc = 'Path to a file to stored the used/reserved names in'
  o.string '-r', '--reserved', reserved_desc

  o.bool '-l', '--lowercase', 'Outputs the name in lowercase'

  o.on '-h', '--help', 'Show this help screen' do
    puts o
    exit
  end
end

# Read names
name_lists = []
opts[:names].each do |name_file|
  name_lists.push(File.read(name_file).split(/\n/))
end

# Read reserved names
reserved_names = []
if !opts[:reserved].nil? && File.exist?(opts[:reserved])
  reserved_names = File.read(opts[:reserved]).split(/\n/)
end

# Contains method to concatenate random names and find unique ones
class Generator
  def initialize(name_ranges, reserved_names)
    @unique_names = build_unique_names(name_ranges)
    @reserved_names = reserved_names
    @has_unreserved_names = !@unique_names.find { |n| unreserved?(n) }.nil?
  end

  # recursively goes through each entry in name_ranges[0] and adds on each
  # possible combination of the rest of the name ranges
  def build_unique_names(name_ranges)
    return name_ranges[0] if name_ranges.length == 1

    unique_names = []
    inner_ranges = name_ranges.drop(1)
    name_ranges[0].each do |name|
      build_unique_names(inner_ranges).each do |inner_name|
        unique_names.push("#{name}_#{inner_name}")
      end
    end
    unique_names
  end
  private :build_unique_names

  def unreserved?(name)
    @reserved_names.find { |n| n.casecmp(name) == 0 }.nil?
  end

  def random_name
    selected_names = @name_ranges.map(&:sample)
    selected_names.join('_')
  end

  def unique_name
    fail 'No unique names left' unless @has_unreserved_names
    name = @unique_names.sample
    @reserved_names.push(name)
    @unique_names.delete(name)
    name
  end
end

generator = Generator.new(name_lists, reserved_names)
name = generator.unique_name
name = name.downcase if opts[:lowercase]

unless opts[:reserved].nil?
  open(opts[:reserved], 'a') do |f|
    f.puts name + "\n"
  end
end

puts name

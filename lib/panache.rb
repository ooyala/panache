require "find"
require "colorize"

module Panache
  @@styles = []

  DEFAULT_TAB_SPACES = 2
  DEFAULT_STYLE_PATH = File.expand_path("~/repos/panache/panache_styles")
  Violation = Struct.new :line_number, :line, :offset, :style, :rule

  class Rule
    attr_reader :message
    def initialize(regexes, message)
      @regexes = regexes
      @message = message
    end

    def check(line)
      offset = 0
      violations = []
      @regexes.each do |regex|
        while (match = regex.match(line, offset))
          # If the match size is 1, then the user did not provide any captures in their regex and we only know
          # that there is >= 1 violation of the rule in this line.
          if match.size == 1
            return [Violation.new(nil, line, nil, nil, self)]
          end
          offset = match.offset(1)[0]
          violations << Violation.new(nil, line, offset, nil, self)
          offset += 1
        end
      end
      violations
    end
  end

  class Style
    def initialize(file_regex)
      @tab_spaces = DEFAULT_TAB_SPACES
      @file_regex = file_regex
      @rules = []
    end

    def self.create(file_regex, &block)
      style = Style.new(file_regex)
      style.instance_eval &block
      Panache.add_style style
    end

    def spaces_per_tab(n)
      @tab_spaces = n
    end

    def rule(regex, message)
      if regex.is_a? Array
        @rules << Rule.new(regex, message)
      else
        @rules << Rule.new([regex], message)
      end
    end

    def checks?(file_name)
      file_name =~ @file_regex
    end

    def check(line)
      # Replace tabs with spaces according to the specified conversion.
      line.gsub!("\t", " " * @tab_spaces)
      @rules.flat_map do |rule|
        violations = rule.check(line)
        violations.each { |v| v.style = self }
      end
    end
  end

  def self.add_style(style)
    @@styles << style
  end

  # Load all Panache styles (files matching *_style.rb) from a given directory.
  def self.load_styles(directory = DEFAULT_STYLE_PATH)
    raise "Need a directory of Panache styles" unless File.directory?(directory)
    style_files = Dir.glob(File.join(directory, "*_style.rb"))
    raise "No Panache styles found in #{directory}" if style_files.empty?
    style_files.each do |style|
      puts "Loading #{style}...".green
      load style
    end
    puts "Loaded #{style_files.size} style#{"s" if style_files.size != 1}.".green
  end

  # Check a given file against loaded styles.
  def self.check_file(path)
    styles = @@styles.select { |style| style.checks? path }
    line_number = 0
    File.open(path).each_with_index.flat_map do |line, line_number|
      line_number += 1
      styles.flat_map { |style| style.check(line) }.each { |violation| violation.line_number = line_number }
    end
  end

  # Check a file or directory
  def self.check_path(path)
    if File.directory? path
      files = Find.find(path).select { |sub_path| File.file? sub_path }
    elsif File.file? path
      files = [path]
    else
      puts "Skipping path: #{path}".yellow
      return {}
    end
    puts "Checking #{path}".green
    results = {}
    files.each { |file| results[file] = Panache.check_file file }
    results
  end

  class Printer
    def initialize(results, output_type = :normal)
      @results = results
      @output_type = output_type
    end

    def print_results
      case @output_type
      when :normal then print_normal
      else print normal
      end
    end

    private

    def print_normal
      violations_found = 0
      bad_files = 0
      @results.each do |file, result|
        next if result.empty?
        puts "Style violations in #{file}:".red
        bad_files += 1
        result.each do |violation|
          violations_found += 1
          puts "Line #{violation.line_number}: #{violation.rule.message}".blue
          puts violation.line
          puts " " * violation.offset + "^".blue if violation.offset
        end
      end
      if violations_found.zero?
        puts "No violations found.".green
      else
        puts "Found #{plural(violations_found, "violation")} in #{plural(bad_files, "bad file")}.".red
      end
      violations_found.zero?
    end
  end
end

def plural(amount, thing)
  "#{amount} #{thing}#{"s" unless amount == 1}"
end

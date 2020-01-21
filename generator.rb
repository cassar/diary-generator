require 'erb'
require 'active_support/all'
require 'pry'

class DiaryGenerator
  DIARY_PATH = File.read('.diary_config').strip
  TOMORROW = 'tomorrow'
  YESTERDAY = 'yesterday'

  attr_reader :time, :ordinal_day, :month, :month_name, :year, :directory_path

  def initialize
    @time = determine_time
    @ordinal_day = time.day.ordinalize
    @month = time.month
    @month_name = time.strftime '%B'
    @year = time.year
    @directory_path = determine_path
  end

  def heading
    "#{ordinal_day} #{month_name} #{year}"
  end

  def generate!
    Dir.mkdir directory_path unless File.exists? directory_path
    File.write file_path, content
    puts in_green "New diary entry created for the #{heading}"
  end

  def should_do_on *days
    days.include? day_name
  end

  private

  def file_path
    "#{directory_path}/#{ordinal_day}.md"
  end

  def template_path(time)
    if ['Saturday', 'Sunday'].include? day_name
      '/typical_day_template.md'
    else
      '/typical_work_day_template.md'
    end
  end

  def day_name
    time.strftime '%A'
  end

  def determine_time
    case ARGV.first
    when TOMORROW
      Time.now.tomorrow
    when YESTERDAY
      Time.now.yesterday
    else
      Time.now
    end
  end

  def content
    ERB.new(File.read(DIARY_PATH + template_path(time))).result
  end

  def determine_path
    "#{DIARY_PATH}/#{year}/#{0 if month < 10}#{month}_#{month_name.downcase}"
  end

  def in_green(text)
    "\e[1;32m#{text}\e[0m"
  end
end

generator = DiaryGenerator.new
generator.generate!

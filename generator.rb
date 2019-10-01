require 'erb'
require 'active_support/all'
require 'pry'

class DiaryGenerator
  DIARY_PATH = File.read('.diary_config').strip
  TOMORROW = 'tomorrow'

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
    File.write "#{directory_path}/#{ordinal_day}.md", content
  end

  private

  def template_path(time)
    if ['Saturday', 'Sunday'].include? time.strftime("%A")
      '/typical_day_template.md'
    else
      '/typical_work_day_template.md'
    end
  end

  def determine_time
    return Time.now.tomorrow if ARGV.first == TOMORROW

    Time.now
  end

  def content
    ERB.new(File.read(DIARY_PATH + template_path(time))).result
  end

  def determine_path
    "#{DIARY_PATH}/#{0 if month < 10}#{month}_#{month_name.downcase}"
  end
end

generator = DiaryGenerator.new
generator.generate!

# frozen_string_literal: true

require 'erb'
require 'active_support/all'
require 'pry'

require_relative 'bash_styling'

# Used to generate the diary entry
class DiaryGenerator
  DIARY_PATH = File.read('.diary_config').strip
  TOMORROW = 'tomorrow'
  YESTERDAY = 'yesterday'
  OPEN = 'open'

  include BashStyling

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

  def handle
    generate! unless ARGV.include? OPEN
    system "atom #{in_shell_format DIARY_PATH, file_path}"
  end

  def should_do_on(*days)
    days.include? day_name
  end

  private

  def generate!
    prepare_directory_path
    File.write file_path, content
    puts in_green "New diary entry created for the #{heading}"
  rescue StandardError
    puts in_red "Diary generator aborted for #{heading}"
  end

  def prepare_directory_path
    Dir.mkdir directory_path unless File.exist? directory_path
    return unless File.exist? file_path

    puts in_blue 'Overwrite existing file? (yes/no)'
    raise StandardError unless 'yes'.match? STDIN.gets.strip
  end

  def file_path
    "#{directory_path}/#{ordinal_day}.md"
  end

  def template_path
    if %w[Saturday Sunday].include? day_name
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
    ERB.new(File.read(DIARY_PATH + template_path)).result
  end

  def determine_path
    "#{DIARY_PATH}/#{year}/#{0 if month < 10}#{month}_#{month_name.downcase}"
  end
end

DiaryGenerator.new.handle

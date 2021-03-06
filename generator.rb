# frozen_string_literal: true

require 'erb'
require 'active_support/all'

require_relative 'bash_styling'

# Used to generate the diary entry
class DiaryGenerator
  DIARY_PATH = File.read("#{Dir.home}/.diary_config").strip
  TOMORROW = 'tomorrow'
  YESTERDAY = 'yesterday'
  OPEN = 'open'
  HELP = '--help'

  include BashStyling

  attr_reader :time, :ordinal_day, :month, :month_name, :year

  def initialize
    @time = determine_time
    @ordinal_day = time.day.ordinalize
    @month = time.month
    @month_name = time.strftime '%B'
    @year = time.year
  end

  def heading
    "#{ordinal_day} #{month_name} #{year}"
  end

  def handle
    return help_message if ARGV.include? HELP

    generate! unless ARGV.include? OPEN
    system "atom #{in_shell_format DIARY_PATH, file_path}"
  end

  def should_do_on(*days)
    days.include? day_name
  end

  private

  def help_message
    puts ''"
    Usage: diary [options]
      open
      tomorrow
      yesterday
      --help
    "''
  end

  def generate!
    prepare_directory_path
    File.write file_path, content
    puts in_green "New diary entry created for the #{heading}"
  rescue StandardError => e
    puts in_red e
  end

  def prepare_directory_path
    Dir.mkdir directory_path_to_year unless File.exist? directory_path_to_year
    Dir.mkdir directory_path_to_month unless File.exist? directory_path_to_month
    return unless File.exist? file_path

    puts in_blue 'Overwrite existing file? (yes/no)'
    return if 'yes'.match? STDIN.gets.strip

    raise StandardError, "Diary generator aborted for #{heading}"
  end

  def file_path
    "#{directory_path_to_month}/#{ordinal_day}.md"
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
    case ARGV.join
    when Regexp.new(TOMORROW)
      Time.now.tomorrow
    when Regexp.new(YESTERDAY)
      Time.now.yesterday
    else
      Time.now
    end
  end

  def content
    ERB.new(File.read(DIARY_PATH + template_path)).result
  end

  def directory_path_to_month
    "#{directory_path_to_year}/#{0 if month < 10}#{month}_#{month_name.downcase}"
  end

  def directory_path_to_year
    "#{DIARY_PATH}/#{year}"
  end
end

(generator = DiaryGenerator.new).handle

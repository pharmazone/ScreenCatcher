#!/usr/bin/env ruby
require 'rubygems'
require 'RMagick'

def show_usage
  puts <<-USAGE.gsub(/^ {2}/, '').gsub(/FNAME/,__FILE__)
  Compare images in folders.

  Usage:
      FNAME folder1 folder2

  folder1, folder2 directories with png images.
  USAGE
  exit
end
show_usage unless ARGV.length == 2

@files = []
@dirs = []
ARGV.each do |dir|
  @dirs << dir
  Dir.chdir(dir) do
    @files << Dir.glob('*.png')
  end
end

if @files[0] != @files[1]
  print "There is different set of files found in directories: " + @dirs.join(',')
  exit 1
end

@files[0].each do |file|
  file1 = File.join(@dirs[0], file)
  file2 = File.join(@dirs[1], file)
  image1  = Magick::ImageList.new(file1)
  image2 = Magick::ImageList.new(file2)

  printf("%-60s\t", file)
  begin
    delta_file, distance = image1.compare_channel(image2, Magick::RootMeanSquaredErrorMetric)
    if distance != 0
      delta_file_name = "diff_#{file}"
      delta_file.write(delta_file_name)
      printf("[ FAIL ] Distance: %-10f\t Saved: %s", distance, delta_file_name)
    else
      printf('[ OK ]')
    end
  rescue Magick::ImageMagickError  => e
      printf('[ Exception ] ' + e.message)
  end
  print "\n"
end


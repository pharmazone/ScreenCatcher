#!/usr/bin/env ruby
require 'rubygems'
require "selenium-webdriver"

def show_usage
  puts <<-USAGE.gsub(/^ {2}/, '').gsub(/FNAME/,__FILE__)
  Script make scrinshorts for ULR listed in UrlListFile.

  Usage:
      FNAME UrlListFile HostPrefix OutputDir

  UrlListFile must contains URLs(without HostPrefix),
              one URL per line.

  HostPrefix  string will be prepended to each URL 
              form UrlListFile. Should contains protocol prefix.
              Example: http://planet.testpublic.symmetrics.de/shop

  OtputDir.is directory where scrinshorts will be saved.
              If directory  doesnt exists  it will be created.

  By default FireFox driver is using.

  Example:
      FNAME urlList.txt http://planet.testintern.symmetrics.de/shop intern
  USAGE
  exit
end
show_usage unless ARGV.length == 3

file, host, dirname = ARGV
FileUtils.mkdir_p dirname unless File.directory? dirname

http_client = Selenium::WebDriver::Remote::Http::Default.new
http_client.timeout = 300

@driver = Selenium::WebDriver.for :firefox, :http_client => http_client
begin
  File.open(file, "r").each do |url|
    url.strip!
    link = File.join(host, url)
    filename = url.gsub(/\/|\?|&/,'_') + '.png';
    printf "%-60s\t", url
    @driver.get link
    print "[ Opened ]\t"
    @driver.save_screenshot File.join(dirname, filename)
    print "[ Saved ]\n"
  end
ensure
  @driver.quit
end

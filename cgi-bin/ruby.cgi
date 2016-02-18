#! /usr/local/bin/ruby
require 'erb'
require 'cgi'
puts 'Content-Type: text/html; charset=utf-8'
puts
ERB.new(IO.read(CGI.new.path_translated)).run



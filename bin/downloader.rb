#!/usr/bin/env ruby

begin
  require 'dotenv'
  Dotenv.load
rescue LoadError
  # dotenv not loaded, no problemo!
end

require_relative '../lib/hellosign_downloader'

begin
  raise ArgumentError if ARGV.empty?
  signature_ids = ARGV
  HelloSignDownloader::Downloader.new(signature_ids).download
rescue ArgumentError
  puts 'Número de parametros incorrectos'
end

#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'
require 'pp'

MAIN_TAGS = %w{adventure action casual rpg strategy simulation}

genres = {}

Dir.glob("_games/*") do |filename|
  tags = []
  game = YAML.load_file(filename)
  game['genres'].each do |genre|
    tag_name = genre.downcase
    genres[tag_name] ||= 0
    genres[tag_name] += 1
  end

  game['genres'].each do |genre|
    tag_name = genre.downcase
    if MAIN_TAGS.include?(tag_name)
      tags << tag_name
    end
  end
  if tags.empty?
    tags << "unspecified"
  end

  game['tags'] = tags

  File.open(filename, "w+") do |out|
    out.puts game.to_yaml
    out.puts "---"
    out.puts
  end
end

puts "Tag Count info:"
pp genres.to_a.sort_by{|a| a[1]}

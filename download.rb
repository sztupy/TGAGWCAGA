#!/usr/bin/env ruby
require 'uri'
require 'net/http'
require 'json'

games = [2097570,2097570,2113850,1835240,2000210,1830970,3223000,2219390,1717730]

games.each do |game|
  uri = URI("https://store.steampowered.com/api/appdetails?appids=#{game}")
  res = Net::HTTP.get_response(uri)
  if res.is_a?(Net::HTTPSuccess)
    data = JSON.parse(res.body)
    gd = data[game.to_s]['data']

    slug = gd['name'].gsub(' ','_').delete('^a-zA-Z0-9_')

    File.open("_games/#{game}-#{slug}.markdown","w+") do |out|
      out.puts <<~"DATA"
      ---
      title: #{gd['name'].to_json}
      description: #{gd['short_description'].to_json}
      image: #{gd['header_image'].to_json}
      capsule_image: #{gd['capsule_image'].to_json}
      categories: game
      steamid: #{game}
      screenshots: #{gd['screenshots'].to_json}
      movies: #{gd['movies'].to_json}
      genres: #{gd['genres'].map{|g| g['description']}.to_json}
      steam_categories: #{gd['categories'].map{|g| g['description']}.to_json}
      platforms: #{gd['platforms'].to_json}
      developers: #{gd['developers'].to_json}
      publishers: #{gd['publishers'].to_json}
      release_date: #{gd['release_date'].to_json}
      content_warning: #{gd['content_descriptors'].to_json}
      about: #{gd['about'].to_json}
      detailed_description: #{gd['detailed_description'].to_json}
      ---

      DATA
    end
  else
    STDERR.puts "Could not download data for #{game}"
  end
end

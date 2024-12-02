#!/usr/bin/env ruby
require 'uri'
require 'net/http'
require 'json'
require 'nokogiri'

games = %w{
https://breach-vr.itch.io/the-old-barn
https://chairian.itch.io/scrapplers
https://crookedbeaker.itch.io/looking-inward
https://dankboi68.itch.io/srpgs-acid-trip-25-charlies-harem
https://eva-codes.itch.io/saltwater-bodies
https://giarosart.itch.io/beluflin
https://guilloteam.itch.io/chumini-tiny-army
https://izumi-games.itch.io/talents-demo
https://jamie-geist.itch.io/auranova
https://koonce.itch.io/crockpot
https://matthyy.itch.io/second-impact
https://natikatz.itch.io/flowerdrops
https://niighty-nine.itch.io/mythical-love
https://oksoft.itch.io/hrspwr
https://polytelygames.itch.io/the-crowns-shadow-game-jam
https://porchor.itch.io/yeeraffe
https://rafaelaoverflow.itch.io/elder-lich
https://sealkode-games.itch.io/dreaming-seal-simulator-8bit
https://siurellgames.itch.io/towny-bar
https://skyfeathergames.itch.io/existexe
https://squigglez.itch.io/traintracks-combat
https://super-walrus-games.itch.io/walthros-renewal
https://synapticsugar.itch.io/agents-of-groove
https://sysomying.itch.io/mrwolf
https://the-balthazar.itch.io/sternly-worded-adventures
https://the-bughouse.itch.io/freeky-faucets-arcade
https://tzoik.itch.io/neurolink
https://vaporwavegothicstudio.itch.io/a-bone-to-pick
https://wildwildnt.itch.io/sacabambaspis-friendly-adventure
https://y-ingfoxy.itch.io/not-my-part
https://zagoiris.itch.io/lefol}

games.each do |game|
  p game
  uri = URI("#{game}/data.json")
  req = Net::HTTP::Get.new(uri)
  req['Cookie'] = ENV['ITCH_COOKIES']
  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https', :read_timeout => 500) { |http|
    http.request(req)
  }
  if res.is_a?(Net::HTTPSuccess)
    gd = JSON.parse(res.body)
    slug = gd['title'].gsub(' ','_').delete('^a-zA-Z0-9_')
    id = gd['id']

    p id

    uri2 = URI("https://api.itch.io/games/#{id}")
    req2 = Net::HTTP::Get.new(uri2)
    req2['Cookie'] = ENV['ITCH_COOKIES']
    res2 = Net::HTTP.start(uri2.hostname, uri2.port, use_ssl: uri2.scheme == 'https', :read_timeout => 500) { |http|
      http.request(req2)
    }

    data2 = JSON.parse(res2.body)['game']

    p data2['traits']

    uri3 = URI(game)
    req3 = Net::HTTP::Get.new(uri3)
    req3['Cookie'] = ENV['ITCH_COOKIES']
    res3 = Net::HTTP.start(uri3.hostname, uri3.port, use_ssl: uri.scheme == 'https', :read_timeout => 500) { |http|
      http.request(req3)
    }

    html_doc = Nokogiri::HTML(res3.body)

    start_id = 0
    screenshots = []
    html_doc.css(".screenshot_list a").each do |link|
      screenshots << {
        id: start_id,
        path_thumbnail: link.at_css("img").attributes['src'].to_s,
        path_full: link.attributes['href'].to_s
      }
      start_id += 1
    end

    unreleased = false

    if html_doc.xpath("//a[@href='https://itch.io/games/in-development']").length>0
      unreleased = true
    end

    File.open("_games/I#{id}-#{slug}.markdown","w+") do |out|
      out.puts <<~"DATA"
      ---
      title: #{gd['title'].to_json}
      description: #{data2['short_text'].to_json}
      image: #{gd['cover_image'].to_json}
      categories: game
      itchid: #{gd['id']}
      itchlink: #{game.to_json}
      genres: #{gd['tags'].to_json}
      platforms: #{data2['traits'].to_json}
      developers: #{(gd['authors']||[]).map{|a|a['name']}.to_json}
      screenshots: #{screenshots.to_json}
      release_date: #{{ coming_soon: unreleased, date: data2['published_at']}.to_json}
      ---

      DATA
    end
  else
    STDERR.puts "Could not download data for #{game}"
  end
end

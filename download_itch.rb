#!/usr/bin/env ruby
require 'uri'
require 'net/http'
require 'json'

#3367740

# https://vaporwavegothicstudio.itch.io/a-bone-to-pick
# https://guilloteam.itch.io/chumini-tiny-army
# https://sealkode-games.itch.io/dreaming-seal-simulator-8bit
# https://crookedbeaker.itch.io/looking-inward
# https://the-balthazar.itch.io/sternly-worded-adventures
# https://izumi-games.itch.io/talents-demo
games = %w{https://polytelygames.itch.io/the-crowns-shadow-game-jam
https://breach-vr.itch.io/the-old-barn
https://siurellgames.itch.io/towny-bar
https://squigglez.itch.io/traintracks-combat
https://super-walrus-games.itch.io/walthros-renewal
https://synapticsugar.itch.io/agents-of-groove
https://sysomying.itch.io/mrwolf
https://giarosart.itch.io/beluflin
https://wildwildnt.itch.io/sacabambaspis-friendly-adventure
https://natikatz.itch.io/flowerdrops
https://dankboi68.itch.io/srpgs-acid-trip-25-charlies-harem
https://tzoik.itch.io/neurolink
https://chairian.itch.io/scrapplers
https://koonce.itch.io/crockpot
https://rafaelaoverflow.itch.io/elder-lich
https://matthyy.itch.io/second-impact
https://porchor.itch.io/yeeraffe}

games.each do |game|
  p game
  uri = URI("#{game}/data.json")
  res = Net::HTTP.get_response(uri)
  if res.is_a?(Net::HTTPSuccess)
    gd = JSON.parse(res.body)
    p gd
    slug = gd['title'].gsub(' ','_').delete('^a-zA-Z0-9_')
    id = gd['id']

    uri2 = URI("https://api.itch.io/games/#{id}")
    req = Net::HTTP::Get.new(uri2)
    req['Cookie'] = ENV['ITCH_COOKIES']
    res2 = Net::HTTP.start(uri2.hostname, uri2.port, use_ssl: uri2.scheme == 'https') { |http|
      http.request(req)
    }

    data2 = JSON.parse(res2.body)['game']

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
      release_date: #{data2['published_at'].to_json}
      ---

      DATA
    end
  else
    STDERR.puts "Could not download data for #{game}"
  end
end

# TGAGWCAGA
The Game Awards for Games Who Can't Afford the Game Awards

# Generating game list:

## Steam

1. Obtain your Steam Api key from https://steamcommunity.com/dev/apikey
2. Run the following replaccing `<your key>` with the key above:

```bash
STEAM_KEY=<your key> ./download_steam.rb
```

3. Watch the output, Steam has a rate limit that kicks in after downloading around 100 games. Once that happens wait 10-15 minutes, edit the list to remove anything that's already downloaded and continue

## Itch

1. Login to itch
2. Obtain the following cookies from your browser: `itchio` and `itchio_token`
3. Run the following, replacing the parts in `<... cookie>` with the value above:

```bash
ITCH_COOKIES='itchio=<itchio cookie>; itchio_token=<itchio_token cookie>' ./download_itch.rb
```

## Tags
Once you have obtained games from both systems run

```bash
./tag_filler.rb
```

This will clean up the input and add tags to each game based on the 6 main categories.

## Post-processing

You might need to go through the itch games to make sure they are downloaded properly. Release date especially can be problematic as itch's API doesn't tell you if a game is released already or not. You might also want to replace the description with something more meaningful.

Games in the Other category will likely need retagged, unless it's clear they really don't belong into the 6 main categories

require 'httpclient'
require 'nokogiri'

songs_link = ARGV[0]
output_dir = ARGV[1] ||= Dir.pwd

def get_song_list(htm)
  artist = htm.css('div#artisttitle').text
  song_list = []
  push_trs = Proc.new {|n|
    s_title = n.css('a')[0].text.gsub('  ','')
    s_dl = n.css('a')[5].attributes['href'].value
    [artist, s_title, s_dl]
  }
  song_list = htm.css('tr')[2..-1].map(&push_trs)
  return song_list
end

def download_song(client, uri, artist, s_title, s_dl, output_dir)
  dl_page = client.get(uri.scheme + '://' + uri.host + s_dl)
  file_dl = dl_page.headers['Location']
  filename = sprintf "%s - %s.%s", artist, s_title.gsub(/[:\/\\]/,'_'), file_dl[-3..-1] 
  if !File.exist?(File.join(output_dir, artist, filename))
    open(File.join(output_dir, artist, filename), 'wb') do |file|
      file.write(client.get(uri.scheme + '://' + uri.host + file_dl).content)
      file.close
    end
  end
end

def download_songs(client, song_list, output_dir, uri)
  song_list.map do |song|
    download_song(client, uri, song[0], song[1], song[2], output_dir)
  end
end

# create the cookie
cookie_info = {
  name: 'AcidPlanetSession',
  value: 'enter your cookie value here',
  url: URI.parse(songs_link)
}
cookie = WebAgent::Cookie.new
cookie.name = cookie_info[:name]
cookie.value = cookie_info[:value]
cookie.url = cookie_info[:url]

# initialize the client and add the cookie
client = HTTPClient.new
client.cookie_manager.add cookie

# get songs page and parse links
songs_obj = client.get songs_link
noko = Nokogiri::HTML(songs_obj.content)
song_list = get_song_list(noko)

# make the output directory
dirname = File.join(output_dir, song_list[0][0])
if !Dir.exist?(dirname)
  Dir.mkdir(dirname)
end


download_songs(client, song_list, output_dir, cookie_info[:url])


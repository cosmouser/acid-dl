# acid-dl
Downloads songs from an artist's songs page on acidplanet

## Usage
Use the url for the artist's songs page as the first argument and the optional output dir as the second argument
```
ruby acid-dl.rb "http://www.acidplanet.com/artist.asp?songs=3511531361514315"
```
will download songs to the current directory

```
ruby acid-dl.rb "http://www.acidplanet.com/artist.asp?songs=3511531361514315" new_music_folder
```
will download songs to new_music_folder

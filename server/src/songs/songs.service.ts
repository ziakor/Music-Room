import { Song } from './dto/song.dto';
import { Injectable } from '@nestjs/common';
import { SpotifyService } from 'src/spotify/spotify.service';

export interface SearchSongReturn {
  tracks: Song[];
}

//! Changer song dto, revoir le type de retour
@Injectable()
export class SongsService {
  constructor(private readonly spotifyService: SpotifyService) {}
  async search(name: string): Promise<SearchSongReturn> {
    const listTracksSpotify = await this.spotifyService.searchTrack(name);
    let listTracks = {
      tracks: listTracksSpotify.items
        .filter((element) => element.preview_url != null)
        .map((track) => ({
          name: track.name,
          image: track.album.images[0].url,
          author: track.artists[0].name,
          url: track.preview_url,
        })),
    };
    return listTracks;
  }
}

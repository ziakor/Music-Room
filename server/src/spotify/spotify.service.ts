import { Injectable } from '@nestjs/common';

var SpotifyWebApi = require('spotify-web-api-node');
@Injectable()
export class SpotifyService {
	 spotifyApi = new SpotifyWebApi({
		 clientId: '',
		 clientSecret: ''
	 });

	 constructor(){
		}
		async searchTrack(name: string) {
			try {
				
				let credential = await this.spotifyApi.clientCredentialsGrant()
				this.spotifyApi.setAccessToken(credential.body['access_token']);
				let res = await this.spotifyApi.searchTracks(`track:${name}`)
				return ({items: res.body.tracks.items})
		} catch (error) {
				return ({items: []})
				
			}
	}
}
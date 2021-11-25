import { UpdateRightLicensePlaylistDto } from './../dto/update-right-license-playlist.dto';
import { Logger, UseGuards } from '@nestjs/common';
import {
  OnGatewayConnection,
  OnGatewayDisconnect,
  OnGatewayInit,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { AuthGuard } from 'src/auth/auth.guard';
import { Server, Socket } from 'socket.io';
import { PlaylistSocketService } from './playlist-socket.service';
import { addSongToWaitingListPlaylistDto } from '../dto/add-song-to-waiting-list-playlist.dto';
import { JoinPlaylistSocketDto } from '../dto/join-playlist-socket.dto';
@WebSocketGateway(3001, { namespace: 'playlist' })
@UseGuards(AuthGuard)
export class PlaylistGateway
  implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer() public server: Server;
  constructor(
    private socketService: PlaylistSocketService,
    private readonly playlistSocketService: PlaylistSocketService,
  ) {}
  private logger: Logger = new Logger('AppGateway');

  afterInit(server: Server) {
    this.logger.log('Init Playlist Websocket');
    this.socketService.socket = server;
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected: ${client.id}`);
  }

  handleConnection(client: Socket, ...args: any[]) {
    this.logger.log(`Client connected: ${client.id}`);
  }

  @SubscribeMessage('addSongToWaitingList')
  async handleAddSongToWaitingList(
    client: Socket,
    data: addSongToWaitingListPlaylistDto,
  ) {
    const res = await this.playlistSocketService.addSongToWaitingList(
      data.playlistId,
      client.data.userId,
      data.name,
      data.url,
      data.image,
      data.author,
    );
    if (res == true) {
      this.server.in(data.playlistId).emit('userAddedSong', {
        name: data.name,
        image: data.image,
        url: data.url,
        author: data.author,
        grade: [{ note: 1, fromId: client.data.userId }],
      });
    }
  }

  @SubscribeMessage('joinPlaylist')
  handleJoinRoom(client: Socket, data: JoinPlaylistSocketDto) {
    client.join(data.playlistId);
    this.server.to(data.playlistId).emit('userJoinedPlaylist', {
      id: client.data.userId,
      pseudo: data.pseudo,
      role: data.role,
      isInvited: data.isInvited,
    });
  }

  @SubscribeMessage('leavePlaylist')
  async handleLeaveRoom(client: Socket, playlist: string) {
    await this.socketService.leave(playlist, client.data.userId);
    client.leave(playlist);
    this.server
      .to(playlist)
      .emit('userLeavedPlaylist', { userId: client.data.userId });
  }

  @SubscribeMessage('updateRightLicense')
  handleUpdateRightLicense(
    client: Socket,
    data: UpdateRightLicensePlaylistDto,
  ) {
    this.server.in(data.playlistId).emit('rightLicenseUpdated', data);
  }
}

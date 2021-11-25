import { OnGatewayInit } from '@nestjs/websockets';
import { OnGatewayDisconnect } from '@nestjs/websockets';
import { WebSocketServer } from '@nestjs/websockets';
import { OnGatewayConnection } from '@nestjs/websockets';
import { SubscribeMessage } from '@nestjs/websockets';
import { WebSocketGateway } from '@nestjs/websockets';
import { WsResponse } from '@nestjs/websockets';
import { RoomSocketService } from './room-socket.service';
import { Server, Socket } from 'socket.io';
import { Logger, UseGuards } from '@nestjs/common';
import { UpdateCurrentSongStatusDto } from '../dto/update-current-song-status.dto';
import { JoinRoomSocketDto } from '../dto/join-room-socket.dto';
import { UpdateCurrentSongTimeDto } from '../dto/update-current-song-time.dto';
import { UpdateCurrentSongDto } from '../dto/update-current-song.dto';
import { addSongToWaitingListDto } from '../dto/add-song-to-waiting-list.dto';
import { VoteSongDto } from '../dto/vote-song.dto';
import { AuthGuard } from 'src/auth/auth.guard';
import { UpdateRightLicenseDto } from '../dto/update-right-license-dto';
import { UpdateInvitationCodeDto } from '../dto/update-invitation-code.dto';
import { UpdateRoleUserDto } from '../dto/update-user-role.dto';
@WebSocketGateway(3001, { namespace: 'rooms' })
@UseGuards(AuthGuard)
export class RoomGateway
  implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer() public server: Server;
  constructor(
    private socketService: RoomSocketService, //! A REVOIR
    private readonly roomSocketService: RoomSocketService,
  ) {}
  private logger: Logger = new Logger('AppGateway');

  afterInit(server: Server) {
    this.logger.log('Init Room Websocket');
    this.socketService.socket = server;
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected: ${client.id}`);
  }

  handleConnection(client: Socket, ...args: any[]) {
    this.logger.log(`Client connected: ${client.id}`);
  }
  @SubscribeMessage('updateCurrentSongStatus')
  async handleStatusSong(client: Socket, data: UpdateCurrentSongStatusDto) {
    await this.roomSocketService.updateCurrentMusicOnPlay(
      data.roomId,
      data.status,
      client.data.userId,
    );
    // client.emit('currentSongStatusChanged', data.status);
    this.server.in(data.roomId).emit('currentSongStatusChanged', data.status);
  }

  @SubscribeMessage('addSongToWaitingList')
  async handleAddSongToWaitingList(
    client: Socket,
    data: addSongToWaitingListDto,
  ) {
    const res = await this.roomSocketService.addSongToWaitingList(
      data.roomId,
      client.data.userId,
      data.name,
      data.url,
      data.image,
      data.author,
    );
    if (res == true) {
      this.server.in(data.roomId).emit('userAddedSong', {
        name: data.name,
        image: data.image,
        url: data.url,
        author: data.author,
        grade: [{ note: 1, fromId: client.data.userId }],
      });
    }
  }

  @SubscribeMessage('voteSong')
  async handleVoteSong(client: Socket, data: VoteSongDto) {
    const res = await this.roomSocketService.handleVotetoSong(
      data.roomId,
      client.data.userId,
      data.name,
      data.author,
      data.note,
    );
    if (res.index >= 0) {
      // client.emit('userVoteSong', {
      //   index: res.index,
      //   indexVote: res.voteIndex,
      //   note: data.note,
      //   fromId: client.data.userId,
      // });
      this.server.in(data.roomId).emit('userVoteSong', {
        index: res.index,
        indexVote: res.voteIndex,
        note: data.note,
        fromId: client.data.userId,
      });
    }
  }

  @SubscribeMessage('updateCurrentSongTime')
  async handleTimeSong(client: Socket, data: UpdateCurrentSongTimeDto) {
    await this.roomSocketService.updateCurrentSongTime(
      data.roomId,
      client.data.userId,
      data.time,
    );
    // client.emit('currentSongTimeChanged', data.time);
    this.server.in(data.roomId).emit('currentSongTimeChanged', data.time);
  }

  @SubscribeMessage('updateCurrentSong')
  async handleUpdateCurrentSong(client: Socket, data: UpdateCurrentSongDto) {
    const res = await this.roomSocketService.updateCurrentSong(
      data.roomId,
      client.data.userId,
      data.name,
      data.url,
      data.image,
      data.author,
    );

    if (res != null) {
      // client.emit('currentSongChanged', res);
      this.server.in(data.roomId).emit('currentSongChanged', res);
    }
  }
  @SubscribeMessage('joinRoom')
  handleJoinRoom(client: Socket, data: JoinRoomSocketDto) {
    client.join(data.roomId);
    this.server.to(data.roomId).emit('userJoinedRoom', {
      id: client.data.userId,
      pseudo: data.pseudo,
      role: data.role,
      isInvited: data.isInvited,
    });
  }

  @SubscribeMessage('leaveRoom')
  async handleLeaveRoom(client: Socket, room: string) {
    await this.socketService.leave(room, client.data.userId);
    client.leave(room);
    this.server.to(room).emit('userLeavedRoom', { userId: client.data.userId });
  }

  @SubscribeMessage('updateRightLicense')
  handleUpdateRightLicense(client: Socket, data: UpdateRightLicenseDto) {
    this.server.in(data.roomId).emit('rightLicenseUpdated', data);
  }

  @SubscribeMessage('updateInvitationCode')
  handleUpdateInvitationCode(client: Socket, data: UpdateInvitationCodeDto) {
    this.server
      .in(data.roomId)
      .emit('invitationCodeUpdated', data.invitationCode);
  }

  @SubscribeMessage('updateRoleUser')
  handleUpdateRoleUser(client: Socket, data: UpdateRoleUserDto) {
    this.server.in(data.roomId).emit('roleUserUpdated', {
      userId: data.userId,
      role: data.role,
    });
  }
}

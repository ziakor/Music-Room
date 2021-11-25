import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Req,
} from '@nestjs/common';
import { AuthGuard } from 'src/auth/auth.guard';
import { JoinInvitedPlaylistDto } from './dto/join-invited-playlist.dto';
import { JoinPlaylistDto } from './dto/join-playlist.dto';
import { LeavePlaylistDto } from './dto/leave-playlist.dto';
import { PlaylistService } from './playlist.service';
import { Request } from 'express';
import { ApiHeader, ApiResponse, ApiTags } from '@nestjs/swagger';

@Controller('playlist')
@ApiTags('playlist')
@UseGuards(AuthGuard)
export class PlaylistController {
  constructor(private readonly playlistService: PlaylistService) {}

  @ApiHeader({
    name: 'authorization',
    description: 'authorization token',
  })
  @ApiResponse({ status: 200, description: 'join public playlist' })
  @ApiResponse({ status: 403, description: 'Forbidden.' })
  @Post('join/:playlistId')
  join(
    @Req() request: Request,
    @Body() data: JoinPlaylistDto,
    @Param('playlistId') playlistId: string,
  ) {
    return this.playlistService.join(data, playlistId, request['uid']);
  }

  @ApiHeader({
    name: 'authorization',
    description: 'authorization token',
  })
  @ApiResponse({
    status: 200,
    description: 'join  playlist with invitation code',
  })
  @ApiResponse({ status: 403, description: 'Forbidden.' })
  @Post('joinInvited')
  joinInvited(@Req() request: Request, @Body() data: JoinInvitedPlaylistDto) {
    return this.playlistService.joinInvited(data, request['uid']);
  }

  @ApiHeader({
    name: 'authorization',
    description: 'authorization token',
  })
  @ApiResponse({ status: 200, description: 'leave playlist' })
  @ApiResponse({ status: 403, description: 'Forbidden.' })
  @Post('leave/:playlistId')
  leave(@Param('playlistId') playlistId: string, @Req() request: Request) {
    return this.playlistService.leave(playlistId, request['uid']);
  }
}

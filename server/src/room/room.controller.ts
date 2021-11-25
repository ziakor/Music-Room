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
import { RoomService } from './room.service';
import { AuthGuard } from 'src/auth/auth.guard';
import { JoinRoomDto } from './dto/join-room.dto';
import { LeaveRoomDto } from './dto/leave-room.dto';
import { JoinInvitedRoomDto } from './dto/join-invited-room.dto';
import { Request } from 'express';
import { ApiHeader, ApiResponse, ApiTags } from '@nestjs/swagger';

@Controller('rooms')
@ApiTags('room')
@UseGuards(AuthGuard)
export class RoomController {
  constructor(private readonly roomService: RoomService) {}

  @ApiHeader({
    name: 'authorization',
    description: 'authorization token',
  })
  @ApiResponse({ status: 200, description: 'join public room' })
  @ApiResponse({ status: 403, description: 'Forbidden.' })
  @Post('join/:roomId')
  join(
    @Req() request: Request,
    @Body() data: JoinRoomDto,
    @Param('roomId') roomId: string,
  ) {
    return this.roomService.join(data, roomId, request['uid']);
  }

  @ApiHeader({
    name: 'authorization',
    description: 'authorization token',
  })
  @ApiResponse({ status: 200, description: 'join room with invitation code' })
  @ApiResponse({ status: 403, description: 'Forbidden.' })
  @Post('joinInvited')
  joinInvited(@Req() request: Request, @Body() data: JoinInvitedRoomDto) {
    return this.roomService.joinInvited(data, request['uid']);
  }

  @ApiHeader({
    name: 'authorization',
    description: 'authorization token',
  })
  @ApiResponse({ status: 200, description: 'leave room' })
  @ApiResponse({ status: 403, description: 'Forbidden.' })
  @Post('leave/:roomId')
  leave(@Req() request: Request, @Param('roomId') roomId: string) {
    return this.roomService.leave(roomId, request['uid']);
  }
}

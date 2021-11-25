import { ApiProperty } from '@nestjs/swagger';
import { IsEmpty, IsNotEmpty, IsString } from 'class-validator';

export class JoinInvitedPlaylistDto {
  @IsNotEmpty()
  @IsString()
  @ApiProperty()
  pseudo: string;

  @IsNotEmpty()
  @IsString()
  @ApiProperty()
  invitationCode: string;
}

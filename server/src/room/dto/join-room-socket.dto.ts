import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsNotEmpty, IsString } from 'class-validator';

export class JoinRoomSocketDto {
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  roomId: string;
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  pseudo: string;
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  role: string;
  @IsBoolean()
  @ApiProperty()
  isInvited: boolean;
}

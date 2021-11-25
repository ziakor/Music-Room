import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsNotEmpty, IsString } from 'class-validator';

export class UpdateCurrentSongStatusDto {
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  roomId: string;

  @IsBoolean()
  @ApiProperty()
  status: boolean;
}

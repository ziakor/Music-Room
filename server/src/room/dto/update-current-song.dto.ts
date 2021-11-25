import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class UpdateCurrentSongDto {
  @IsString()
  @ApiProperty()
  name: string;
  @ApiProperty()
  @IsString()
  image: string;
  @IsString()
  @ApiProperty()
  url: string;
  @IsString()
  @ApiProperty()
  author: string;
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  roomId: string;
}

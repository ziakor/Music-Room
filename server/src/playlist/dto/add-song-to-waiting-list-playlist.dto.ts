import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class addSongToWaitingListPlaylistDto {
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  name: string;
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  image: string;
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  url: string;
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  author: string;
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  playlistId: string;
}

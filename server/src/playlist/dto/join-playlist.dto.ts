import { ApiProperty } from '@nestjs/swagger';
import { IsEmpty, IsNotEmpty, IsString } from 'class-validator';

export class JoinPlaylistDto {
  @IsNotEmpty()
  @IsString()
  @ApiProperty()
  pseudo: string;
}

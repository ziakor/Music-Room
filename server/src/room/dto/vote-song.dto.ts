import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsNumber, IsString, Max, Min } from 'class-validator';

export class VoteSongDto {
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  name: string;
  @IsNumber()
  @Min(-1)
  @Max(1)
  @ApiProperty()
  note: number;
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  author: string;
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  roomId: string;
}

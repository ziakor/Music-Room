import { ApiProperty } from '@nestjs/swagger';
import { IsInt, IsNotEmpty, IsString, Max, Min } from 'class-validator';

export class UpdateCurrentSongTimeDto {
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  roomId: string;

  @IsInt()
  @Min(0)
  @Max(30)
  @ApiProperty()
  time: number;
}

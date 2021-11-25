import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class RemoveFriendsDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  friendId: string;
}

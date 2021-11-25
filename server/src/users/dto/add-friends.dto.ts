import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class AddFriendsDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  friendId: string;
}

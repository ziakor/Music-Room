import { ApiProperty } from '@nestjs/swagger';
import { IsIn, IsNotEmpty, IsString } from 'class-validator';

const role: string[] = ['Modo', 'User'];
export class UpdateRoleUserDto {
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  roomId: string;

  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  userId: string;

  @IsString()
  @IsNotEmpty()
  @IsIn(role)
  @ApiProperty()
  role: string;
}

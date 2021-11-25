import { ApiProperty } from '@nestjs/swagger';
import { IsString } from 'class-validator';

export class ResetPasswordDto {
  @IsString()
  @IsString()
  @ApiProperty()
  password: string;
  @IsString()
  @IsString()
  @ApiProperty()
  email: string;
}

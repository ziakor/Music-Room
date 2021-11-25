import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class CodeQueryDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  email: string;
}

import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class LogDto {
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  platform: string;
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  device: string;
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  application_version: string;
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  message: string;
}

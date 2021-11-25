import { Type } from 'class-transformer';
import { IsEmail, IsInt, IsNotEmpty, IsNumber, IsString, Min } from 'class-validator';

export class SearchSongDto {
  @IsNotEmpty()
  @IsString()
  name: string; 
  }
  
import { ApiProperty } from '@nestjs/swagger';
import {
  IsNumber,
  IsLatitude,
  IsBoolean,
  IsString,
  IsNotEmpty,
  Min,
  Max,
} from 'class-validator';

export class UpdateRightLicensePlaylistDto {
  @IsBoolean()
  @ApiProperty()
  onlyInvitedEnabled: boolean;

  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  playlistId: string;
}

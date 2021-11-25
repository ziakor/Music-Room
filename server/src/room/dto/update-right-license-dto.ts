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

export class UpdateRightLicenseDto {
  @IsNumber()
  @Min(-90)
  @Max(90)
  @ApiProperty()
  locationLatitude: number;
  @IsNumber()
  @Min(-90)
  @Max(90)
  @ApiProperty()
  locationLongitude: number;
  @IsNumber()
  @Min(0)
  @ApiProperty()
  timeStart: number;
  @IsNumber()
  @Min(0)
  @ApiProperty()
  timeEnd: number;
  @IsBoolean()
  @ApiProperty()
  onlyInvitedEnabled: boolean;
  @IsBoolean()
  @ApiProperty()
  locationEnabled: boolean;
  @IsBoolean()
  @ApiProperty()
  timeEnabled: boolean;
  @IsString()
  @IsNotEmpty()
  @ApiProperty()
  roomId: string;
}

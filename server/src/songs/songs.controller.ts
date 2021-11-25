import { Song } from './dto/song.dto';
import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  UsePipes,
  ValidationPipe,
  UseGuards,
  SetMetadata,
} from '@nestjs/common';
import { SearchSongReturn, SongsService } from './songs.service';
import { SearchSongDto } from './dto/search-song.dto';
import { AuthGuard } from 'src/auth/auth.guard';
import { Auth } from 'src/auth/auth.decorator';
import { ApiOkResponse, ApiTags } from '@nestjs/swagger';

@Controller('songs')
@ApiTags('songs')
// @UseGuards(AuthGuard)
export class SongsController {
  constructor(private readonly songsService: SongsService) {}

  @ApiOkResponse({ description: 'list of tracks finded' })
  @Get('/search?')
  @UsePipes(new ValidationPipe({ whitelist: false, transform: true }))
  async search(@Query() dto: SearchSongDto): Promise<SearchSongReturn> {
    return await this.songsService.search(dto.name);
  }
}

import { Body, Controller, Post } from '@nestjs/common';
import { ApiResponse, ApiTags } from '@nestjs/swagger';
import { LogDto } from './dto/log.dto';
import { LogService } from './log.service';

@Controller('log')
@ApiTags('log')
export class LogController {
  constructor(private readonly logService: LogService) {}
  @Post()
  @ApiResponse({
    status: 200,
    description: 'log added with success',
  })
  resetForgetPassword(@Body() data: LogDto) {
    return this.logService.addLog(data);
  }
}

import { Injectable } from '@nestjs/common';
import { LogDto } from './dto/log.dto';
const fs = require('fs');
@Injectable()
export class LogService {
  addLog(data: LogDto) {
    fs.writeFile(
      './src/log/log.txt',
      `${Date.now()} ${data.platform} ${data.device} ${
        data.application_version
      } ${data.message}\n`,
      { flag: 'a+' },
      (err) => {},
    );
  }
}

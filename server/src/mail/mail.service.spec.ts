import { MailerService } from '@nestjs-modules/mailer/dist/mailer.service';
import { HandlebarsAdapter } from '@nestjs-modules/mailer/dist/adapters/handlebars.adapter';
import { Test, TestingModule } from '@nestjs/testing';
import { join } from 'path';
import { MailService } from './mail.service';
jest.mock('@nestjs-modules/mailer/dist/mailer.service');

describe('MailService', () => {
  let service: MailService;
  let mailer;
  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [MailService, MailerService],
    }).compile();
    service = module.get<MailService>(MailService);
    mailer = module.get<MailerService>(MailerService);
  });
  afterAll(() => {
    jest.resetAllMocks();
  });

  it('should be defined', async () => {
    expect(service).toBeDefined();
  });
  it('should not throw', async () => {
    jest.spyOn(mailer, 'sendMail').mockResolvedValue(null);
    await expect(
      service.sendEmail(
        'dimitrihauet@gmail.com',
        '123ds',
        './forgotPasswordCode',
        { name: '', code: '123ds' },
        'Forgot your password ?',
      ),
    ).resolves.not.toThrow();
  });
  it('should throw', async () => {
    jest
      .spyOn(mailer, 'sendMail')
      .mockRejectedValue(Error('Server error, try again.'));
    await expect(
      service.sendEmail(
        'dimitrihauet@gmail.com',
        '123ds',
        './forgotPasswordCode',
        { name: '', code: '123ds' },
        'Forgot your password ?',
      ),
    ).rejects.toThrow(Error('Server error, try again.'));
  });
});

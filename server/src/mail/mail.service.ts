import { MailerService } from '@nestjs-modules/mailer';
import { Injectable } from '@nestjs/common';

@Injectable()
export class MailService {
  constructor(private mailerService: MailerService) {}

  async sendEmail(
    email: string,
    token: string,
    template: string,
    context: any,
    subject: string,
  ) {
    try {
      await this.mailerService.sendMail({
        to: email,
        from: 'support@example.com',
        subject: subject,
        template: template, // `.hbs` extension is appended automatically
        context: context,
      });
    } catch (error) {
      console.log(error);
      throw new Error('Server error, try again.');
    }
  }
}

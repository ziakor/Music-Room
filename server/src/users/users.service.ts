import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { log, timeStamp } from 'console';
import { FirebaseService } from 'src/firebase/firebase.service';
import { MailService } from 'src/mail/mail.service';
import { generateString } from 'src/utils/function';
import { validatePassword } from 'src/utils/validation';
import * as admin from 'firebase-admin/lib/auth/index';
import { ApiSuccessReturn } from 'src/entities/apiSuccesReturn';

@Injectable()
export class UsersService {
  constructor(
    private readonly firebaseService: FirebaseService,
    private readonly mailService: MailService,
  ) {}
  async findAll() {
    try {
      const res = await this.firebaseService.getAllUsers();
      return res.map((doc) => ({ pseudo: doc.pseudo, id: doc.id }));
    } catch (error) {
      throw new HttpException(error, HttpStatus.FORBIDDEN);
    }
  }
  async find(id: string, userId: string) {
    try {
      const res = await this.firebaseService.getFirestoreData(id, 'Users');

      if (res['friends'].includes(userId)) {
        return {
          pseudo: res['pseudo'],
          bio: res['bio'],
          friends: res['friends'],
          birth: res['birth'],
          gender: res['gender'],
        };
      } else {
        return {
          pseudo: res['pseudo'],
          bio: res['bio'],
          friends: res['friends'],
        };
      }
    } catch (error) {
      throw new HttpException(error, HttpStatus.FORBIDDEN);
    }
  }

  async forgetPassword(email: string): Promise<ApiSuccessReturn> {
    const code = generateString(8);
    try {
      const user = await this.firebaseService.getAuthUserWithEmail(email);

      await this.firebaseService.updateFirestoreUser(user.uid, { code: code });

      await this.mailService.sendEmail(
        email,
        code,
        './forgotPasswordCode',
        { name: '', code: code },
        'Forgot your password ?',
      );
      console.log({ message: 'code generated', data: {} });
      return { message: 'code generated', data: {} };
    } catch (error) {
      console.log('ERROR');
      console.log(error);

      throw new HttpException(error, HttpStatus.FORBIDDEN);
    }
  }

  async forgetPasswordCode(
    email: string,
    code: string,
    password: string,
  ): Promise<ApiSuccessReturn> {
    try {
      if (!validatePassword(password))
        throw new Error("This password doesn't fill all requirements.");

      const user = await this.firebaseService.getAuthUserWithEmail(email);
      const data = await this.firebaseService.getFirebaseUserData(user.uid);
      if (data['code'] != code) throw new Error('Invalid code.');
      await this.firebaseService.updateFirestoreUser(user.uid, { code: '' });
      await this.firebaseService.updateAuthUser(user.uid, {
        password: password,
      });
      this.mailService.sendEmail(
        email,
        code,
        './resetPassword',
        { name: '' },
        'Your password has been changed!',
      );
      return { message: 'password updated', data: {} };
    } catch (error) {
      throw new HttpException(error.message, HttpStatus.FORBIDDEN);
    }
  }

  async addFriend(userId: string, friendId: string) {
    try {
      const res = await this.firebaseService.getFirestoreData(userId, 'Users');

      let index: number = res['friends'].indexOf(friendId);
      if (index == -1) {
        res['friends'].push(friendId);
        await this.firebaseService.updateFirestoreUser(userId, {
          friends: res['friends'],
        });
      }
      return { res };
    } catch (error) {
      throw new HttpException(error.message, HttpStatus.FORBIDDEN);
    }
  }

  async removeFriend(userId: string, friendId: string) {
    try {
      const res = await this.firebaseService.getFirestoreData(userId, 'Users');

      let index: number = res['friends'].indexOf(friendId);
      if (index != -1) {
        res['friends'].splice(index, 1);
        await this.firebaseService.updateFirestoreUser(userId, {
          friends: res['friends'],
        });
      }

      return {};
    } catch (error) {
      throw new HttpException(error.message, HttpStatus.FORBIDDEN);
    }
  }
}

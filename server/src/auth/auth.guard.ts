import {
  CanActivate,
  ExecutionContext,
  HttpException,
  Injectable,
  Module,
  HttpStatus,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Observable } from 'rxjs';
import { Socket } from 'socket.io';
import { FirebaseModule } from 'src/firebase/firebase.module';
import { FirebaseService } from 'src/firebase/firebase.service';

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(
    private readonly firebaseService: FirebaseService,
    private readonly reflector: Reflector,
  ) {}

  canActivate(
    context: ExecutionContext,
  ): boolean | Promise<boolean> | Observable<boolean> {
    if (context['contextType'] == 'ws') {
      const client: Socket = context.switchToWs().getClient<Socket>();
      if (process.env.benchmark == 'true') {
        client.data['userId'] = '123';
        return true;
      }
      const authToken = context['args'][0].handshake.headers['authorization'];
      if (authToken == undefined || authToken.length == 0) return false;
      return this.firebaseService
        .verifyIdToken(authToken)
        .then((res) => {
          if (res.length == 0) return false;
          client.data['userId'] = res;
          return true;
        })
        .catch(() => {
          client.data['userId'] = '';
          return false;
        });
    } else {
      const request = context.switchToHttp().getRequest();
      const authToken = request.headers['authorization'];

      if (authToken == undefined) return false;
      return this.firebaseService
        .verifyIdToken(authToken)
        .then((res) => {
          if (res.length == 0) return false;
          request.uid = res;
          return true;
        })
        .catch(() => {
          return false;
        });
    }
  }
}

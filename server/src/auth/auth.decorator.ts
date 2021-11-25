import { SetMetadata } from '@nestjs/common';

export const Auth = (token: string) => SetMetadata('token', token);

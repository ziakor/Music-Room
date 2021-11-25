import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  UseGuards,
  Req,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { FirebaseService } from 'src/firebase/firebase.service';
import { MailService } from 'src/mail/mail.service';
import { CodeQueryDto } from './dto/code-query-dto';
import { ResetPasswordDto } from './dto/reset-password-dto';
import { ApiSuccessReturn } from 'src/entities/apiSuccesReturn';
import { AuthGuard } from 'src/auth/auth.guard';
import { Request } from 'express';
import { AddFriendsDto } from './dto/add-friends.dto';
import {
  ApiHeader,
  ApiOkResponse,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
@Controller('users')
@ApiTags('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @ApiResponse({
    status: 200,
    description: 'list of users successfully retrieve',
  })
  @Get()
  findAll() {
    return this.usersService.findAll();
  }
  @UseGuards(AuthGuard)
  @ApiHeader({
    name: 'authorization',
    description: 'authorization token',
  })
  @ApiResponse({ status: 200, description: 'User find with success.' })
  @ApiResponse({ status: 403, description: 'Forbidden.' })
  @Get('/:id')
  find(@Param('id') id: string, @Req() request: Request) {
    return this.usersService.find(id, request['uid']);
  }

  @ApiOkResponse({ description: 'reset password send with success.' })
  @Post('/forgetPassword')
  resetForgetPassword(@Body() data: CodeQueryDto): Promise<ApiSuccessReturn> {
    console.log('SALSIFI PASSWORD FORGET');
    return this.usersService.forgetPassword(data.email);
  }

  @ApiResponse({
    status: 200,
    description: 'password updated with success',
  })
  @Post('/forgetPassword/:code')
  resetForgetPasswordWithCode(
    @Body() data: ResetPasswordDto,
    @Param('code') code: string,
  ): Promise<ApiSuccessReturn> {
    return this.usersService.forgetPasswordCode(
      data.email,
      code,
      data.password,
    );
  }

  @ApiResponse({
    status: 200,
    description: 'user added to the friend list',
  })
  @ApiHeader({
    name: 'authorization',
    description: 'authorization token',
  })
  @UseGuards(AuthGuard)
  @Post('/addFriend')
  AddFriend(@Body() data: AddFriendsDto, @Req() request: Request) {
    return this.usersService.addFriend(request['uid'], data.friendId);
  }

  @ApiResponse({
    status: 200,
    description: 'user removed of the friend list',
  })
  @Post('/removeFriend')
  @ApiHeader({
    name: 'authorization',
    description: 'authorization token',
  })
  @UseGuards(AuthGuard)
  RemoveFriend(@Body() data: AddFriendsDto, @Req() request: Request) {
    return this.usersService.removeFriend(request['uid'], data.friendId);
  }
}

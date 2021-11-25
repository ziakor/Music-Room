import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:music_room/src/data/repository/user_repository.dart';
import 'package:music_room/src/data/service/api_service.dart';

part 'forgetpassword_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  final UserRepository repository;

  ForgetPasswordCubit(this.repository) : super(ForgetPasswordInitial());

  void sendEmailCode(String email) async {
    try {
      await repository.resetPasswordCode(email);
      emit(ForgetPasswordSendCodeMail(true, ""));
    } on ApiServerError catch (e) {
      emit(ForgetPasswordError(e.message));
    } catch (e) {
      print(e);
      emit(ForgetPasswordError("Internal server error"));
    }
  }

  void updatePasswordWithCode(
      String code, String password, String email) async {
    try {
      await repository.resetPassword(email, password, code);
      emit(ForgetPasswordUpdateWithCode(true, ""));
    } on ApiServerError catch (e) {
      emit(ForgetPasswordError(e.message));
    } catch (e) {
      emit(ForgetPasswordError("Internal server error"));
    }
  }
}

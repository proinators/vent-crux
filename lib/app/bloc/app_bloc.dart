import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:vent/src/src.dart';
import 'package:fluttertoast/fluttertoast.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({required AuthenticationService authService})
      : _authService = authService,
        super(AppState.initial()) {
    on<AppInitial>(_onInit);
    on<_AppUserChanged>(_onUserChanged);
    on<AppLogoutRequested>(_onLogoutRequested);
    _userSubscription = _authService.user.listen(
          (user) {
        add(_AppUserChanged(user));
      },
    );
  }

  final AuthenticationService _authService;
  late final StreamSubscription<UserModel> _userSubscription;

  void _onInit(AppInitial event, Emitter<AppState> emit) async {
    final userModel = await _authService.currentUser;
    emit(
      userModel.isNotEmpty
          ? AppState.authenticated(userModel)
          : const AppState.unauthenticated(),
    );
  }

  void _onUserChanged(_AppUserChanged event, Emitter<AppState> emit) {
    emit(
      event.userModel.isNotEmpty
          ? AppState.authenticated(event.userModel)
          : const AppState.unauthenticated(),
    );
  }

  void _onLogoutRequested(AppLogoutRequested event, Emitter<AppState> emit) {
    unawaited(_authService.logOut((exception) {
      log("Logout failed with exception: $exception");
      Fluttertoast.showToast(msg: "Logout failed");
    }));
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}

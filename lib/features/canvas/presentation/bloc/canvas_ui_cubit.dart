import 'package:flutter_bloc/flutter_bloc.dart';

class CanvasUiState {
  final bool showChat;
  final bool isSidebarOpen;

  const CanvasUiState({
    this.showChat = false,
    this.isSidebarOpen = true,
  });

  CanvasUiState copyWith({
    bool? showChat,
    bool? isSidebarOpen,
  }) {
    return CanvasUiState(
      showChat: showChat ?? this.showChat,
      isSidebarOpen: isSidebarOpen ?? this.isSidebarOpen,
    );
  }
}

class CanvasUiCubit extends Cubit<CanvasUiState> {
  CanvasUiCubit() : super(const CanvasUiState());

  void toggleChat() {
    emit(state.copyWith(showChat: !state.showChat));
  }

  void toggleSidebar() {
    emit(state.copyWith(isSidebarOpen: !state.isSidebarOpen));
  }

  void setSidebarOpen(bool isOpen) {
    emit(state.copyWith(isSidebarOpen: isOpen));
  }
}

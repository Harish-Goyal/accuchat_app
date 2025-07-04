


/*class ChatService {
  late IO.Socket socket;

  String backendSocketUrl = 'http://192.168.1.112:3000';

  void initSocket() {
    try {
      if (socket.connected??false)
      {

        socket.destroy();
      }

    } catch (e) {}

    print('Connecting to chat service');
    socket = IO.io(backendSocketUrl, {
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
    socket.onConnect((_) {
      debugPrint('Connected to Socket.IO server');
    });
    socket.onDisconnect((_) {
      debugPrint('Disconnected from Socket.IO server');
    });
    socket.onError((error) {
      debugPrint('Socket error: $error');
    });
  }

  void connectUserEmitter() {
    socket.emit('connect_user', {'user_id': storage.read(userId)});
  }
  void sendMessage({required String senderId, required String receiverId, required String message}) {
    socket.emit('send_message', {'sender_id': senderId,'receiver_id':receiverId,'message':message});
  }

  void onNewMessage(Function(dynamic) callback) {
    socket.on('new_message', callback);
  }

  void dispose() {
    socket.disconnect();
  }
}*/





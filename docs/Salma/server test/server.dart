import 'dart:io';

void main() async {
  var server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('MyAUC Server is LIVE at http://${server.address.address}:${server.port}');

  await for (HttpRequest request in server) {
    // This part checks the URL path
    if (request.uri.path == '/map') {
      request.response
        ..write('Map Data: AUC New Cairo - Floor 1 Loaded.')
        ..close();
    } else if (request.uri.path == '/status') {
      request.response
        ..write('The MyAUC Server is Awake and Healthy!')
        ..close();
    } else {
      request.response
        ..write('Welcome to the MyAUC Backend. Use /map or /status to get data.')
        ..close();
    }
  }
}
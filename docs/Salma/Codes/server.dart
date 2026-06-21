cd C:\Users\qaise\my_auc\backend\server.dart

  import 'dart:io';

void main() async {
  var server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('MyAUC Server is LIVE at http://192.168.8.160:8080');

  await for (HttpRequest request in server) {
    request.response.headers.add('Access-Control-Allow-Origin', '*');

    if (request.uri.path == '/getmapimage') {
      // Look for the campus map file inside the backend folder
      var imageFile = File('auc-new-cairo-campus-map.jpg');
      
      if (await imageFile.exists()) {
        request.response.headers.add('Content-Type', 'image/jpeg');
        await imageFile.openRead().pipe(request.response);
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.write('Image file not found on server.');
        await request.response.close();
      }
    } 
    else if (request.uri.path == '/map') {
      request.response.headers.add('Content-Type', 'text/plain; charset=utf-8');
      var chosenRoom = request.uri.queryParameters['destination'] ?? 'Unknown Room';
      
      if (chosenRoom == 'Electronics Lab 1') {
        request.response.write('📍 Route: Walk 10 meters straight, then turn LEFT into Electronics Lab 1.');
      } else if (chosenRoom == 'Embedded Systems Lab') {
        request.response.write('📍 Route: Walk 25 meters straight down the hallway. It is on your LEFT side.');
      } else if (chosenRoom == 'Microprocessors Lab') {
        request.response.write('📍 Route: Walk 40 meters straight to the end of the wing. It is on your LEFT.');
      } else if (chosenRoom == 'Professor Office 101') {
        request.response.write('📍 Route: Walk 15 meters straight. Look toward your RIGHT side for Room 101.');
      } else if (chosenRoom == 'Department Head Office') {
        request.response.write('📍 Route: Turn RIGHT immediately at the entrance gateway to find the Head Office.');
      } else {
        request.response.write('📍 Connected to server, but please select a valid room from the list!');
      }
      await request.response.close();
    } else {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
    }
  }
}

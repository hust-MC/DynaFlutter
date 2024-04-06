import 'dart:io';

const int version = 3;

Future<void> main() async {

  final server = await HttpServer.bind('192.168.10.3', 8080);
  print('Server listening on ${server.address}:${server.port}');

  await for (HttpRequest request in server) {
    print('Receive method: ${request.method}; path: ${request.uri.path}');

    if (request.method == 'GET') {
      switch (request.uri.path) {
        case '/patch':
          final File file = File('lib/server/dyna.json'); // 补丁文件的路径
          if (await file.exists()) {
            request.response.headers.contentType = ContentType('application', 'zip');
            request.response.headers.set('Content-Disposition', 'attachment; filename="patch.zip"');
            await file.openRead().pipe(request.response);
          } else {
            request.response.statusCode = HttpStatus.notFound;
            request.response.write('File not found');
          }
          break;
        case '/version':
          request.response.write(version);
          break;
        default:
          request.response.statusCode = HttpStatus.notFound;
          request.response.write('Path Not Found');
          break;
      }
    }
    await request.response.close();
  }
}

/// PoloClient
library polo_client;

export 'src/polo_client_stub.dart'
    if (dart.library.io) 'src/polo_io_client_helper.dart'
    if (dart.library.html) 'src/polo_web_client_helper.dart';

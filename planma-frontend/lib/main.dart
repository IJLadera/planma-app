import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:planma_app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // Testing: Access the base URL
  // String apiUrl = Config().baseApiUrl;
  // print(apiUrl);
  
  runApp(MyApp());
}
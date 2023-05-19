import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repo_viewer/core/infrastructure/sembast_database.dart';

final dioProvider = Provider((ref) => Dio());
final semblastProvider = Provider((ref) => SembastDatabase());


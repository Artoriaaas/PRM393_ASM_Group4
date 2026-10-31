import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const developmentUiEnabled = kDebugMode;
final developmentUiProvider = Provider<bool>((ref) => developmentUiEnabled);

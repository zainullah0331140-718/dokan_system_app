import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();

String newId() => uuid.v4();

import 'package:sloth/src/rust/api/metadata.dart';

typedef ReplyPreview = ({
  String authorPubkey,
  FlutterMetadata? authorMetadata,
  String content,
  bool isNotFound,
});

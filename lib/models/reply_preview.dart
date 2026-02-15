// coverage:ignore-file
import 'package:whitenoise/src/rust/api/metadata.dart';

typedef ReplyPreview = ({
  String messageId,
  String authorPubkey,
  FlutterMetadata? authorMetadata,
  String content,
  bool hasMedia,
  bool isNotFound,
});

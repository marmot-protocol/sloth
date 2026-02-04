import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sloth/widgets/wn_system_notice.dart';

({
  String? noticeMessage,
  WnSystemNoticeType noticeType,
  void Function(String noticeMessage) showErrorNotice,
  void Function(String noticeMessage) showSuccessNotice,
  void Function() dismissNotice,
})
useSystemNotice() {
  final message = useState<String?>(null);
  final typeState = useState(WnSystemNoticeType.success);

  void showNotice({required String msg, required WnSystemNoticeType type}) {
    message.value = msg;
    typeState.value = type;
  }

  void showSuccessNotice(String msg) {
    showNotice(msg: msg, type: WnSystemNoticeType.success);
  }

  void showErrorNotice(String msg) {
    showNotice(msg: msg, type: WnSystemNoticeType.error);
  }

  void dismissNotice() {
    message.value = null;
  }

  return (
    noticeMessage: message.value,
    noticeType: typeState.value,
    showSuccessNotice: showSuccessNotice,
    showErrorNotice: showErrorNotice,
    dismissNotice: dismissNotice,
  );
}

import 'package:sloth/src/rust/api/accounts.dart';

class MockRelayType implements RelayType {
  final String type;
  MockRelayType(this.type);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

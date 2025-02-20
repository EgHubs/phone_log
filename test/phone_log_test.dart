import 'dart:async';

import 'package:fixnum/fixnum.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:phone_log/phone_log.dart';

void main() {
  String? invokedMethod;
  dynamic arguments;
  MockPlatformChannel? mockChannel;
  MockPlatformChannel? mockChannelForGetLogs;

  setUp(() {
    mockChannel = new MockPlatformChannel();
    mockChannelForGetLogs = new MockPlatformChannel();

    when(mockChannel!.invokeMethod(any!, any))
        .thenAnswer((Invocation invocation) {
      invokedMethod = invocation.positionalArguments[0];
      arguments = invocation.positionalArguments[1];
      return;
    } as Future<dynamic> Function(Invocation));

    when(mockChannelForGetLogs!.invokeMethod('getPhoneLogs', any))
        .thenAnswer((_) => new Future(() => [
              {
                'formattedNumber': '123 123 1234',
                'number': '1231231234',
                'callType': 'INCOMING_TYPE',
                'dateYear': 2018,
                'dateMonth': 6,
                'dateDay': 15,
                'dateHour': 3,
                'dateMinute': 16,
                'dateSecond': 23,
                'duration': 123
              }
            ]));
  });

  group('Phone log plugin', () {
    test('fetch phone log', () async {
      var phoneLog = new PhoneLog.private(mockChannelForGetLogs);

      var records = await (phoneLog.getPhoneLogs(
          startDate: new Int64(123456789), duration: new Int64(12)) as FutureOr<Iterable<CallRecord>>);

      print(records);
      var record = records.first;

      expect(record.formattedNumber, '123 123 1234');
      expect(record.callType, 'INCOMING_TYPE');
      expect(record.number, '1231231234');
      expect(record.date.runtimeType, DateTime);
      expect(record.duration, 123);

      var phoneLogMethod = new PhoneLog.private(mockChannel);
      await phoneLogMethod.getPhoneLogs(
          startDate: new Int64(123456789), duration: new Int64(12));
      expect(invokedMethod, 'getPhoneLogs');
      expect(arguments, {'startDate': '123456789', 'duration': '12'});
    });

    test('check permission', () async {
      var phoneLog = new PhoneLog.private(mockChannel);

      await phoneLog.checkPermission();

      expect(invokedMethod, 'checkPermission');
      expect(arguments, null);
    });

    test('request permission', () async {
      var phoneLog = new PhoneLog.private(mockChannel);

      await phoneLog.requestPermission();

      expect(invokedMethod, 'requestPermission');
      expect(arguments, null);
    });
  });
}

class MockPlatformChannel extends Mock implements MethodChannel {}

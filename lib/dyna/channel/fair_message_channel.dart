/*
 * Copyright (C) 2005-present, 58.com.  All rights reserved.
 * Use of this source code is governed by a BSD type license that can be
 * found in the LICENSE file.
 */

import 'dart:convert';

import 'package:dyna_flutter/dyna/dyna_widget.dart';
import 'package:flutter/services.dart';

typedef VoidMsgCallback = void Function();
typedef StringMsgCallback = String? Function(String? msg);

const jsLoader = 'com.wuba.fair/js_loader';
const commonMessageChannel = 'com.wuba.fair/common_message_channel';
const basicMessageChannel = 'com.wuba.fair/basic_message_channel';

class DynaChannel {

  final BasicMessageChannel<String?> _commonChannel = const BasicMessageChannel<String?>(commonMessageChannel, StringCodec());
  final MethodChannel _methodChannel = const MethodChannel(jsLoader);
  final MethodChannel basicMethodChannel = const MethodChannel(basicMessageChannel);

  factory DynaChannel() {
    return _msg;
  }

  static final DynaChannel _msg = DynaChannel._internal();

  DynaChannel._internal() {
    _initMessageChannel();
  }

  void _initMessageChannel() {
    _commonChannel.setMessageHandler((String? message) async {
      print('来自native端的消息：$message');
      _callback?.call(message);
      return 'reply from dart';
    });

    _methodChannel.setMethodCallHandler((call) async {});
  }

  StringMsgCallback? _callback;

  void setMessageHandler(StringMsgCallback callback) {
    _callback = callback;
  }

  Future<dynamic> loadJS(String args, StringMsgCallback? callback) {
    return _methodChannel.invokeMethod('loadMainJs', args);
  }

  Future<dynamic> release(String args, VoidMsgCallback? callback) {
    return _methodChannel.invokeMethod('releaseMainJs', args);
  }

  Future<String> getVariable(String variable) async {
    var arguments = {
      KEY_PAGE_NAME: PAGE_NAME,
      'type': 'variable',
      'args': {variable: ''}
    };
    return (await _methodChannel.invokeMethod('getVariable', jsonEncode(arguments))).toString();
  }

  Future<dynamic> invokeFunction(String funName) async {
    var arguments = {
      KEY_PAGE_NAME: PAGE_NAME,
      'type': 'method',
      'args':{
        'funcName': funName
      }
    };
    return await _methodChannel.invokeMethod('invokeFunction', jsonEncode(arguments));
  }

  Future<String?> sendCommonMessage(dynamic msg) async {
    return _commonChannel.send(msg);
  }

  dynamic sendCommonMessageSync(dynamic msg) => "OKOK MC";
// FairUtf8.fromUtf8(invokeJSCommonFuncSync.call(FairUtf8.toUtf8(msg)));
}

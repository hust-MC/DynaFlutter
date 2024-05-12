/*
 * Copyright (C) 2005-present, 58.com.  All rights reserved.
 * Use of this source code is governed by a BSD type license that can be
 * found in the LICENSE file.
 */

import 'dart:convert';

import 'package:dyna_flutter/dyna/dyna_widget.dart';
import 'package:flutter/services.dart';

import 'fair_utf8.dart';

typedef VoidMsgCallback = void Function();
typedef StringMsgCallback = String? Function(String? msg);

// final DynamicLibrary dl = Platform.isAndroid
//     ? DynamicLibrary.open('libfairflutter.so')
//     : DynamicLibrary.open('FairDynamicFlutter.framework/FairDynamicFlutter');

final String JS_LOADER = 'com.wuba.fair/js_loader';
final String COMMON_MESSAGE_CHANNEL = 'com.wuba.fair/common_message_channel';
final String BASIC_MESSAGE_CHANNEL = 'com.wuba.fair/basic_message_channel';

class FairMessageChannel {
  // Pointer<Utf8> Function(Pointer<Utf8>) invokeJSCommonFuncSync = dl
  //     .lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Utf8>)>>(
  //         'invokeJSCommonFuncSync')
  //     .asFunction();

  BasicMessageChannel<String?>? _commonChannel;
  MethodChannel? _methodChannel;
  MethodChannel? basicMethodChannel;

  factory FairMessageChannel() {
    return _msg;
  }

  static final FairMessageChannel _msg = FairMessageChannel._internal();

  FairMessageChannel._internal() {
    _initMessageChannel();
  }

  void _initMessageChannel() {
    _commonChannel ??= BasicMessageChannel<String?>(COMMON_MESSAGE_CHANNEL, StringCodec());
    _methodChannel ??= MethodChannel(JS_LOADER);
    basicMethodChannel ??= MethodChannel(BASIC_MESSAGE_CHANNEL);

    _commonChannel!.setMessageHandler((String? message) async {
      print('来自native端的消息：$message');
      //js 异步调用dart中的相关方法
      var data = json.decode(message ?? '');
      var funcName = data['funcName']?.toString();

      // if (funcName == 'invokePlugin') {
      //   var p = await FairPluginDispatcher.dispatch(message);
      //   return p;
      // }

      _callback?.call(message);
      return 'reply from dart';
    });

    _methodChannel!.setMethodCallHandler((call) async {});
  }

  StringMsgCallback? _callback;

  void setMessageHandler(StringMsgCallback callback) {
    _callback = callback;
  }

  Future<dynamic> loadJS(String args, StringMsgCallback? callback) {
    return _methodChannel!.invokeMethod('loadMainJs', args);
  }

  Future<dynamic> release(String args, VoidMsgCallback? callback) {
    return _methodChannel!.invokeMethod('releaseMainJs', args);
  }

  Future<String> getVariable(String variable) async {
    var arguments = {
      KEY_PAGE_NAME: PAGE_NAME,
      'type': 'variable',
      'args': {variable: ''}
    };
    return (await _methodChannel!.invokeMethod('getVariable', jsonEncode(arguments))).toString();
  }

  Future<dynamic> invokeFunction(String funName) async {
    var arguments = {
      KEY_PAGE_NAME: PAGE_NAME,
      'type': 'method',
      'args':{
        'funcName': funName
      }
    };
    return await _methodChannel!.invokeMethod('invokeFunction', jsonEncode(arguments));
  }

  Future<String?> sendCommonMessage(dynamic msg) async {
    return _commonChannel!.send(msg);
  }

  dynamic sendCommonMessageSync(dynamic msg) => "OKOK MC";
// FairUtf8.fromUtf8(invokeJSCommonFuncSync.call(FairUtf8.toUtf8(msg)));
}

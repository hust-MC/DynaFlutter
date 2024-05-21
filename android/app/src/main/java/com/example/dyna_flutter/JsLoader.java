/*
 * Copyright (C) 2005-present, 58.com.  All rights reserved.
 * Use of this source code is governed by a BSD type license that can be
 * found in the LICENSE file.
 */
package com.example.dyna_flutter;


import android.os.Handler;
import android.os.Looper;
import android.os.UserHandle;
import android.util.Log;

import com.eclipsesource.v8.V8Array;

import org.json.JSONObject;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

public class JsLoader {
    /*控制js引擎的加载*/
    public static final String FLUTTER_LOADER_MESSAGE_CHANNEL = "com.wuba.fair/js_loader";
    /*native-js 基础通信*/
    public static final String FLUTTER_COMMON_MESSAGE_CHANNEL = "com.wuba.fair/common_message_channel";

    /*native-js 基础通信*/
    public static final String FLUTTER_BASIC_MESSAGE_CHANNEL = "com.wuba.fair/basic_message_channel";

    public static final String INVOKE_JS_COMMON_FUNC = "invokeJSCommonFunc";

    public static final String JS_INVOKE_FLUTTER_CHANNEL = "jsInvokeFlutterChannel";
    public static final String JS_INVOKE_FLUTTER_CHANNEL_SYNC = "jsInvokeFlutterChannel";
    public static final String SET_DATA = "setState";
    public static final String JS_PRINT_METHOD = "print";

    public static final String LOAD_MAIN_JS = "loadMainJs";
    public static final String RELEASE_MAIN_JS = "releaseMainJs";
    private static final String METHOD_CHANNEL = "com.wuba.fair/js_loader";
    private static final String GET_VARIABLE = "getVariable";
    private static final String INVOKE_FUNCTION = "invokeFunction";
    private MethodChannel methodChannel;

    private JsExecutor jsExecutor = new JsExecutor();
    public JsLoader(BinaryMessenger binaryMessenger) {
//        registerJavaMethods(null);
//        registerJavaClass(null);
        loadMsgChannel(binaryMessenger);
    }

    private void loadMsgChannel(BinaryMessenger binaryMessenger) {
        methodChannel = new MethodChannel(binaryMessenger, FLUTTER_LOADER_MESSAGE_CHANNEL);
        methodChannel.setMethodCallHandler(methodHandler);
    }

    private MethodChannel.MethodCallHandler methodHandler = (call, result) -> {
        Log.e("MCLOG=====", "call.method=" + call.method);
        Log.e("MCLOG=====", "call.arguments=" + call.arguments);

        switch (call.method) {
            case LOAD_MAIN_JS:
                Log.e("MCLOG=====", "LOAD_MAIN_JS");

                Log.e("MCLOG=====", "LOAD_MAIN_JS in run");

                loadMainJs(call.arguments, s -> {
                    ThreadUtils.runOnUI(() -> result.success(s));
                });
                result.success("successful MCMC");

                break;
            case RELEASE_MAIN_JS:
                Log.e("MCLOG=====", "RELEASE_MAIN_JS");
                ThreadUtils.run(() -> {
                    Log.e("MCLOG=====", "RELEASE_MAIN_JS in run");
//                            releaseJsObject(call.arguments);
                });
                result.success("successful MCMC");

                break;
            case GET_VARIABLE:
            case INVOKE_FUNCTION:
                Object funResult = jsExecutor.executeFunction(call.arguments);
                Log.e("MCLOG=====", call.method + ": funResult=" + funResult);

                result.success(funResult);
                break;

            default:
                break;
        }
    };

    public MethodChannel.MethodCallHandler getMethodHandler() {
        return methodHandler;
    }

    public void loadMainJs(Object arguments, JsResultCallback<String> callback) {
        try {
            Log.d("MCLOG====", "用户的js文件地址" + arguments);
            JSONObject jsonObject = new JSONObject(String.valueOf(arguments));
            String jsLocalPath = jsonObject.getString("path");
            String jsName = jsonObject.getString("pageName");
            String result = jsExecutor.executeJs(jsLocalPath);
            Log.d("MCLOG====", "JS执行结果： " + result);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void getVariable(Object args) {
        jsExecutor.executeJs(String.valueOf(args));
    }

    interface JsResultCallback<T> {
        void call(T t);
    }
}



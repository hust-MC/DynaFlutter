package com.example.dyna_flutter;

import android.util.Log;

import com.eclipsesource.v8.V8;
import com.eclipsesource.v8.V8Array;
import com.eclipsesource.v8.V8Object;

public class JsExecutor {
    public static final String TAG = "JsExecutor";
    public static final String INVOKE_JS_FUNC = "invokeJSFunc";

    private final V8 v8;
    JsExecutor() {
        // 初始化 V8 引擎
        V8.setFlags("--expose_gc");
        v8 = V8.createV8Runtime();
        V8Object console = new V8Object(v8);
        v8.add("console", console);
        console.registerJavaMethod((receiver, parameters) -> {
            Log.d(TAG, "Log from JavaScript: " + parameters.get(0));
            return null;
        }, "log");

//        String jsCode = "console.log('Hello, world!');";
//        v8.executeVoidScript(jsCode);
    }

    public V8 getV8() {
        return v8;
    }

    public Object executeFunction(Object src) {
        try {
            V8Array array = new V8Array(v8);
            array.push(src.toString());
            return v8.executeFunction(INVOKE_JS_FUNC, array);
        } catch (Exception e) {
            Log.e("V8Executor", "Error executing Function: " + e.getMessage());
            return null;
        }
    }

    public String executeJs(String jsCode) {
        try {
            // 在 V8 上下文中执行 JavaScript 代码
            return v8.executeScript(jsCode).toString();
        } catch (Exception e) {
            Log.e("V8Executor", "Error executing JavaScript: " + e.getMessage());
            return null;
        }
    }

    public void release() {
        v8.release();
    }
}

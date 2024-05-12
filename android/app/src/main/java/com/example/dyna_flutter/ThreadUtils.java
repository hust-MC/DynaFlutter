package com.example.dyna_flutter;

import android.os.Handler;
import android.os.Looper;

/**
 * Created by Chao.Ma11.
 *
 * @Description:
 * @Date: 2024/4/30
 */
public class ThreadUtils {
    public static final Handler mHandler = new Handler(Looper.getMainLooper());

    public static boolean runOnUI(Runnable runnable) {
        return mHandler.post(runnable);
    }

    public static void run(Runnable runnable) {
        new Thread(runnable).start();
    }
}

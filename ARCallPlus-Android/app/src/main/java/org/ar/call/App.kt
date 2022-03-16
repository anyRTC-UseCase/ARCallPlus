package org.ar.call

import android.app.Application
import android.content.Context
import android.os.Handler
import android.util.Log
import com.kongzue.dialog.util.DialogSettings
import com.tencent.android.tpush.XGIOperateCallback
import com.tencent.android.tpush.XGPushConfig
import com.tencent.android.tpush.XGPushManager

class App : Application() {

  companion object {
    private lateinit var mUiThread: Thread
    private lateinit var mHandler: Handler

    lateinit var context: Context

    fun runOnUiThread(action: Runnable) {
      if (Thread.currentThread() !== mUiThread) {
        mHandler.post(action)
      } else {
        action.run()
      }
    }
  }

  override fun onCreate() {
    super.onCreate()
    context = applicationContext
    XGPushConfig.enableDebug = true
    mUiThread = Thread.currentThread()
    mHandler = Handler(mainLooper)

    DialogSettings.style = DialogSettings.STYLE.STYLE_IOS
    DialogSettings.cancelable = false
  }
}
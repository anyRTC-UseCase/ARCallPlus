package org.ar.call.services

import android.content.Context
import android.content.Intent
import android.util.Log
import com.tencent.android.tpush.*

class MessageReceiver : XGPushBaseReceiver() {

  override fun onRegisterResult(p0: Context?, p1: Int, p2: XGPushRegisterResult?) {
    if (p0 == null || p2 == null) {
      return
    }
    val text = if (p1 == SUCCESS) {
      // 在这里拿token
      val token: String = p2.token
      "注册成功1. token：$token"
    } else {
      p2.toString() + "注册失败，错误码：" + p1
    }
    Log.d("::", text)
  }

  override fun onUnregisterResult(p0: Context?, p1: Int) {
  }

  override fun onSetTagResult(p0: Context?, p1: Int, p2: String?) {
  }

  override fun onDeleteTagResult(p0: Context?, p1: Int, p2: String?) {
  }

  override fun onSetAccountResult(p0: Context?, p1: Int, p2: String?) {
    //val testIntent: Intent = Intent(TEST_ACTION)
//        testIntent.putExtra("step", Constants.TEST_SET_ACCOUNT);
    //p0?.sendBroadcast(testIntent)
  }

  override fun onDeleteAccountResult(p0: Context?, p1: Int, p2: String?) {
    //val testIntent: Intent = Intent(TEST_ACTION)
//        testIntent.putExtra("step", Constants.TEST_SET_ACCOUNT);
    //p0?.sendBroadcast(testIntent)
  }

  override fun onSetAttributeResult(p0: Context?, p1: Int, p2: String?) {
  }

  override fun onQueryTagsResult(p0: Context?, p1: Int, p2: String?, p3: String?) {
  }

  override fun onDeleteAttributeResult(p0: Context?, p1: Int, p2: String?) {
  }

  override fun onTextMessage(p0: Context?, p1: XGPushTextMessage?) {
    Log.e("::", "onTextMessage, $p0, $p1")
  }

  override fun onNotificationClickedResult(p0: Context?, p1: XGPushClickedResult?) {
  }

  override fun onNotificationShowedResult(p0: Context?, p1: XGPushShowedResult?) {
    if (p0 == null || p1 == null)
      return
    val viewIntent = Intent("com.qq.xgdemo.activity.UPDATE_LISTVIEW")
    p0.sendBroadcast(viewIntent)
    Log.d(
      "::",
      "您有1条新消息, " + "通知被展示 ， " + p1.toString() + ", PushChannel:" + p1.pushChannel
    )
  }
}
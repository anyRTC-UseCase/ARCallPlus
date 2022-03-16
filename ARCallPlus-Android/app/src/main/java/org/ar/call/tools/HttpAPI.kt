package org.ar.call.tools

import android.util.Log
import org.ar.call.App
import org.ar.call.BuildConfig
import org.ar.call.model.UserModel
import org.json.JSONArray
import org.json.JSONObject
import java.io.ByteArrayOutputStream
import java.io.PrintWriter
import java.net.HttpURLConnection
import java.net.URL


class HttpAPI {

  companion object {
    var head_authorization = ""
  }

  //private val baseUrl = "http://192.168.1.111:23680"
  private val baseUrl = "https://pro.gateway.agrtc.cn"
  private val appId = BuildConfig.APP_ID

  private fun generateRequest(callback: ReqResult, reqUrl: String, obj: JSONObject? = null) {
    try {
      val url = URL("$baseUrl$reqUrl")
      val cnn = url.openConnection() as HttpURLConnection
      if (head_authorization.isNotBlank())
        cnn.setRequestProperty("AR-Authorization", head_authorization)
      cnn.connectTimeout = 5000
      cnn.readTimeout = 5000
      cnn.requestMethod = "POST"
      cnn.doOutput = true
      cnn.doInput = true

      val output = PrintWriter(cnn.outputStream)
      output.print(obj?.toString() ?: "")
      output.flush()
      output.close()
      cnn.connect()

      if (cnn.responseCode != 200) {
        App.runOnUiThread { callback.invoke(cnn.responseCode, cnn.responseMessage, null) }
        return
      }
      val headerFields = cnn.headerFields
      val input = cnn.inputStream
      val baos = ByteArrayOutputStream()
      val bufArr = ByteArray(1024)
      var readSize: Int
      while (true) {
        readSize = input.read(bufArr)
        if (readSize <= 0)
          break
        baos.write(bufArr, 0, readSize)
      }

      val response = baos.toString()
      App.runOnUiThread { callback.invoke(200, response, headerFields) }
      input.close()
      cnn.disconnect()
    } catch (e: Exception) {
      App.runOnUiThread { callback.invoke(500, null, null) }
      e.printStackTrace()
    }
  }

  fun userExists(
    uid: String,
    isExists: (isExists: Boolean, failed: Boolean, userInfo: UserModel.UserInfo?) -> Unit
  ) {
    Thread {
      val jsObj = JSONObject("{\"uId\": \"$uid\", \"appId\": \"$appId\"}")
      generateRequest(callback = { code, response, _ ->
        if (null != response && code == 200) {
          val rJson = JSONObject(response)
          val sCode = rJson.getInt("code")
          var userExists = false
          var userInfo: UserModel.UserInfo? = null

          if (sCode == 200) {
            val dJson = rJson.getJSONObject("data")
            val sUid = dJson.getString("uId")
            val sAvatar = dJson.getString("headerImg")
            val sNickname = dJson.getString("nickName")
            userExists = true
            userInfo = UserModel.UserInfo(System.currentTimeMillis(), sUid, sAvatar, sNickname)
          }
          isExists.invoke(userExists, false, userInfo)
          return@generateRequest
        }
        isExists.invoke(false, true, null)
      }, "/api/v1/jpush/exists", obj = jsObj)
    }.start()
  }

  fun init(
    uid: String,
    avatar: String,
    nickname: String,
    initSuccess: (Boolean) -> Unit
  ) {
    Thread {
      val jsObj = JSONObject(
        "{\"appId\": \"$appId\", \"uId\": \"$uid\", \"device\": 1, \"headerImg\": \"$avatar\", \"nickName\": \"$nickname\"}"
      )
      generateRequest(callback = { code, response, headerFields ->
        if (null != response && code == 200 && headerFields != null) {
          val token = headerFields["Ar-Token"]?.get(0) ?: ""
          Log.e("::", "token=$token")
          if (token.isNotBlank()) {
            initSuccess.invoke(true)
            head_authorization = token
            return@generateRequest
          }
        }
        initSuccess.invoke(false)
      }, "/api/v1/jpush/init", obj = jsObj)
    }.start()
  }

  /**
   * @param callType: 0/1/2/3：p2p音频呼叫/p2p视频呼叫/群组音频呼叫/群组视频呼叫
   * @param pushType: 0=push 1=cancel
   */
  fun pushNotification(
    uid: String,
    title: String,
    callTo: Array<String>,
    callType: Int,
    pushType: Int,
    callback: (success: Boolean) -> Unit
  ) {
    Thread {
      val json = JSONObject(
        //"{\"caller\": \"$uid\", \"title\": \"$title\", \"callee\": [\"$callTo\"], \"callType\": $callType, \"pushType\": $pushType}"
      )
      val callToArray = JSONArray(callTo)
      json.apply {
        put("caller", uid)
        put("title", title)
        put("callee", callToArray)
        put("callType", callType)
        put("pushType", pushType)
      }
      Log.e("::", "push json=$json")
      generateRequest(callback = { code, resp, _ ->
        if (code != 200 || null == resp) {
          App.runOnUiThread { callback.invoke(false) }
          return@generateRequest
        }
        val sJson = JSONObject(resp)
        val sCode = sJson.getInt("code")
        App.runOnUiThread { callback.invoke(sCode == 200) }
      }, "/api/v1/jpush/processPush", json)
    }.start()
  }

  private fun interface ReqResult {
    fun invoke(code: Int, body: String?, headerFields: Map<String, List<String>>?)
  }
}
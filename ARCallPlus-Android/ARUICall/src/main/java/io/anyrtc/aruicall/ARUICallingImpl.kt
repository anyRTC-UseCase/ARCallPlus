package io.anyrtc.aruicall

import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.lifecycle.*
import com.blankj.utilcode.util.ToastUtils
import com.google.gson.Gson
import com.hjq.gson.factory.GsonFactory
import io.anyrtc.aruicall.utils.ARUICallService
import io.anyrtc.aruicall.utils.Interval
import io.anyrtc.aruicall.view.ARUICallGroupView
import io.anyrtc.aruicall.view.ARUICallVideoView
import io.anyrtc.aruicall.view.BaseTUICallView
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import org.ar.rtm.RemoteInvitation
import org.ar.rtm.RtmMessage
import org.json.JSONObject
import toast
import java.util.concurrent.TimeUnit

class ARUICallingImpl constructor(context: Context, private val anotherUserLogin: (() -> Unit)? = null) : ARUICalling(), RtmEvents, LifecycleObserver,
  LifecycleOwner {

  private var mEnableCustomViewRoute = false // 是否开启自定义视图
  private var mContext: Context? = null
  private val gson = Gson()
  private var isReconnect = false
  private val interval by lazy { Interval(10, 1, TimeUnit.SECONDS, 1).life(this) }
  private val disconnectInterval by lazy { Interval(30, 1, TimeUnit.SECONDS, 1).life(this) }
  private var isReceiveResponse = false
  private val mRegistry = LifecycleRegistry(this)
  private var aruiCallingListener: ARUICalling.ARUICallingListener? = null
  private var mCallView: BaseTUICallView? = null
  private var needForegroundService = false

  init {
    mContext = context
    ProcessLifecycleOwner.get().lifecycle.addObserver(this)
    GlobalVM.instance.registerCalling(this)
    if (needForegroundService) {
      ARUICallService.start(context)
    }
  }


  @OnLifecycleEvent(Lifecycle.Event.ON_START)
  private fun onStart() {
    mRegistry.handleLifecycleEvent(Lifecycle.Event.ON_START)

  }

  @OnLifecycleEvent(Lifecycle.Event.ON_STOP)
  private fun onStop() {
    mRegistry.handleLifecycleEvent(Lifecycle.Event.ON_STOP)
  }

  @OnLifecycleEvent(Lifecycle.Event.ON_CREATE)
  private fun onCreate() {
    mRegistry.handleLifecycleEvent(Lifecycle.Event.ON_CREATE)
  }

  @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
  private fun onResume() {
    mRegistry.handleLifecycleEvent(Lifecycle.Event.ON_RESUME)
  }

  @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
  private fun onPAUSE() {
    mRegistry.handleLifecycleEvent(Lifecycle.Event.ON_PAUSE)
  }

  fun needForegroundService(need: Boolean) {
    this.needForegroundService = need
  }


  override fun call(user: ARCallUser, type: ARUICalling.Type) {
    if (user == null || user.userId == ARUILogin.userId) {
      mContext?.toast("不能呼叫自己")
      return
    }
    internalCall(
      CurCallModel(
        arrayOf(user).toMutableList(),
        type,
        ARUICalling.Role.CALL,
        ((Math.random() * 9 + 1) * 100000000L).toLong().toString(),
        false,
        ""
      )
    )
  }

  override fun call(users: Array<ARCallUser>, type: ARUICalling.Type) {
    internalCall(
      CurCallModel(
        users.toMutableList(),
        type,
        ARUICalling.Role.CALL,
        ((Math.random() * 9 + 1) * 100000000L).toLong().toString(),
        users.size>1,
        ""
      )
    )

  }


  override fun setCallingListener(listener: ARUICalling.ARUICallingListener) {
    aruiCallingListener = listener
    GlobalVM.instance.aruiCallingListener = listener
  }

  override fun setCallingBell(filePath: String) {
    GlobalVM.instance.mCallingBellPath = filePath
  }

  override fun enableMuteMode(enable: Boolean) {
    GlobalVM.instance.mEnableMuteMode = enable
  }

  override fun enableFloatWindow(enable: Boolean) {
  }

  override fun enableCustomViewRoute(enable: Boolean) {
    mEnableCustomViewRoute = enable
  }

  override fun onRemoteInvitationReceived(var1: RemoteInvitation?) {
    super.onRemoteInvitationReceived(var1)

    internalCalled()
  }

  private fun internalCalled() {
    GlobalVM.instance.curCallModel?.let {
      if (it.isGroup) {
        val calledArray =
          it.users.filterNot { it.userId == GlobalVM.instance.userId } as ArrayList<ARCallUser>
        if (mEnableCustomViewRoute) {
          mCallView = ARUICallGroupView(mContext!!)
          aruiCallingListener?.onCallStart(
            calledArray.toTypedArray(),
            it.type,
            Role.CALLED,
            mCallView
          )
        } else {
          mContext?.startActivity(Intent(mContext, BaseCallActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            putExtra("isGroup", true)
          })
          aruiCallingListener?.onCallStart(
            calledArray.toTypedArray(),
            it.type,
            Role.CALLED,
            null
          )
        }


      } else {
        if (mEnableCustomViewRoute) {
          mCallView = ARUICallVideoView(
            mContext!!
          )
          aruiCallingListener?.onCallStart(
            it.users.toTypedArray(),
            it.type,
            Role.CALLED,
            mCallView
          )
        } else {
          mContext?.startActivity(Intent(mContext, BaseCallActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            putExtra("isGroup", false)
          })
          aruiCallingListener?.onCallStart(
            it.users.toTypedArray(),
            it.type,
            Role.CALLED,
            mCallView
          )
        }

      }
    }
  }

  private fun internalCall(
    callModel: CurCallModel
  ) {

    if (callModel.isGroup) {//群组呼叫
      GlobalVM.instance.queryOnline(callModel.getUserIdArray()) { onlineUsers ->
        val onlineList = mutableListOf<ARCallUser>()

        val callContent = CallContent()
        callContent.mode = callModel.type.ordinal
        callContent.conference = callModel.isGroup
        callContent.chanId = callModel.groupId
        callContent.userData = ArrayList<String>().apply {
          add(ARUILogin.userId)//self
          callModel.getUserIdArray().forEach {//有推送后 所有人都呼叫
            add(it)
          }
        }
        callContent.userInfo = ArrayList<ARCallUser>().apply {
          callModel.users.forEach {
            add(it)
          }
          (ARUILogin.selfModel?.let {
            add(it)
          })
        }

        onlineUsers.forEach { uid ->
          callModel.users.find { it.userId == uid }?.let {
            onlineList.add(it)
          }
        }
        val offlineList = callModel.users.subtract(onlineList)
        if (offlineList.size > 0) {
          aruiCallingListener?.onPushToOfflineUser(//不在线的发起推送
            offlineList.toTypedArray(), callModel.type
          )
        }
        callModel.content = GsonFactory.getSingletonGson().toJson(callContent)
        GlobalVM.instance.curCallModel = callModel//传给当前model
        if (mEnableCustomViewRoute) {
          mCallView = ARUICallGroupView(mContext!!)
          aruiCallingListener?.onCallStart(
            callModel.users.toTypedArray(), callModel.type, ARUICalling.Role.CALL, mCallView
          )
        } else {
          mContext?.startActivity(Intent(mContext, BaseCallActivity::class.java).apply {
            putExtra("isGroup", true)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
          })
          aruiCallingListener?.onCallStart(
            callModel.users.toTypedArray(), callModel.type, ARUICalling.Role.CALL, null
          )
        }
      }

    } else { //P2P呼叫
      GlobalVM.instance.queryOnline(callModel.getUserIdArray()[0]) {
        if (!it) {
          aruiCallingListener?.onPushToOfflineUser(
            arrayOf(callModel.users[0]),
            callModel.type
          )
        }
        GlobalVM.instance.curCallModel = callModel//传给当前model
        GlobalVM.instance.createLocalInvitation()
        if (mEnableCustomViewRoute) {
          mCallView = ARUICallVideoView(mContext!!)
          aruiCallingListener?.onCallStart(
            arrayOf(callModel.users[0]),
            callModel.type,
            callModel.role,
            mCallView
          )
        } else {
          mContext?.startActivity(
            Intent(mContext, BaseCallActivity::class.java).apply {
              putExtra("isGroup", false)
              addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
          )
          aruiCallingListener?.onCallStart(
            arrayOf(callModel.users[0]),
            callModel.type,
            callModel.role,
            null
          )
        }
      }
    }
  }

  override fun onConnectionStateChanged(state: Int, reason: Int) {
    super.onConnectionStateChanged(state, reason)
    if (state == 5) {
      if (isReconnect) {
        isReconnect = true
        isReceiveResponse = false
      }

      lifecycleScope.launch {
        anotherUserLogin?.invoke()
        GlobalVM.instance.onFinish()
        GlobalVM.instance.curCallModel?.let {
          aruiCallingListener?.onCallEvent(
            Event.CALL_LOGOUT,
            it.type,
            it.role,
            ARUICallConstants.EVENT_CALL_LOGOUT
          )
        }
      }
    } else if (state == 4) {
      isReconnect = true
      isReceiveResponse = false
      ToastUtils.showLong("正在重连...")
      if (GlobalVM.instance.isCalling) {//如果正在通话中 断线了 30秒都没有重连成功
        disconnectInterval.finish {
          if (isReconnect) {
            //如果重连了30秒都还没连上 则离开
            lifecycleScope.launch {
              mContext?.toast("网络连接断开！")
              delay(1500)
              GlobalVM.instance.onFinish()
              GlobalVM.instance.curCallModel?.let {
                aruiCallingListener?.onCallEnd(
                  it.users.toTypedArray(),
                  it.type,
                  it.role,
                  0
                )
                aruiCallingListener?.onCallEvent(
                  Event.CALL_END,
                  it.type,
                  it.role,
                  ARUICallConstants.EVENT_CALL_TIMEOUT
                )
              }
            }
          }
        }.start()
      }
    } else if (state == 3) {
      if (isReconnect) {
        isReconnect = false
        disconnectInterval.cancel()
        mContext?.toast("重连成功！")
        if (GlobalVM.instance.isInP2pCall && (GlobalVM.instance.isWaiting || GlobalVM.instance.isCalling)) {
          //断网重连成功后 如果是p2p正在呼叫页面 则发送消息给对方
          //判断是否继续等待被接听/接听/拒绝❌
          //10秒没有任何消息返回 则退出
          //收到对方说不在呼叫页面了 则退出
          GlobalVM.instance.sendCallStateMsg()
          interval.finish {
            if (!isReceiveResponse) {
              mContext?.toast("通话结束")
              GlobalVM.instance.finishCall()
              GlobalVM.instance.onFinish()
              GlobalVM.instance.curCallModel?.let {
                aruiCallingListener?.onCallEvent(
                  Event.CALL_END,
                  it.type,
                  it.role,
                  ARUICallConstants.EVENT_CALL_TIMEOUT
                )
              }

            }
          }.start()
        }
      }
    }
  }

  override fun onMessageReceived(message: RtmMessage?, uid: String?) {
    super.onMessageReceived(message, uid)
    if (!message?.text.isNullOrEmpty()) {
      val json = JSONObject(message?.text)
      if (json.has("Cmd")) {
        when (json["Cmd"]) {
          "CallState" -> {
            interval.cancel()
            GlobalVM.instance.sendCallStateResponseMsg(uid!!)
          }
          "CallStateResult" -> {
            isReceiveResponse = true
            val state = json.getInt("state")
            when (state) {
              0 -> {//对方已结束通话
                mContext?.toast("对方已挂断")
                GlobalVM.instance.finishCall()
                GlobalVM.instance.onFinish()
              }
              1 -> {//对方正在等待中
                //不处理
              }
              2 -> {//对方正在通话了
                if (GlobalVM.instance.isWaiting) {//如果本地还是在等待中 说明在断网期间 对方已经进入通话
                  val mode = json.getInt("Mode")
                  GlobalVM.instance.reSendAcceptCallback(mode)
                }
              }
            }
          }
        }
      }
    }
  }


  override fun getLifecycle(): Lifecycle {
    return mRegistry
  }
}
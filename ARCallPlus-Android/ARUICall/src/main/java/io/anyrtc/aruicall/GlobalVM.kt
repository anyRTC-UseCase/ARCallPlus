package io.anyrtc.aruicall

import android.app.Notification
import android.app.PendingIntent
import androidx.core.app.NotificationManagerCompat
import androidx.lifecycle.*
import org.ar.rtm.*
import org.json.JSONObject


import android.content.Context
import android.net.Uri
import android.util.Log
import com.hjq.gson.factory.GsonFactory
import getAppOpenIntentByPackageName
import getPackageContext
import io.anyrtc.aruicall.utils.Interval
import io.anyrtc.aruicall.utils.MediaPlayHelper
import io.anyrtc.aruicall.utils.NetworkObserver
import io.karn.notify.Notify
import launch
import java.util.concurrent.TimeUnit


class GlobalVM private constructor(): LifecycleObserver, NetworkObserver.Listener {

    private var isBackground = false //是否处于后台
    private var needReCallBack = false //从后台回到前台 期间如果有人呼叫 需要将呼叫重新回调出去
    private var isShowNotify = false //是否显示了通知
    var isWaiting = false //是否正处于呼叫/被叫接听等待中...
    var isCalling = false// 是否正在通话中...
    var isInP2pCall = false
    var isInGroupCall = false
    var callingUid = ""//p2p正在通话中的人的UID
    var netOnline = true //网络是否连接着
    private var mContext:Context?=null
    private var mediaPlayHelper:MediaPlayHelper? = null
    var mEnableMuteMode = false // 是否开启静音模式
    var curCallModel:CurCallModel? = null //当前通话保存的信息
    var mCallingBellPath = "" // 被叫铃音路径
    var aruiCallingListener:ARUICalling.ARUICallingListener? = null

    val callTime = MutableLiveData<Long>(0)
    private val callTimeInterval by lazy { Interval(-1, 1, TimeUnit.SECONDS, 10) }//收到对方异常离开 倒计10秒 10秒内对方还未恢复 则退出
    private var isStartTime = false
    init {
        ProcessLifecycleOwner.get().lifecycle.addObserver(this)
    }

    companion object {
        val instance: GlobalVM by lazy(mode = LazyThreadSafetyMode.SYNCHRONIZED) {
            GlobalVM() }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_START)
    fun onForeground() {
        isBackground = false
        if (needReCallBack) {
            launch({
                if (currentRemoteInvitation != null) {
                    callingEvents?.onRemoteInvitationReceived(currentRemoteInvitation)
                   // events?.onRemoteInvitationReceived(currentRemoteInvitation)
                    cancelNotify()
                }
            })
            needReCallBack = false
        }
    }

    @OnLifecycleEvent(Lifecycle.Event.ON_STOP)
    fun onBackground() {
        isBackground = true
    }

    fun onFinish(){
        events?.onFinish()
    }


    var userId = ""
    private var events: RtmEvents? = null
    private var callingEvents: RtmEvents? = null

    private lateinit var rtmClient:RtmClient
    val rtmCallManager by lazy { rtmClient.rtmCallManager }
    var localInvitation: LocalInvitation? = null
    var remoteInvitationArray =
        mutableListOf<RemoteInvitation>()//如果有多个人呼叫 必须将所有对象存起来 而不是直接覆盖之前的 不然会出各种奇怪的问题
    var currentRemoteInvitation: RemoteInvitation? = null //当前的通话对象

    var isLoginSuccess = false
    var channelId = ""
    var rtmChannel: RtmChannel? = null


    fun register(rtmEvents: RtmEvents) {
        events = rtmEvents
    }

    fun registerCalling(rtmEvents: RtmEvents) {
        callingEvents = rtmEvents
    }

    fun unRegister() {
        events = null
    }

    fun initSDK(appId:String,context: Context){
        rtmClient = RtmClient.createInstance(
            context,
            appId,
            RtmEvent()
        )
        rtmClient?.let {
//            it.setParameters("{\"Cmd\":\"ConfPriCloudAddr\", \"ServerAdd\":\"xxx\", \"Port\": 7080}")
        }
        mContext = context
        NetworkObserver.invoke(context,true,this)
        mediaPlayHelper = MediaPlayHelper((mContext))
    }

    fun unInit(){
        release()
    }

    //当前通话是否是被叫
    private fun currentIsCalled(): Boolean {
        return currentRemoteInvitation != null
    }
    //发送查询对方呼叫状态信令
    fun sendCallStateMsg() {
        sendMessage(
            callingUid, JSONObject().apply {
                put("Cmd", "CallState")
            }.toString(), {

            })
    }

    //不在呼叫页面了
    fun finishCall(){
        if (currentIsCalled()){
            currentRemoteInvitation?.let { rtmCallManager.refuseRemoteInvitation(it,null) }
        }else{
            localInvitation?.let { rtmCallManager.cancelLocalInvitation(it,null)}
        }
    }

    //发送是否还在呼叫回执信令
    fun sendCallStateResponseMsg(uid:String) {
        sendMessage(
           uid, JSONObject().apply {
                put("Cmd","CallStateResult")
                if (isWaiting){
                    put("state", 1)
                }else if (isCalling){
                    //如果发消息的id和当前通话id不一致则直接发CallState =0
                        if (uid!=callingUid){
                            put("state", 0)
                        }else{
                            put("state", 2)
                            put("Mode",curCallModel?.type?.ordinal)
                        }
                }else{
                    put("state", 0)
                }
            }.toString(), {

            })
    }

    //重新分发对方已同意呼叫回调

    fun reSendAcceptCallback(callType:Int){
        events?.onLocalInvitationAccepted(localInvitation,JSONObject().apply {
            put("Mode",callType)
        }.toString())
    }

    fun login(uid:String,callback:ResultCallback<Void>) {
        rtmClient.logout(null)
        rtmClient.login(ARUILogin.rtmToken, uid, object : ResultCallback<Void> {
            override fun onSuccess(var1: Void?) {
                isLoginSuccess = true
                rtmCallManager.setEventListener(CallEvent())
                userId = uid
                launch({
                    callback.onSuccess(var1)
                })

            }

            override fun onFailure(var1: ErrorInfo?) {
                isLoginSuccess = false
                launch({
                    callback.onFailure(var1)
                })

            }
        })
    }
    fun logout(){
        rtmClient.logout(null)
    }
    fun queryOnline(peerId: String, block: (Boolean) -> Unit) {
        queryOnline(HashSet<String>().apply {
            add(peerId)
        }) {
            it?.let { map ->
                launch({
                    if (map.containsKey(peerId) && map.get(peerId)!!) {
                        block.invoke(true)
                    } else {
                        block.invoke(false)
                    }
                })
            }
        }
    }

    fun queryOnline(list: Array<String>, block: (ArrayList<String>) -> Unit) {
        val onlineArray = arrayListOf<String>()
        rtmClient.queryPeersOnlineStatus(list.toSet(),
            object : ResultCallback<MutableMap<String, Boolean>> {

                override fun onSuccess(var1: MutableMap<String, Boolean>?) {
                    launch({
                        var1?.forEach {
                            if (it.value) {
                                onlineArray.add(it.key)
                            }
                        }
                        block.invoke(onlineArray)
                    })
                }

                override fun onFailure(var1: ErrorInfo?) {
                    launch({
                        block.invoke(onlineArray)
                    })
                }
            })
    }

    fun createLocalInvitation() {
        localInvitation = curCallModel?.users?.get(0)?.let { rtmCallManager.createLocalInvitation(it.userId) }
        localInvitation?.let {
            it.content = GsonFactory.getSingletonGson().toJson(CallContent().apply {
                mode = curCallModel?.type?.ordinal!!//音频 or 视频
                conference= false//是否多人
                chanId=curCallModel?.groupId//频道号
                userData=null
                sipData = ""
                userInfo = ArrayList<ARCallUser>().apply {
                    add(ARUILogin.selfModel!!)
                }
               vidCodec= "[\"H264\",\"MJpeg\"]"//适配linux手表端
               audCodec = "[\"Opus\",\"G711\"]"//适配linux手表端
            })
        }
    }

    private fun queryOnline(
        queryList: HashSet<String>,
        resultList: (MutableMap<String, Boolean>?) -> Unit
    ) {
        rtmClient.queryPeersOnlineStatus(
            queryList,
            object : ResultCallback<MutableMap<String, Boolean>> {
                override fun onSuccess(var1: MutableMap<String, Boolean>?) {
                    resultList.invoke(var1)
                }

                override fun onFailure(var1: ErrorInfo?) {
                }
            })

    }



    fun call() {
        localInvitation?.let {
            rtmCallManager.sendLocalInvitation(it, null)
        }
    }

    fun call(localInvitation: LocalInvitation) {
        rtmCallManager.sendLocalInvitation(localInvitation, null)
    }


    fun sendMessage(userId: String, msg: String, block: (Boolean) -> Unit) {
        rtmClient.sendMessageToPeer(
            userId,
            rtmClient.createMessage(msg),
            SendMessageOptions(),
            object : ResultCallback<Void> {
                override fun onSuccess(var1: Void?) {
                    launch({
                        block.invoke(true)
                    })

                }

                override fun onFailure(var1: ErrorInfo?) {
                    launch({
                        block.invoke(false)
                    })
                }
            })
    }

    fun cancel() {
        localInvitation?.let {
            rtmCallManager.cancelLocalInvitation(it, null)
        }
    }

    fun cancel(localInvitation: LocalInvitation) {
        rtmCallManager.cancelLocalInvitation(localInvitation, null)
    }

    fun refuse(remoteInvitation: RemoteInvitation, response: String = "") {
        remoteInvitationArray.find { it.callerId == remoteInvitation.callerId }?.let {
            it.response = response
            rtmCallManager.refuseRemoteInvitation(it, null)
            remoteInvitationArray.remove(it)
        }
    }

    fun accept(remoteInvitation: RemoteInvitation, response: String = "") {
        remoteInvitationArray.find { it.callerId == remoteInvitation.callerId }?.let {
            it.response = response
            rtmCallManager.acceptRemoteInvitation(it, null)
            remoteInvitationArray.remove(it)
        }
    }

    fun release() {
        events = null
        rtmClient.logout(null)
        rtmClient.release()
        releaseCall()
    }

    fun joinRTMChannel(chanID: String) {
        channelId = chanID
        rtmChannel = rtmClient.createChannel(chanID, ChannelEvent())
        rtmChannel?.join(null)
    }

    fun leaveRtmChannel() {
        rtmChannel?.let {
            it.leave(null)
            it.release()
            stopRing()
            channelId = ""
        }
    }

    private inner class RtmEvent : RtmClientListener {
        override fun onConnectionStateChanged(state: Int, reason: Int) {
            launch({
                events?.onConnectionStateChanged(state, reason)
                callingEvents?.onConnectionStateChanged(state, reason)
            })

        }

        override fun onMessageReceived(message: RtmMessage?, var2: String?) {
            launch({
                    if (!message?.text.isNullOrEmpty()) {
                        val json = JSONObject(message?.text)
                        if (json.has("Cmd")) {
                            when (json["Cmd"]) {
                                "EndCall"->{
                                    events?.onMsgEndCall()
                                    releaseCall()
                                }
                                "SwitchAudio"->{
                                    curCallModel?.type=ARUICalling.Type.AUDIO
                                    events?.onSwitchToAudio()
                                }
                                else->{
                                    events?.onMessageReceived(message,var2)
                                    callingEvents?.onMessageReceived(message,var2)
                                }
                            }
                        }
                    }

            })
        }

        override fun onTokenWillExpire() {
        }

        override fun onTokenExpired() {
        }

        override fun onPeersOnlineStatusChanged(var1: MutableMap<String, Int>?) {
            launch({
            events?.onPeersOnlineStatusChanged(var1)
            })
        }

    }

    private inner class CallEvent : RtmCallEventListener {

        //返回给主叫的回调：被叫已收到呼叫邀请。
        override fun onLocalInvitationReceivedByPeer(var1: LocalInvitation?) {
            launch({
                events?.onLocalInvitationReceivedByPeer(var1)
            })

        }

        //返回给主叫的回调：被叫已接受呼叫邀请
        override fun onLocalInvitationAccepted(var1: LocalInvitation?, var2: String?) {
            launch({
                events?.onLocalInvitationAccepted(var1, var2)
                startCallTime()
                stopRing()
                curCallModel?.let {
                    aruiCallingListener?.onCallEvent(ARUICalling.Event.CALL_SUCCEED,it.type,it.role,ARUICallConstants.EVENT_CALL_SUCCESS)

                }
              })
        }

        //返回给主叫的回调：被叫已拒绝呼叫邀请。
        override fun onLocalInvitationRefused(var1: LocalInvitation?, var2: String?) {
            launch({
                    events?.onLocalInvitationRefused(var1, var2)
                    curCallModel?.let {
                        aruiCallingListener?.onCallEvent(
                            ARUICalling.Event.CALL_FAILED,
                            it.type,
                            it.role,
                            ARUICallConstants.EVENT_CALL_HANG_UP
                        )
                        stopRing()
                    }
            })
        }

        //返回给主叫的回调：呼叫邀请已被成功取消。
        override fun onLocalInvitationCanceled(var1: LocalInvitation?) {
            launch({
                if (callingUid==var1?.calleeId) {
                    events?.onLocalInvitationCanceled(var1)
                    stopRing()
                }
            })
        }

        //返回给主叫的回调：发出的呼叫邀请失败。可能对方一直没有接听
        override fun onLocalInvitationFailure(var1: LocalInvitation?, var2: Int) {
            launch({
                    events?.onLocalInvitationFailure(var1, var2)
                    stopRing()
            })
        }

        //返回给被叫的回调：收到一条呼叫邀请。SDK 会同时返回一个 RemoteInvitation 对象供被叫管理。
        override fun onRemoteInvitationReceived(var1: RemoteInvitation?) {
            remoteInvitationArray.add(var1!!)
            if (curCallModel!=null) {
                refuse(var1!!, JSONObject().apply {
                    put("Cmd", "Calling")
                }.toString())
                return
            }
            if (currentRemoteInvitation == null) {//如果当前没有通话ID 就给它赋值
                currentRemoteInvitation = var1
            }
            val content = GsonFactory.getSingletonGson().fromJson(var1!!.content,CallContent::class.java)
            if (curCallModel==null){
                var users = mutableListOf<ARCallUser>()

                if (!content.isConference){//如果是p2p
                    if (!content.userInfo.isNullOrEmpty()){//如果有用户信息
                        users = content.userInfo
                    }else{
                        users = mutableListOf(ARCallUser(var1!!.callerId))
                    }
                }else{
                    if (!content.userInfo.isNullOrEmpty()){//如果有用户信息
                        users = content.userInfo
                    }else{
                        content.userData.forEach {
                            users.add(ARCallUser(it))
                        }
                    }
                    users = users.filterNot { it.userId == userId } as ArrayList<ARCallUser>
                }
                curCallModel = CurCallModel(users,ARUICalling.Type.values()[content.mode],ARUICalling.Role.CALLED,content.chanId,content.isConference,var1?.content.toString(),var1!!.callerId,callerName = if (content.userInfo == null){var1!!.callerId}else{content.userInfo?.find { it.userId==var1?.callerId }?.userName.toString()})
            }

            launch({
                if (isBackground) {//如果是在后台 则不分发这个收到呼叫 因为安卓10或国内一些rom限制后台启动activity
                    //todo 可以加本地通知
                    needReCallBack = true
                    val pakContext = getPackageContext(
                        mContext!!,
                        mContext!!.packageName
                    )
                    pakContext?.let {
                        val intent = getAppOpenIntentByPackageName(it,  mContext!!.packageName)
                        val builder = Notify.with( mContext!!)
                            .alerting("sound", {
                                sound =
                                    Uri.parse("android.resource://" +  mContext!! + "/" + R.raw.phone_ringing)
                            })
                            .meta {
                                clickIntent = PendingIntent.getActivity(
                                    mContext!!, 0,
                                    intent, 0
                                )
                                cancelOnClick = true
                            }
                            .content {
                                title = "收到呼叫"
                                text = "收到来自${var1.callerId}的呼叫邀请"
                            }.asBuilder().setOnlyAlertOnce(false)
                        with(NotificationManagerCompat.from(mContext!!)) {
                            notify(1000, builder.build().apply {
                                flags = Notification.FLAG_INSISTENT
                            })
                            isShowNotify = true
                            startRing()
                        }

                    }
                } else {
                    events?.onRemoteInvitationReceived(var1)
                    callingEvents?.onRemoteInvitationReceived(var1)
                }

            })
        }

        //返回给被叫的回调：接受呼叫邀请成功。
        override fun onRemoteInvitationAccepted(var1: RemoteInvitation?) {
            cancelNotify()
            launch({
                events?.onRemoteInvitationAccepted(var1)
                startCallTime()
                stopRing()
            })

            if (currentRemoteInvitation?.callerId.equals(var1!!.callerId)) {
                currentRemoteInvitation = null
            }
            remoteInvitationArray.find { it.callerId == var1?.callerId }?.let {
                remoteInvitationArray.remove(it)
            }

        }

        //返回给被叫的回调：拒绝呼叫邀请成功
        override fun onRemoteInvitationRefused(var1: RemoteInvitation?) {
            cancelNotify()
            stopRing()
            launch({
            events?.onRemoteInvitationRefused(var1)
            })
            if (currentRemoteInvitation?.callerId.equals(var1!!.callerId)) {
                currentRemoteInvitation = null
                curCallModel = null
            }
            remoteInvitationArray.find { it.callerId == var1?.callerId }?.let {
                remoteInvitationArray.remove(it)
            }

        }

        //返回给被叫的回调：拒绝呼叫邀请成功
        override fun onRemoteInvitationCanceled(var1: RemoteInvitation?) {
            Log.d("-----","onRemoteInvitationCanceled")
            cancelNotify()
            launch({
            events?.onRemoteInvitationCanceled(var1)
                stopRing()
            })
            if (currentRemoteInvitation?.callerId.equals(var1!!.callerId)) {
                currentRemoteInvitation = null
                curCallModel = null
            }

            remoteInvitationArray.find { it.callerId == var1?.callerId }?.let {
                remoteInvitationArray.remove(it)
            }


        }

        override fun onRemoteInvitationFailure(var1: RemoteInvitation?, var2: Int) {
            Log.d("-----","onRemoteInvitationFailure")
            cancelNotify()
            launch({
            events?.onRemoteInvitationFailure(var1, var2)
                stopRing()
            })

            if (currentRemoteInvitation?.callerId.equals(var1!!.callerId)) {
                currentRemoteInvitation = null
            }
            remoteInvitationArray.find { it.callerId == var1?.callerId }?.let {
                remoteInvitationArray.remove(it)
            }


        }

    }

    private fun startCallTime() {
        if (!isStartTime) {
            callTimeInterval.reset()
            callTimeInterval.subscribe {
                callTime.value = it
            }
            callTimeInterval.finish {
                Log.d("通话 结束", it.toString())
            }
            callTimeInterval.start()
            isStartTime = true
        }
    }

    private inner class ChannelEvent : RtmChannelListener {
        override fun onMemberCountUpdated(var1: Int) {
        }

        override fun onAttributesUpdated(var1: MutableList<RtmChannelAttribute>?) {
        }

        override fun onMessageReceived(message: RtmMessage?, var2: RtmChannelMember?) {
            launch({
            })
        }

        override fun onMemberJoined(var1: RtmChannelMember?) {
            launch({
                events?.onMemberJoined(var1)
            })

        }

        override fun onMemberLeft(var1: RtmChannelMember?) {
            launch({
                events?.onMemberLeft(var1)
            })
        }
    }

    private fun cancelNotify() {
        if (isShowNotify) {
            Notify.cancelNotification(1000)
            isShowNotify = false
        }
    }

    override fun onConnectivityChange(isOnline: Boolean) {
        netOnline = isOnline
        Log.d("onConnectivityChange",isOnline.toString())
    }

    fun startCallRing(){
        mediaPlayHelper?.let {
            it.start(R.raw.phone_dialing)
        }
    }

    fun startRing(){
        mediaPlayHelper?.let {
            if (!mEnableMuteMode){
                if (mCallingBellPath.isNullOrEmpty()){
                    it.start(R.raw.phone_ringing)
                }else{
                    it.start(mCallingBellPath)
                }
            }
        }
    }

    fun stopRing(){
        stopMusic()
    }

    private fun playHangupMusic(){
        mediaPlayHelper?.let {
            it.start(R.raw.phone_hangup,2000)
        }
    }

    private fun stopMusic(){
        mediaPlayHelper?.let {
            if (it.resId!=R.raw.phone_hangup){
                it.stop()
            }
        }
    }

    fun releaseCall(){
        playHangupMusic()
        callTimeInterval.stop()
        isStartTime = false
        curCallModel?.let {
            aruiCallingListener?.onCallEnd(it.users.toTypedArray(),it.type,it.role,callTime.value!!)
        }
        curCallModel = null
        isBackground = false //是否处于后台
        needReCallBack = false //从后台回到前台 期间如果有人呼叫 需要将呼叫重新回调出去
        isShowNotify = false //是否显示了通知
        isWaiting = false //是否正处于呼叫/被叫接听等待中...
        isCalling = false// 是否正在通话中...
        isInP2pCall = false
        isInGroupCall = false
        callingUid = ""//p2p正在通话中的人的UID
        netOnline = true //网络是否连接着
        localInvitation= null
        remoteInvitationArray.clear()
        currentRemoteInvitation = null //当前的通话对象
        channelId = ""

    }


}
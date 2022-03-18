package io.anyrtc.aruicall

import android.content.Context
import android.view.TextureView
import androidx.lifecycle.MutableLiveData
import io.anyrtc.aruicall.utils.Interval
import kotlinx.coroutines.delay
import launch
import org.ar.rtc.Constants
import org.ar.rtc.IRtcEngineEventHandler
import org.ar.rtc.RtcEngine
import org.ar.rtc.video.VideoCanvas
import java.util.concurrent.TimeUnit

class RtcVM(){

    var rtcEngine: RtcEngine? = null
    private var channelId = ""
    private var userId = ""
    var inMeeting = false //是否正在通话中
    private var haveMemberJoin = false //是否有人加入？用来判断 加入频道后 对方可能因为某些原因 10秒内都未能加入通话 则退出本次通话

    val joinState = MutableLiveData<Int>()
    val remoteVideoDecode = MutableLiveData<String>()
    val remoteAudioDecode = MutableLiveData<String>()
    val remoteVideoState = MutableLiveData<Pair<String,Int>>()
    val remoteAudioState = MutableLiveData<Pair<String,Int>>()
    val userJoin = MutableLiveData<String>()
    val nobodyComeIn = MutableLiveData<Boolean>()
    val userOffline = MutableLiveData<Int>()
    var calledLeave = false



    private val userOfflineInterval by lazy { Interval(10, 1, TimeUnit.SECONDS, 1) }//收到对方异常离开 倒计10秒 10秒内对方还未恢复 则退出
    private val nobodyComing by lazy {  Interval(10, 1, TimeUnit.SECONDS, 1) }

    fun initRTC(context: Context,callType:Int,chanID:String,uid:String){
        rtcEngine = RtcEngine.create(context, ARUILogin.devId,RtcEvent())
//        rtcEngine?.let {
//            it.setParameters("{\"Cmd\":\"ConfPriCloudAddr\", \"ServerAdd\":\"xxx\", \"Port\": 6080}")
//        }
        if (callType==ARUICalling.Type.VIDEO.ordinal){
            rtcEngine?.enableVideo()
        }else{
            rtcEngine?.disableVideo()
        }
        channelId = chanID
        userId = uid

    }

    fun setupLocalVideo(textureView: TextureView){
        rtcEngine?.let {
           launch ({ co->
                delay(200)
                it.setupLocalVideo(
                    VideoCanvas(textureView,
                        Constants.RENDER_MODE_HIDDEN,"","",
                        Constants.VIDEO_MIRROR_MODE_ENABLED)
                )
                it.startPreview()
            })

        }
    }

    fun setupLocalVideo(canvas: VideoCanvas){
        rtcEngine?.let {
            launch ({co->
                it.setupLocalVideo(
                    canvas
                )
                it.startPreview()
            })

        }
    }

    fun setupRemoteVideo(uid:String,textureView: TextureView){
        rtcEngine?.let {
            it.setupRemoteVideo(VideoCanvas(textureView,Constants.RENDER_MODE_FIT,uid))
        }
    }
    fun setupRemoteVideo(videoCanvas: VideoCanvas){
            rtcEngine?.let {
                it.setupRemoteVideo(videoCanvas)
        }

    }

    fun setEnableSpeakerphone(open:Boolean){
        rtcEngine?.setEnableSpeakerphone(open)
    }

    fun joinChannel(){
        rtcEngine?.joinChannel(ARUILogin.rtcToken,channelId,"",userId)
    }

    fun leaveChannel(){
        if (!calledLeave){//
            rtcEngine?.leaveChannel()
            calledLeave = true
        }
    }

    fun muteLocalAudioStream(mute:Boolean){
        rtcEngine?.muteLocalAudioStream(mute)
    }
    fun muteLocalVideoStream(mute:Boolean){
        rtcEngine?.muteLocalVideoStream(mute)
    }

    fun disableVideo(){
        rtcEngine?.disableVideo()
    }

    private inner class RtcEvent :IRtcEngineEventHandler(){

        override fun onJoinChannelSuccess(channel: String?, uid: String?, elapsed: Int) {
            super.onJoinChannelSuccess(channel, uid, elapsed)
            launch ({co->
                joinState.value = 0
                nobodyComing.finish {
                    if (!haveMemberJoin){
                        nobodyComeIn.value = true
                    }
                }.start()
            })
        }

        override fun onFirstRemoteAudioDecoded(uid: String?, elapsed: Int) {
            super.onFirstRemoteAudioDecoded(uid, elapsed)
            launch({
                remoteAudioDecode.value = uid
            })
        }

        override fun onFirstRemoteVideoDecoded(
            uid: String?,
            width: Int,
            height: Int,
            elapsed: Int
        ) {
            super.onFirstRemoteVideoDecoded(uid, width, height, elapsed)
            launch ({
                remoteVideoDecode.value = uid
            })
        }

        override fun onRemoteVideoStats(stats: RemoteVideoStats?) {
            super.onRemoteVideoStats(stats)
        }


        override fun onLocalAudioStats(stats: LocalAudioStats?) {
            super.onLocalAudioStats(stats)

        }
        override fun onRtcStats(stats: RtcStats?) {
            super.onRtcStats(stats)
        }


        override fun onLocalVideoStats(stats: LocalVideoStats?) {
            super.onLocalVideoStats(stats)

        }
        override fun onRemoteVideoStateChanged(
            uid: String?,
            state: Int,
            reason: Int,
            elapsed: Int
        ) {
            super.onRemoteVideoStateChanged(uid, state, reason, elapsed)
            if (reason == 5 || reason ==6){
                launch ({
                    remoteVideoState.value=Pair(uid!!,reason)
                })
            }
        }

        override fun onRemoteAudioStats(stats: RemoteAudioStats?) {
            super.onRemoteAudioStats(stats)
        }

        override fun onRemoteAudioStateChanged(
            uid: String?,
            state: Int,
            reason: Int,
            elapsed: Int
        ) {
            super.onRemoteAudioStateChanged(uid, state, reason, elapsed)
            if (reason == 5 || reason==6){
                launch ({
                    remoteAudioState.value = Pair(uid!!,reason)
                })
            }
        }

        override fun onUserJoined(uid: String?, elapsed: Int) {
            super.onUserJoined(uid, elapsed)
            launch ({
                userJoin.value=uid
                haveMemberJoin = true
                userOfflineInterval.cancel()
            })
        }

        override fun onUserOffline(uid: String?, reason: Int) {
            super.onUserOffline(uid, reason)
            launch ({
                haveMemberJoin = false
                if (reason ==1){//异常 则继续等待10秒 10秒内它还未恢复（【恢复会走】onUserJoin）则离开
                    userOffline.value =1
                    userOfflineInterval.finish {
                        if (it==10L){
                            userOffline.value =-1
                        }
                    }.start()
                }
                //reason 1 正常 2 异常

            })

        }
    }

     fun onCleared() {
         userOfflineInterval.cancel()
         nobodyComing.cancel()
        RtcEngine.destroy()
    }

}
package io.anyrtc.aruicall.view

import android.content.Context
import android.widget.RelativeLayout
import android.view.LayoutInflater
import android.view.TextureView
import android.widget.Toast
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import com.blankj.utilcode.constant.PermissionConstants
import com.blankj.utilcode.util.PermissionUtils
import gone
import io.anyrtc.aruicall.*
import io.anyrtc.aruicall.databinding.*
import io.anyrtc.aruicall.utils.ImageLoader
import kotlinx.coroutines.delay
import launch
import org.ar.rtc.Constants
import org.ar.rtc.RtcEngine
import org.ar.rtc.VideoEncoderConfiguration
import org.ar.rtc.video.VideoCanvas
import org.ar.rtm.LocalInvitation
import org.ar.rtm.RemoteInvitation
import org.json.JSONObject
import java.util.HashMap

open class ARUICallVideoView @JvmOverloads constructor (protected val mContext: Context) :
    BaseTUICallView(mContext), RtmEvents,LifecycleOwner {
    protected var globalVM = GlobalVM.instance
    private var remoteUserId = ""
    private val bindingAudioWait by lazy { LayoutAudioCallWaitBinding.inflate(
        LayoutInflater.from(context),this,false) }
    private val bindingVideoWait by lazy { LayoutVideoCallWaitBinding.inflate(
        LayoutInflater.from(context),this,false) }

    private val bindingAudio by lazy { LayoutAudioCallBinding.inflate( LayoutInflater.from(context),this,false) }
    private val bindingVideo by lazy { LayoutVideoCallBinding.inflate( LayoutInflater.from(context),this,false) }
    private val videoList = HashMap<String, TextureView?>()
    private val mRegistry = LifecycleRegistry(this)
    private var rootView:RelativeLayout
    private val rtcVM = RtcVM()
    init {
       val view=  LayoutInflater.from(mContext).inflate(R.layout.activity_p2_pvideo, this)
       rootView = view.findViewById(R.id.rl_root)
        globalVM.isWaiting = true
        globalVM.curCallModel?.let { curModel->
            if (curModel.role==ARUICalling.Role.CALL){
                PermissionUtils.permission(PermissionConstants.CAMERA,PermissionConstants.MICROPHONE).callback(object :PermissionUtils.FullCallback{
                    override fun onGranted(permissionsGranted: MutableList<String>?) {
                        globalVM.startCallRing()//如果是主动呼叫
                        globalVM.localInvitation?.let {
                            remoteUserId = it.calleeId
                            rtcVM.initRTC(context,curModel.type.ordinal,curModel.groupId,globalVM.userId)
                            showWaitLayout(curModel.role,curModel.type,curModel.users[0].userName,curModel.users[0].headerUrl)
                            globalVM.call()
                        }?:run {
                            finish()
                        }
                    }

                    override fun onDenied(
                        permissionsDeniedForever: MutableList<String>?,
                        permissionsDenied: MutableList<String>?
                    ) {
                        globalVM.curCallModel?.let {
                            rtcVM.inMeeting = false
                            globalVM.isWaiting = false
                            globalVM.isCalling = false
                            globalVM.cancel()
                        }
                        finish()
                    }

                }).request()

            }else{//被呼叫
                PermissionUtils.permission(PermissionConstants.CAMERA,PermissionConstants.MICROPHONE).callback(object :PermissionUtils.FullCallback{
                    override fun onGranted(permissionsGranted: MutableList<String>?) {
                        globalVM.startRing()
                        globalVM.currentRemoteInvitation?.let {
                            remoteUserId = it.callerId
                            rtcVM.initRTC(context,curModel.type.ordinal,curModel.groupId,globalVM.userId)
                            showWaitLayout(curModel.role,curModel.type,if (curModel.users[0].userName.isNullOrEmpty()){curModel.users[0].userId}else{curModel.users[0].userName},curModel.users[0].headerUrl)
                        }?:run {
                            finish()
                        }
                    }

                    override fun onDenied(
                        permissionsDeniedForever: MutableList<String>?,
                        permissionsDenied: MutableList<String>?
                    ) {
                        globalVM.curCallModel?.let {
                            rtcVM.inMeeting = false
                            globalVM.isWaiting = false
                            globalVM.isCalling = false
                            globalVM.cancel()
                        }
                        finish()
                    }

                }).request()

            }
        }
        globalVM.callingUid = remoteUserId
        initOnclick()
        initLiveData()
    }

    override fun finish() {
        super.finish()
        rtcVM.onCleared()
        globalVM.releaseCall()
    }

    private fun initLiveData() {
       rtcVM.joinState.observe(this,{
            if (it==0){
//                binding.chronometer.start()
            }
        })

       rtcVM.remoteVideoDecode.observe(this,{
           globalVM.stopRing()
            setupRemoteVideo(it)
        })

       rtcVM.remoteVideoState.observe(this,{
           bindingVideo.arVideoManager.findCloudView(it.first)?.let { layout->
               layout.setVideoAvailable(it.second == 6)
           }
        })

       rtcVM.nobodyComeIn.observe(this,{
            launch ({
                Toast.makeText(context, "对方网络异常", Toast.LENGTH_SHORT).show()
                    delay(1500)
                    leave(false)
            })
        })
       rtcVM.userOffline.observe(this,{
            if (it == 1){

                Toast.makeText(context, "对方网络异常", Toast.LENGTH_SHORT).show()
            }else{
                launch ({
                    Toast.makeText(context, "对方通话异常", Toast.LENGTH_SHORT).show()
                    delay(1500)
                    leave(false)
                })
            }
        })
        globalVM.callTime.observe(this,{
            bindingAudio.tvTime.text = mContext.getString(R.string.rtccalling_called_time_format, it / 60, it % 60)
            bindingVideo.tvTime.text = mContext.getString(R.string.rtccalling_called_time_format, it / 60, it % 60)
        })


    }

    private fun initOnclick(){
        bindingAudio.run {
            btnAudioMute.setOnClickListener {
                it.isSelected=!it.isSelected
                rtcVM.muteLocalAudioStream(it.isSelected)
            }
            btnHangUp.setOnClickListener {
                leave()
            }
            btnAudioSpeak.setOnClickListener {
                btnAudioSpeak.isSelected = !btnAudioSpeak.isSelected
               rtcVM.setEnableSpeakerphone(btnAudioSpeak.isSelected)
            }
        }

        bindingVideo.run {
            btnAudio.setOnClickListener {
                btnAudio.isSelected = !btnAudio.isSelected
                rtcVM.muteLocalAudioStream(btnAudio.isSelected)
            }
            btnSwitchAudio.setOnClickListener {
                globalVM.sendMessage(remoteUserId,JSONObject().apply {
                    put("Cmd","SwitchAudio")
                }.toString()){
                    if (it){
                        showAudioModel()
                    }else{
                       // showError("切换失败")
                    }
                }
            }
            btnHangUp.setOnClickListener {
                leave()
            }
            btnVideo.setOnClickListener {
                btnVideo.isSelected = !btnVideo.isSelected
                rtcVM.muteLocalVideoStream(btnVideo.isSelected)
                bindingVideo.arVideoManager.findCloudView(globalVM.userId)?.let {
                    it.setVideoAvailable(!btnVideo.isSelected)
                }
            }
            btnSwitchCamera.setOnClickListener {
               rtcVM.rtcEngine?.switchCamera()
            }
            btnSpeak.setOnClickListener {
                btnSpeak.isSelected = !btnSpeak.isSelected
               rtcVM.setEnableSpeakerphone(btnSpeak.isSelected)
            }
        }


    }


    private fun showWaitLayout(role:ARUICalling.Role,type:ARUICalling.Type,userName:String="",headerUrl:String=""){
            if (type == ARUICalling.Type.AUDIO){
                globalVM.curCallModel?.let {
                    bindingAudioWait.run {
                        tvAwName.text = userName
                        bindingAudio.tvAudioName.text = if (it.users[0].userName.isNullOrEmpty()) it.users[0].userId else it.users[0].userName
                        ImageLoader.loadImage(context,bindingAudio.imgAudioHead,headerUrl)
                        ImageLoader.loadImage(context,imgAwHead,headerUrl)
                        if (role == ARUICalling.Role.CALL){
                            globalVM.startCallRing()
                            tvAwState.text="正在等待对方接受邀请"
                            btnAwAccept.gone()
                            btnAwHangUp.text = "挂断"
                            btnAwHangUp.setOnClickListener {
                                globalVM.curCallModel?.let {
                                    rtcVM.inMeeting = false
                                    globalVM.isWaiting = false
                                    globalVM.isCalling = false
                                    globalVM.cancel()
                                }
                                finish()
                            }
                        }else{
                            globalVM.startRing()
                            tvAwState.text="邀请您进行语音通话"
                            btnAwHangUp.text="拒接"
                            btnAwHangUp.setOnClickListener {
                                globalVM.curCallModel?.let {
                                    rtcVM.inMeeting = false
                                    globalVM.isWaiting = false
                                    globalVM.isCalling = false
                                    globalVM.currentRemoteInvitation?.let {
                                        globalVM.refuse(it)
                                    }
                                    finish()
                                }
                            }
                            btnAwAccept.setOnClickListener {
                                globalVM.curCallModel?.let {calModel->
                                    globalVM.currentRemoteInvitation?.let {
                                        globalVM.accept(it,calModel.content)
                                    }
                                }
                            }
                        }
                        rootView.addView(bindingAudioWait.root)
                    }

                }
            }else{
                globalVM.curCallModel?.let {
                    bindingVideoWait.run {
                        val localPreview = RtcEngine.CreateRendererView(context)
                        rtcVM.setupLocalVideo(localPreview)
                        rlVwPreview.addView(localPreview,0)
                        tvVwName.text = userName
                        ImageLoader.loadImage(context,ivVwHead,headerUrl)
                        if (role == ARUICalling.Role.CALL){
                            globalVM.startCallRing()
                            btnVwAccept.gone()
                            btnVwSwitchAudio.gone()
                            btnVwHangUp.text="挂断"
                            tvVwState.text="正在等待对方接受邀请"
                            btnVwHangUp.setOnClickListener {
                                globalVM.curCallModel?.let {
                                    rtcVM.inMeeting = false
                                    globalVM.isWaiting = false
                                    globalVM.isCalling = false
                                    globalVM.cancel()
                                }
                                finish()
                            }
                        }else{
                            globalVM.startRing()
                            tvVwState.text="邀请您进行视频通话"
                            btnVwHangUp.text="拒接"
                            btnVwHangUp.setOnClickListener {
                                globalVM.curCallModel?.let {
                                    rtcVM.inMeeting = false
                                    globalVM.isWaiting = false
                                    globalVM.isCalling = false
                                    globalVM.currentRemoteInvitation?.let {
                                        globalVM.refuse(it)
                                    }
                                    finish()
                                }
                            }
                            btnVwAccept.setOnClickListener {
                                globalVM.curCallModel?.let {calModel->
                                    globalVM.currentRemoteInvitation?.let {
                                        globalVM.accept(it,calModel.content)
                                    }
                                }
                            }
                            btnVwSwitchAudio.setOnClickListener {
                                globalVM.curCallModel?.let {
                                    it.type = ARUICalling.Type.AUDIO
                                    val newContent = JSONObject().apply {
                                        put("Mode", ARUICalling.Type.AUDIO.ordinal) //更改后的模式
                                        put("Conference", false)
                                        put("UserData", "")
                                        put("SipData", "")
                                    }.toString()
                                    it.content = newContent
                                    globalVM.currentRemoteInvitation?.let {
                                        globalVM.accept(it,newContent)
                                    }
                                }
                                rlVwPreview.removeAllViews()
                                rtcVM.disableVideo()
                            }
                        }
                        rootView.addView(bindingVideoWait.root)
                    }
                }

            }
    }


    private fun showAudioModel(){
        rootView.removeView(bindingVideo.root)
        rootView.addView(bindingAudio.root)
        globalVM.curCallModel?.let {
            bindingAudio.tvAudioName.text = if (it.users[0].userName.isNullOrEmpty()) it.users[0].userId else it.users[0].userName
            ImageLoader.loadImage(context,bindingAudio.imgAudioHead,it.users[0].headerUrl)
        }
        rtcVM.disableVideo()
        bindingVideo.btnSpeak.isSelected = false
        rtcVM.setEnableSpeakerphone(false)
        bindingVideo.arVideoManager.releaseAllVideoView()
        globalVM.curCallModel?.type = ARUICalling.Type.AUDIO
        Toast.makeText(context, "声音将通过听筒播放", Toast.LENGTH_SHORT).show()
    }
    private fun leave(needSendMessage:Boolean = true){
        if (needSendMessage) {
            globalVM.sendMessage(remoteUserId, JSONObject().apply {
                put("Cmd", "EndCall")
            }.toString()) {}
        }
       rtcVM.inMeeting = false
       rtcVM.leaveChannel()
        if (globalVM.curCallModel?.type == ARUICalling.Type.VIDEO){
            bindingVideo.arVideoManager.releaseAllVideoView()
        }
        if (globalVM.curCallModel?.role==ARUICalling.Role.CALL) {//这里本可以不调用 但如果是断网重连进来的就需要再取消一下 否则下次无法再呼叫
            globalVM.cancel()
        }
        finish()
    }

    private fun joinRTC(infoJSON:JSONObject){
        rootView.removeView(bindingAudioWait.root)
        rootView.removeView(bindingVideoWait.root)
        if (globalVM.curCallModel?.type == ARUICalling.Type.AUDIO){
            rootView.addView(bindingAudio.root,0)
        }else{
            rootView.addView(bindingVideo.root,0)
        }
        var watchParams = ""
        var vidCodec = ""
        var audCodec = ""

        //-----------------这一堆是为了适配手表⌚️---------------
        if (!infoJSON.isNull("VidCodec")){
            vidCodec = infoJSON.getString("VidCodec")
        }
        if (!infoJSON.isNull("AudCodec")){
            audCodec = infoJSON.getString("AudCodec")
        }
        if (!infoJSON.isNull("Parameters")){
            watchParams = infoJSON.getString("Parameters")
        }
        var isAppOrWeb = vidCodec.isNullOrEmpty()||vidCodec.contains("H264")||audCodec.isNullOrEmpty()||audCodec.contains("Opus")
        //-----------------这一堆是为了适配手表⌚️---------------
        globalVM.isWaiting = false
        globalVM.isCalling = true
            if (globalVM.curCallModel?.type ==ARUICalling.Type.AUDIO) {
                bindingAudio.run {
                    globalVM.curCallModel?.let {
                       tvAudioName.text = if (it.users[0].userName.isNullOrEmpty()) it.users[0].userId else it.users[0].userName
                        ImageLoader.loadImage(context,imgAudioHead,it.users[0].headerUrl)
                    }
                }
                Toast.makeText(context, "声音将通过听筒播放", Toast.LENGTH_SHORT).show()
                bindingVideo.btnSpeak.isSelected = false
               rtcVM.setEnableSpeakerphone(false)
            } else {
                bindingVideo.run {
                    setupLocalVideo()
                    Toast.makeText(context, "声音将通过扬声器播放", Toast.LENGTH_SHORT).show()
                    btnSpeak.isSelected = true
                    rtcVM.setEnableSpeakerphone(true)
                    if (!isAppOrWeb){//如果是⌚️
                       rtcVM.rtcEngine?.setParameters("{\"Cmd\":\"SetEncoderType\", \"VidCodecType\": 5, \"AudCodecType\": 3}")
                        watchParams?.let {
                            val json = JSONObject(it)
                            val width = json.getInt("Width")
                            val height = json.getInt("Height")
                            val fps = json.getInt("Fps")
                            val configuration = VideoEncoderConfiguration()
                            configuration.dimensions =
                                VideoEncoderConfiguration.VideoDimensions(width, height)
                            configuration.bitrate = 128
                            configuration.minBitrate = 128
                            configuration.frameRate = fps
                            configuration.minFrameRate = 1
                           rtcVM.rtcEngine?.setVideoEncoderConfiguration(configuration)
                        }
                    }
                }
            }
       rtcVM.joinChannel()

    }

    private fun setupLocalVideo() {
        bindingVideo.arVideoManager.setMySelfUserId(globalVM.userId,globalVM.curCallModel?.type)
        var layout = bindingVideo.arVideoManager.findCloudView(globalVM.userId)
        if (layout==null){
            layout = bindingVideo.arVideoManager.allocCloudVideoView(globalVM.userId)
        }
        rtcVM.setupLocalVideo(VideoCanvas(layout.videoView))
    }

    private fun setupRemoteVideo(uid: String) {
        var layout = bindingVideo.arVideoManager.findCloudView(uid)
        if (layout==null){
            layout = bindingVideo.arVideoManager.allocCloudVideoView(uid)
        }
        rtcVM.setupRemoteVideo(VideoCanvas(layout.videoView,Constants.RENDER_MODE_HIDDEN,uid))
    }

    override fun onLocalInvitationRefused(var1: LocalInvitation?, var2: String?) {
        super.onLocalInvitationRefused(var1, var2)
        if(var2.isNullOrEmpty()){
                Toast.makeText(context,"对方拒绝通话",Toast.LENGTH_SHORT).show()
            }else{
                val reasonJSON = JSONObject(var2)
                if (reasonJSON.has("Cmd")){
                    val reason = reasonJSON.getString("Cmd")
                    if (reason=="Calling"){
                        Toast.makeText(context,"对方正忙",Toast.LENGTH_SHORT).show()
                    }
                }else{
                    Toast.makeText(context,"对方拒绝通话",Toast.LENGTH_SHORT).show()
                }
            }
            finish()
    }

    override fun onLocalInvitationAccepted(var1: LocalInvitation?, var2: String?) {
        super.onLocalInvitationAccepted(var1, var2)
            val infoJSON = JSONObject(var2)
            val callMode = infoJSON.getInt("Mode")//这里还需要获取一下通话模式 因为对方可以语音接听
            globalVM.curCallModel?.type = ARUICalling.Type.values()[callMode]
            joinRTC(infoJSON)

    }

    override fun onLocalInvitationCanceled(var1: LocalInvitation?) {
        super.onLocalInvitationCanceled(var1)
            finish()
    }

    override fun onLocalInvitationFailure(var1: LocalInvitation?, var2: Int) {
        super.onLocalInvitationFailure(var1, var2)
           rtcVM.inMeeting = false
            Toast.makeText(context,"对方未能接通呼叫",Toast.LENGTH_SHORT).show()
            finish()
    }

    override fun onRemoteInvitationAccepted(var1: RemoteInvitation?) {
        super.onRemoteInvitationAccepted(var1)
            joinRTC(JSONObject(var1?.content))
    }


    override fun onRemoteInvitationRefused(var1: RemoteInvitation?) {
        super.onRemoteInvitationRefused(var1)
            if (globalVM.isCalling||globalVM.isWaiting){

            }else{
               rtcVM.inMeeting = false
                finish()
            }
    }

    override fun onRemoteInvitationCanceled(var1: RemoteInvitation?) {
        super.onRemoteInvitationCanceled(var1)
        rtcVM.inMeeting = false
        Toast.makeText(context,"对方已取消呼叫",Toast.LENGTH_SHORT).show()
        finish()
    }

    override fun onRemoteInvitationFailure(var1: RemoteInvitation?, var2: Int) {
        super.onRemoteInvitationFailure(var1, var2)
        rtcVM.inMeeting = false
        Toast.makeText(context,"接受呼叫邀请失败",Toast.LENGTH_SHORT).show()
        finish()
    }



    override fun onMsgEndCall() {
        super.onMsgEndCall()
        Toast.makeText(context,"对方已挂断", Toast.LENGTH_SHORT).show()
        leave(false)
    }

    override fun onSwitchToAudio() {
        super.onSwitchToAudio()
        showAudioModel()
    }
    override fun getLifecycle(): Lifecycle {

        return mRegistry
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        globalVM.register(this)
        GlobalVM.instance.isInP2pCall = true
        mRegistry.currentState = Lifecycle.State.CREATED
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        globalVM.unRegister()
        GlobalVM.instance.isInP2pCall = false
        mRegistry.currentState = Lifecycle.State.DESTROYED
    }

    override fun initView() {
    }

    override fun onWindowVisibilityChanged(visibility: Int) {
        super.onWindowVisibilityChanged(visibility)
        if (visibility == VISIBLE) {
            mRegistry.handleLifecycleEvent(Lifecycle.Event.ON_START)
            mRegistry.handleLifecycleEvent(Lifecycle.Event.ON_RESUME)
        }else if (visibility == GONE || visibility == INVISIBLE){
            mRegistry.handleLifecycleEvent(Lifecycle.Event.ON_PAUSE)
            mRegistry.handleLifecycleEvent(Lifecycle.Event.ON_STOP)
        }
    }

    override fun onFinish() {
        super.onFinish()
        finish()
        globalVM.releaseCall()
    }
}
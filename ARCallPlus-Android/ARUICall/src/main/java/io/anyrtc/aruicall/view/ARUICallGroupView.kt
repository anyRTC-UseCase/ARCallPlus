package io.anyrtc.aruicall.view

import android.content.Context
import android.view.LayoutInflater
import android.widget.*
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import com.blankj.utilcode.constant.PermissionConstants
import com.blankj.utilcode.util.PermissionUtils
import gone
import io.anyrtc.aruicall.*
import io.anyrtc.aruicall.GlobalVM
import io.anyrtc.aruicall.RtcVM
import io.anyrtc.aruicall.databinding.LayoutGroupCallBinding
import io.anyrtc.aruicall.databinding.LayoutRecivedGroupCallBinding
import io.anyrtc.aruicall.utils.ImageLoader
import org.ar.rtc.Constants
import org.ar.rtc.video.VideoCanvas
import org.ar.rtm.LocalInvitation
import org.ar.rtm.RemoteInvitation
import org.ar.rtm.RtmChannelMember

open class ARUICallGroupView @JvmOverloads constructor(
    mContext: Context
) : BaseTUICallView(mContext), RtmEvents, LifecycleOwner,ARTCGroupVideoLayoutManager.UserNoResponseListener {
    protected var globalVM: GlobalVM
    protected var rtcVM = RtcVM()
    private val mRegistry = LifecycleRegistry(this)
    private val localInvitationList: ArrayList<LocalInvitation> = ArrayList()
    private var callArray: MutableList<ARCallUser>?=null
    private var channelId: String = ""
    private var isCalled: Boolean = false
    private var role = ARUICalling.Role.CALLED
    private var type = ARUICalling.Type.VIDEO
    private var remoteId=""
    private var remoteName=""
    private var sendContent = ""
    private var isWaiting = false//是否在呼叫响铃页面
    private var rootView:RelativeLayout
    private val bindingReceive by lazy {
        LayoutRecivedGroupCallBinding.inflate(
            LayoutInflater.from(context), this, false
        )
    }
    private val bindingVideo by lazy {
        LayoutGroupCallBinding.inflate(
            LayoutInflater.from(context), this, false
        )
    }

    init {
        val view = LayoutInflater.from(mContext).inflate(R.layout.activity_group_video, this)
        rootView = view.findViewById(R.id.rl_group_root)
        globalVM = GlobalVM.instance
        globalVM.curCallModel?.let {
            callArray = it.users
            channelId = it.groupId
            isCalled = it.role == ARUICalling.Role.CALLED
            sendContent = it.content
            role = it.role
            type = it.type
            remoteId = it.callerId
            remoteName = it.callerName
        }
        PermissionUtils.permission(PermissionConstants.CAMERA, PermissionConstants.MICROPHONE).callback(object :PermissionUtils.FullCallback{
            override fun onGranted(permissionsGranted: MutableList<String>?) {
                rtcVM.initRTC(context, type.ordinal, channelId, globalVM.userId)
                if (role==ARUICalling.Role.CALL){
                    globalVM.startCallRing()
                    initVideoLayout()
                }else{
                    globalVM.startRing()
                    initWaitLayout()
                }
                globalVM.joinRTMChannel(channelId)
            }

            override fun onDenied(
                permissionsDeniedForever: MutableList<String>?,
                permissionsDenied: MutableList<String>?
            ) {
               if (role == ARUICalling.Role.CALLED){
                   globalVM.currentRemoteInvitation?.let {
                       globalVM.refuse(it)
                       globalVM.leaveRtmChannel()
                   }
               }else{
                       localInvitationList.forEach {
                           globalVM.cancel(it)
                       }
                    globalVM.leaveRtmChannel()
               }
                finish()
            }

        }).request()

    }

    private fun initVideoLayout(){

        bindingVideo.run {
            if (type == ARUICalling.Type.AUDIO){
                btnVideo.gone()
                btnSwitchCamera.gone()
                btnSwitchAudio.gone()
                tvTime.setTextColor(context.resources.getColor(R.color.calling_color_second))
                btnSpeak.setTextColor(context.resources.getColor(R.color.calling_color_second))
                btnHangUp.setTextColor(context.resources.getColor(R.color.calling_color_second))
                btnAudio.setTextColor(context.resources.getColor(R.color.calling_color_second))
                llRoot.setBackgroundColor(context.resources.getColor(R.color.calling_color_audiocall_background))
            }else{
                tvTime.setTextColor(context.resources.getColor(R.color.white))
                btnSpeak.setTextColor(context.resources.getColor(R.color.white))
                btnAudio.setTextColor(context.resources.getColor(R.color.white))
                btnVideo.setTextColor(context.resources.getColor(R.color.white))
                btnHangUp.setTextColor(context.resources.getColor(R.color.white))
                btnSwitchAudio.setTextColor(context.resources.getColor(R.color.white))
                llRoot.setBackgroundColor(context.resources.getColor(R.color.calling_color_videocall_background))
            }
        }
        bindingVideo.arVideoManager.setNoResponseListener(this)
        bindingVideo.arVideoManager.setMySelfUserId(globalVM.userId,globalVM.curCallModel?.type)
        var layout = bindingVideo.arVideoManager.findVideoCallLayout(globalVM.userId)
        if (layout==null){
            layout = bindingVideo.arVideoManager.allocVideoCallLayout(globalVM.userId,false)
        }
        layout.setUserName(ARUILogin.selfModel?.userName)
        layout.setHeaderUrl(ARUILogin.selfModel?.headerUrl)
        if (role==ARUICalling.Role.CALL){
                rtcVM.joinChannel()
                callArray?.forEach {
                    bindingVideo.arVideoManager.allocVideoCallLayout(it.userId,false).apply {
                        setUserName(it.userName)
                        setHeaderUrl(it.headerUrl)
                        startLoading()
                    }
                    if (!isCalled) {
                        val localInvitation = globalVM.rtmCallManager.createLocalInvitation(it.userId)?.apply {
                            this.content = sendContent
                        }
                        localInvitationList.add(localInvitation!!)
                        globalVM.call(localInvitation)
                    }
                }
        }else{
            rootView.removeView(bindingReceive.root)
            callArray?.forEach {
                bindingVideo.arVideoManager.allocVideoCallLayout(it.userId,true).apply {
                    setUserName(it.userName)
                    setHeaderUrl(it.headerUrl)
                    startLoading()
                }
            }
            rtcVM.joinChannel()
        }
        bindingVideo.btnSpeak.isSelected = !bindingVideo.btnSpeak.isSelected
        rtcVM.setEnableSpeakerphone( bindingVideo.btnSpeak.isSelected)
        isWaiting = false
        rootView.addView(bindingVideo.root)
        initCallLayoutOnclick()
    }

    private fun initWaitLayout(){

        bindingReceive.run {
            isWaiting = true
            if (type == ARUICalling.Type.VIDEO){
                rlRoot.setBackgroundColor(context.resources.getColor(R.color.calling_color_videocall_background))
                tvState.text = "邀请您视频通话..."
                btnHangUp.setTextColor(context.resources.getColor(R.color.white))
                btnAccept.setTextColor(context.resources.getColor(R.color.white))
            }else{
                rlRoot.setBackgroundColor(context.resources.getColor(R.color.calling_color_audiocall_background))
                tvState.text = "邀请您语音通话..."
                tvState.setTextColor(context.resources.getColor(R.color.calling_color_second))
                btnHangUp.setTextColor(context.resources.getColor(R.color.calling_color_second))
                btnAccept.setTextColor(context.resources.getColor(R.color.calling_color_second))
            }
            tvCallerName.text = if (remoteName.isNullOrEmpty()){remoteId}else{remoteName}
            val squareWidth =
                resources.getDimensionPixelOffset(R.dimen.rtccalling_small_image_size)
            val margin =
                resources.getDimensionPixelOffset(R.dimen.rtccalling_small_image_left_margin)
            callArray?.forEachIndexed { index, s ->
                llRemoteUser.addView(ImageView(context).apply {
                    layoutParams = LinearLayout.LayoutParams(squareWidth,squareWidth).apply {
                        if (index!=0){
                            leftMargin = margin
                        }
                    }
                    ImageLoader.loadImage(context,this,s.headerUrl)
                })
            }
            btnAccept.setOnClickListener {
                globalVM.currentRemoteInvitation?.let {
                    globalVM.accept(it)
                    initVideoLayout()
                }
            }
            btnHangUp.setOnClickListener {
                globalVM.currentRemoteInvitation?.let {
                    globalVM.refuse(it)
                    globalVM.leaveRtmChannel()
                }
                finish()
            }
        }
        rootView.addView(bindingReceive.root)
    }


    override fun initView() {

    }

    private fun initLiveData() {
        rtcVM.joinState.observe(this, {
            rtcVM.inMeeting = true
                bindingVideo.arVideoManager.findVideoCallLayout(globalVM.userId)?.let {
                    if (type == ARUICalling.Type.VIDEO) {
                        it.setVideoAvailable(true)
                        rtcVM.setupLocalVideo(
                            VideoCanvas(
                                it.videoView,
                                Constants.RENDER_MODE_HIDDEN,
                                globalVM.userId
                            )
                        )
                    }
                    it.muteMic(false)
                }

        })
        rtcVM.remoteVideoDecode.observe(this, { uid ->
            bindingVideo.arVideoManager.findVideoCallLayout(uid)?.let {
                it.stopLoading()
                it.stopInterval()
            }
        })
        rtcVM.remoteAudioDecode.observe(this,{uid->
            bindingVideo.arVideoManager.findVideoCallLayout(uid)?.let {
                it.stopLoading()
                it.stopInterval()
            }
        })
        rtcVM.userJoin.observe(this, { userId->
            globalVM.stopRing()
            bindingVideo.arVideoManager.findVideoCallLayout(userId)?.let {
                it.stopInterval()
                if (type==ARUICalling.Type.VIDEO) {
                        rtcVM.setupRemoteVideo(VideoCanvas(it.videoView,Constants.RENDER_MODE_HIDDEN,userId))
               }
            }
        })

        rtcVM.remoteVideoState.observe(this, {
            bindingVideo.arVideoManager.findVideoCallLayout(it.first)?.let {user->
                if (it.second == Constants.REMOTE_VIDEO_STATE_REASON_REMOTE_MUTED) {
                    user.setVideoAvailable(false)
                    } else if (it.second == Constants.REMOTE_VIDEO_STATE_REASON_REMOTE_UNMUTED) {
                    user.setVideoAvailable(true)
                    }
            }
        })

        rtcVM.remoteAudioState.observe(this, {
            bindingVideo.arVideoManager.findVideoCallLayout(it.first)?.let {user->
                if (it.second == Constants.REMOTE_AUDIO_REASON_REMOTE_MUTED) {
                    user.muteMic(true)
                } else if (it.second == Constants.REMOTE_AUDIO_REASON_REMOTE_UNMUTED) {
                    user.muteMic(false)
                }
            }
        })

        globalVM.callTime.observe(this,{
            bindingVideo.tvTime.text = context.getString(R.string.rtccalling_called_time_format, it / 60, it % 60)
        })
    }

    fun initCallLayoutOnclick() {
        bindingVideo.run {
            btnSwitchCamera.setOnClickListener {
                rtcVM.rtcEngine?.switchCamera()
            }
            btnHangUp.setOnClickListener {
                if (!isCalled) {
                    localInvitationList.forEach {
                        globalVM.cancel(it)
                    }
                }
                globalVM.leaveRtmChannel()
                finish()
            }
            btnAudio.setOnClickListener {
                btnAudio.isSelected = !btnAudio.isSelected
                rtcVM.rtcEngine?.enableLocalAudio(!btnAudio.isSelected)
                arVideoManager.findVideoCallLayout(globalVM.userId)?.let {
                    it.muteMic(btnAudio.isSelected)
                }
            }
            btnSpeak.setOnClickListener {
                btnSpeak.isSelected = !btnSpeak.isSelected
                rtcVM.setEnableSpeakerphone(btnSpeak.isSelected)
            }
            btnVideo.setOnClickListener {
                btnVideo.isSelected = !btnVideo.isSelected
                rtcVM.rtcEngine?.enableLocalVideo(!btnVideo.isSelected)
                arVideoManager.findVideoCallLayout(globalVM.userId)?.let {
                    it.setVideoAvailable(!btnVideo.isSelected)
                }
            }
            btnInvite.setOnClickListener {
               // invite()
            }
        }
    }

    private fun invite() {
//        val inviteBinding = DialogInviteBinding.inflate(LayoutInflater.from(context), this, false)
//        CustomDialog.show(object : OnBindView<CustomDialog>(inviteBinding.root) {
//            override fun onBind(dialog: CustomDialog?, v: View?) {
//                inviteBinding.tvInviteConfirm.setOnClickListener {
//
//
//                    if (callArray?.find { it.userId == inviteBinding.etUser.text.toString() }!=null) {
//                        toast("用户已在通话中")
//                        return@setOnClickListener
//                    }
//                    dialog?.dismiss()
//                    globalVM.queryOnline(inviteBinding.etUser.text.toString()) {
//                        if (it) {
//                            bindingVideo.arVideoManager.allocVideoCallLayout(inviteBinding.etUser.text.toString())
//                            callArray?.add(ARCallUser(inviteBinding.etUser.text.toString()))
//                            val params = JSONObject()
//                            val arr = JSONArray()
//                            arr.put(globalVM.userId)
//                            params.put("Mode", 0)
//                            params.put("Conference", true)
//                            params.put("ChanId", channelId)
//                            callArray?.forEach {
//                                arr.put(it)
//                            }
//                            params.put("UserData", arr)
//                            val localInvitation =
//                                globalVM.rtmCallManager.createLocalInvitation(inviteBinding.etUser.text.toString())
//                            localInvitation?.content = params.toString()
//                            localInvitationList.add(localInvitation!!)
//                            globalVM.call(localInvitation)
//                            dialog?.dismiss()
//                        } else {
//                            toast("对方不在线")
//                        }
//                    }
//                }
//                inviteBinding.tvInviteCancel.setOnClickListener {
//                    dialog?.dismiss()
//                }
//            }
//        }).setMaskColor(Color.parseColor("#B2000000")).setCancelable(false);
    }

    fun toast(msg: String) {
        Toast.makeText(context, msg, Toast.LENGTH_SHORT).show()
    }


    override fun finish() {
        super.finish()
        rtcVM.onCleared()
        globalVM.releaseCall()
    }

    override fun getLifecycle(): Lifecycle {
        return mRegistry
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        initLiveData()
        GlobalVM.instance.isInGroupCall = true
        globalVM.register(this)
        mRegistry.currentState = Lifecycle.State.CREATED
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        GlobalVM.instance.isInGroupCall = false
        globalVM.unRegister()
        mRegistry.currentState = Lifecycle.State.DESTROYED
    }

    override fun onMemberJoined(member: RtmChannelMember?) {
        super.onMemberJoined(member)
        if ( callArray!!.find { it.userId==member?.userId.toString() }==null) {
            bindingVideo.arVideoManager.allocVideoCallLayout(member?.userId.toString(),true)
            callArray?.add(ARCallUser(member?.userId.toString()))//邀请的人可能是
        }
    }

    override fun onMemberLeft(member: RtmChannelMember?) {
        super.onMemberLeft(member)
        removeMember(member?.userId.toString())
    }

    private fun removeMember(userId: String) {
        callArray?.find { it.userId==userId }?.let {
            callArray?.remove(it)
        }
        bindingVideo.arVideoManager.recyclerVideoCallLayout(userId)
        if (bindingVideo.arVideoManager.count==1){
            globalVM.leaveRtmChannel()
            toast("通话已结束")
            finish()
        }
    }


    override fun onRemoteInvitationCanceled(var1: RemoteInvitation?) {
        super.onRemoteInvitationCanceled(var1)
        toast("主叫已取消呼叫")
        finish()
    }

    override fun onRemoteInvitationFailure(var1: RemoteInvitation?, var2: Int) {
        super.onRemoteInvitationFailure(var1, var2)
        toast("接受呼叫邀请失败")
        finish()
    }

    override fun onLocalInvitationAccepted(var1: LocalInvitation?, var2: String?) {
        super.onLocalInvitationAccepted(var1, var2)
        localInvitationList.remove(var1)
    }

    override fun onLocalInvitationCanceled(var1: LocalInvitation?) {
        super.onLocalInvitationCanceled(var1)
        localInvitationList.remove(var1)
    }

    override fun onLocalInvitationFailure(var1: LocalInvitation?, var2: Int) {
        super.onLocalInvitationFailure(var1, var2)
        localInvitationList.remove(var1)
        removeMember(var1!!.calleeId)
    }

    override fun onLocalInvitationRefused(var1: LocalInvitation?, var2: String?) {
        super.onLocalInvitationRefused(var1, var2)
        toast("${var1?.calleeId}拒绝了呼叫邀请")
        removeMember(var1?.calleeId.toString())
        localInvitationList.remove(var1)
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
    }

    override fun noResponse(userId: String?) {
        userId?.let {
            removeMember(userId)
        }
    }
}
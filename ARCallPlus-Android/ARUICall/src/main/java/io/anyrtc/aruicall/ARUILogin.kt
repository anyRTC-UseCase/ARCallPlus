package io.anyrtc.aruicall

import android.content.Context
import android.text.TextUtils
import io.anyrtc.aruicall.ARCallUser
import io.anyrtc.aruicall.GlobalVM
import org.ar.rtm.ErrorInfo
import org.ar.rtm.ResultCallback
import java.lang.RuntimeException

object ARUILogin {
    internal var devId = ""
    internal var userId = ""
    internal var rtmToken = ""
    internal var rtcToken = ""
    internal var selfModel:ARCallUser? = null

    fun init(context: Context,appId:String,rtmToken:String="",rtcToken:String=""){
        if (TextUtils.isEmpty(appId)){
            throw RuntimeException("未配置appId")
        }
        this.devId = appId
        this.rtmToken = rtmToken
        this.rtcToken = rtcToken
        GlobalVM.instance.initSDK(appId,context)
    }

    fun unInit(){
        devId = ""
        GlobalVM.instance.unInit()
    }

    fun login(arCallUser: ARCallUser, callback: ResultCallback<Void>){
        if (TextUtils.isEmpty(arCallUser.userId)){
             throw RuntimeException("登录未写userId")
        }
        GlobalVM.instance.login(arCallUser.userId,object :ResultCallback<Void>{
            override fun onSuccess(var1: Void?) {
                selfModel = arCallUser
                userId = arCallUser.userId
                callback.onSuccess(var1)
            }

            override fun onFailure(var1: ErrorInfo?) {
                callback.onFailure(var1)
            }

        })
    }

    fun logout(){
        GlobalVM.instance.logout()
        userId = ""
        selfModel = null
    }

    fun getSelf() = selfModel


}
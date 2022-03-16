package io.anyrtc.aruicall

import android.content.Context
import android.view.View

abstract class ARUICalling {
    enum class Type{
        VIDEO,AUDIO
    }
    enum class Role{
        CALL,CALLED
    }
    enum class Event{
        CALL_START,CALL_SUCCEED,CALL_END,CALL_FAILED,CALL_LOGOUT
    }

    abstract fun call(user:ARCallUser,type:Type)

    abstract fun call(users:Array<ARCallUser>,type:Type)

    abstract fun setCallingListener(listener: ARUICallingListener)

    abstract fun setCallingBell(filePath: String)

    abstract fun enableMuteMode(enable: Boolean)

    abstract fun enableFloatWindow(enable: Boolean)

    abstract fun enableCustomViewRoute(enable: Boolean)

    interface ARUICallingListener{

        fun shouldShowOnCallView(): Boolean

        fun onCallStart(users: Array<ARCallUser>, type: Type, role: Role, tuiCallingView: View?)

        fun onCallEnd(users: Array<ARCallUser>, type: Type, role: Role, totalTime: Long)

        fun onCallEvent(event: Event, type: Type, role: Role, message: String?)

        fun onPushToOfflineUser(users: Array<ARCallUser>, type: Type)

    }

    companion object : SingletonHolder<ARUICalling, Context, (() -> Unit)?>(::ARUICallingImpl)

}

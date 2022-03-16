package io.anyrtc.aruicall


 data class CurCallModel(
     var users:MutableList<ARCallUser> = mutableListOf()
    , var type:ARUICalling.Type = ARUICalling.Type.VIDEO
    , val role:ARUICalling.Role = ARUICalling.Role.CALL
    , val groupId:String=""
    , val isGroup:Boolean = false
    , var content:String="",var callerId:String="",var selfId:String="",var callerName:String=""){


    fun getUserIdArray():Array<String>{
        val array = mutableListOf<String>()
        users.forEach {
            array.add(it.userId)
        }
        return array.toTypedArray()
    }
}

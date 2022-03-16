package io.anyrtc.aruicall

open class SingletonHolder<out T, in A, in B>(creator: (A, B?) -> T) {
    private var creator: ((A, B?) -> T)? = creator
    @Volatile
    private var instance: T? = null

    fun getInstance(arg: A, b: B? = null): T {
        val i = instance
        if (i != null) {
            return i
        }

        return synchronized(this) {
            val i2 = instance
            if (i2 != null) {
                i2
            } else {
                val created = creator!!(arg, b)
                instance = created
                creator = null
                created
            }
        }
    }
}

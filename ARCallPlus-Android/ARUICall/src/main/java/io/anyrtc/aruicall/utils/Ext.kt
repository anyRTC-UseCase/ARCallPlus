
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.fragment.app.Fragment
import kotlinx.coroutines.*
import java.net.SocketTimeoutException
import kotlin.coroutines.CoroutineContext
import kotlin.math.roundToInt
import android.content.ComponentName

import android.text.TextUtils

import android.content.pm.ResolveInfo
import android.content.res.Resources
import android.os.Build
import android.util.TypedValue
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.RelativeLayout
import androidx.annotation.ColorInt
import androidx.annotation.ColorRes


fun Activity.toast(text:String){
    Toast.makeText(this,text,Toast.LENGTH_SHORT).show()
}

fun Fragment.toast(text:String){
    Toast.makeText(activity,text,Toast.LENGTH_SHORT).show()
}

fun<T> Activity.go(clazz: Class<T>){
    startActivity(Intent().apply {
        setClass(this@go,clazz)
    })
}


fun<T> Activity.goAndFinish(clazz: Class<T>){
    startActivity(Intent().apply {
        setClass(this@goAndFinish,clazz)
        finish()
    })
}

fun View.gone(){
    this.visibility = View.GONE
}

fun View.show(){
    this.visibility = View.VISIBLE
}

fun Float.dp2px(context: Context):Int{
    return (0.5f + this * context.resources.displayMetrics.density).roundToInt()
}


/**
 * 默认主线程的协程
 */
fun launch(
    block: suspend (CoroutineScope) -> Unit,
    error_: ((e: Throwable) -> Unit)? = null,
    context: CoroutineContext = Dispatchers.Main
) = GlobalScope.launch(context + CoroutineExceptionHandler { _, e ->
    error_?.let { it(e) }
}) {
    try {
        block(this)
    } catch (e: Exception) {
        e.printStackTrace()
        if (e is SocketTimeoutException) {
        }
        error_?.let { it(e) }
    }
}


fun <T> Boolean?.matchValue(valueTrue: T, valueFalse: T): T {
    return if (this == true) valueTrue else valueFalse
}

fun getPackageContext(context: Context, packageName: String?): Context? {
    var pkgContext: Context? = null
    if (context.getPackageName().equals(packageName)) {
        pkgContext = context
    } else {
        try {
            pkgContext = context.createPackageContext(
                packageName, Context.CONTEXT_IGNORE_SECURITY
                        or Context.CONTEXT_INCLUDE_CODE
            )
        } catch (e: PackageManager.NameNotFoundException) {
            e.printStackTrace()
        }
    }
    return pkgContext
}

fun getAppOpenIntentByPackageName(context: Context, packageName: String): Intent? {
    var mainAct: String? = null
    // 根据包名寻找MainActivity
    val pkgMag = context.packageManager
    val intent = Intent(Intent.ACTION_MAIN)
    intent.addCategory(Intent.CATEGORY_LAUNCHER)
    intent.flags = Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED or Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT
    val list = pkgMag.queryIntentActivities(
        intent,
        PackageManager.GET_ACTIVITIES
    )
    for (i in list.indices) {
        val info = list[i]
        if (info.activityInfo.packageName == packageName) {
            mainAct = info.activityInfo.name
            break
        }
    }
    if (TextUtils.isEmpty(mainAct)) {
        return null
    }
    intent.component = ComponentName(packageName, mainAct!!)
    return intent
}


private const val COLOR_TRANSPARENT = 0
fun Activity.immersiveRes(@ColorRes color: Int, darkMode: Boolean? = null) =
    immersive(resources.getColor(color), darkMode)

fun Activity.immersive(@ColorInt color: Int = COLOR_TRANSPARENT, darkMode: Boolean? = null) {
    when {
        Build.VERSION.SDK_INT >= 21 -> {
            when (color) {
                COLOR_TRANSPARENT -> {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
                    var systemUiVisibility = window.decorView.systemUiVisibility
                    systemUiVisibility = systemUiVisibility or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    systemUiVisibility = systemUiVisibility or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    window.decorView.systemUiVisibility = systemUiVisibility
                    window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
                    window.statusBarColor = color
                }
                else -> {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
                    var systemUiVisibility = window.decorView.systemUiVisibility
                    systemUiVisibility =
                        systemUiVisibility and View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    systemUiVisibility = systemUiVisibility and View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    window.decorView.systemUiVisibility = systemUiVisibility
                    window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
                    window.statusBarColor = color
                }
            }
        }
        Build.VERSION.SDK_INT >= 19 -> {
            window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
            if (color != COLOR_TRANSPARENT) {
                setTranslucentView(window.decorView as ViewGroup, color)
            }
        }
    }
    if (darkMode != null) {
        darkMode(darkMode)
    }
}
 fun Context.toast(msg:String){
    Toast.makeText(this,msg,Toast.LENGTH_SHORT).show()
}
private fun Context.setTranslucentView(container: ViewGroup, color: Int) {
    if (Build.VERSION.SDK_INT >= 19) {
        var simulateStatusBar: View? = container.findViewById(android.R.id.custom)
        if (simulateStatusBar == null && color != 0) {
            simulateStatusBar = View(container.context)
            simulateStatusBar.id = android.R.id.custom
            val lp = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, statusBarHeight)
            container.addView(simulateStatusBar, lp)
        }
        simulateStatusBar?.setBackgroundColor(color)
    }
}

fun Activity.darkMode(darkMode: Boolean = true) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        var systemUiVisibility = window.decorView.systemUiVisibility
        systemUiVisibility = if (darkMode) {
            systemUiVisibility or View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR
        } else {
            systemUiVisibility and View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR.inv()
        }
        window.decorView.systemUiVisibility = systemUiVisibility
    }
}

val Context?.statusBarHeight: Int
    get() {
        this ?: return 0
        var result = 24
        val resId = resources.getIdentifier("status_bar_height", "dimen", "android")
        result = if (resId > 0) {
            resources.getDimensionPixelSize(resId)
        } else {
            TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP,
                result.toFloat(), Resources.getSystem().displayMetrics
            ).toInt()
        }
        return result
    }

fun View.statusPadding(remove: Boolean = false) {
    if (this is RelativeLayout) {
        throw UnsupportedOperationException("Unsupported set statusPadding for RelativeLayout")
    }
    if (Build.VERSION.SDK_INT >= 19) {
        val statusBarHeight = context.statusBarHeight
        val lp = layoutParams
        if (lp != null && lp.height > 0) {
            lp.height += statusBarHeight //增高
        }
        if (remove) {
            if (paddingTop < statusBarHeight) return
            setPadding(
                paddingLeft, paddingTop - statusBarHeight,
                paddingRight, paddingBottom
            )
        } else {
            if (paddingTop >= statusBarHeight) return
            setPadding(
                paddingLeft, paddingTop + statusBarHeight,
                paddingRight, paddingBottom
            )
        }
    }
}

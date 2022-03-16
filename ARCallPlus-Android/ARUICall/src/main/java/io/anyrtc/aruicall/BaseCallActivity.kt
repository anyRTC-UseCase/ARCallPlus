package io.anyrtc.aruicall

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

import android.content.pm.ActivityInfo
import android.graphics.Color
import android.view.WindowManager
import darkMode
import immersive
import io.anyrtc.aruicall.utils.ScreenUtils
import io.anyrtc.aruicall.view.ARUICallGroupView
import io.anyrtc.aruicall.view.ARUICallVideoView


internal class BaseCallActivity : AppCompatActivity() {


    override fun onCreate(savedInstanceState: Bundle?) {
        ScreenUtils.adapterScreen(this, 375, false)
        super.onCreate(savedInstanceState)
//        immersive(Color.parseColor("#FF232426"),false)
        immersive()
        darkMode(false)
        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        val isGroup = intent.getBooleanExtra("isGroup",false)
        if (isGroup){
            setContentView(object : ARUICallGroupView(this) {
                override fun finish() {
                    super.finish()
                    GlobalVM.instance.isInGroupCall=false
                    this@BaseCallActivity.finish()
                }
            });
        }else{
            setContentView(object : ARUICallVideoView(
                this
            ) {

                override fun finish() {
                    super.finish()
                    GlobalVM.instance.isInP2pCall=false
                    this@BaseCallActivity.finish()
                }

            });
        }

    }


    override fun onDestroy() {
        super.onDestroy()
        ScreenUtils.resetScreen(this)
    }


    override fun onStart() {
        super.onStart()
    }



}
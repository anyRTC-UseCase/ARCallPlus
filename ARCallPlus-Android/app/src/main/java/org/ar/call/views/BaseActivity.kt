package org.ar.call.views

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.gyf.immersionbar.ImmersionBar
import org.ar.call.R
import org.ar.call.tools.ScreenUtils

open class BaseActivity : AppCompatActivity() {

  override fun onCreate(savedInstanceState: Bundle?) {
    ScreenUtils.adapterScreen(this, 375, adapterScreenVertical())
    super.onCreate(savedInstanceState)
    ImmersionBar.with(this).fitsSystemWindows(false).statusBarColor(statusBarColor())
      .statusBarDarkFont(
        statusBarColor() == R.color.statusBarColor
      ).navigationBarColor(statusBarColor(), 0.2f)
      .navigationBarDarkIcon(statusBarColor() == R.color.statusBarColor).init()
  }

  protected open fun statusBarColor() = R.color.statusBarColor
  protected open fun adapterScreenVertical() = false
  protected open fun targetDP() = 375

  fun changeScreenAdapter(isVertical: Boolean, dpi: Int) {
    ScreenUtils.resetScreen(this)
    ScreenUtils.adapterScreen(this, dpi, !isVertical)
  }

  override fun onDestroy() {
    ScreenUtils.resetScreen(this)
    super.onDestroy()
  }
}

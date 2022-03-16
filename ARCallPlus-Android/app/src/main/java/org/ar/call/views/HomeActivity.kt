package org.ar.call.views

import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.tencent.android.tpush.XGIOperateCallback
import com.tencent.android.tpush.XGPushManager
import io.anyrtc.aruicall.ARCallUser
import io.anyrtc.aruicall.ARUICalling
import io.anyrtc.aruicall.ARUILogin
import org.ar.call.BuildConfig
import org.ar.call.R
import org.ar.call.databinding.ActivityHomeBinding
import org.ar.call.model.UserModel
import org.ar.call.tools.HttpAPI
import org.ar.rtm.ErrorInfo

class HomeActivity : BaseActivity() {
  private lateinit var binding: ActivityHomeBinding

  private val homeFragment = CommunicationFragment()
  private val myselfFragment = MyselfFragment()

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    binding = ActivityHomeBinding.inflate(layoutInflater)
    setContentView(binding.root)

    initCore()
    initWidget()
  }

  private fun initCore() {
    val userModel = UserModel()
    userModel.queryDB {
      val selfInfo = userModel.selfInfo!!
      ARUILogin.init(this, BuildConfig.APP_ID)
      ARUILogin.login(ARCallUser(selfInfo.phoneNumber, selfInfo.nickname, selfInfo.avatar), object : org.ar.rtm.ResultCallback<Void> {
        override fun onSuccess(var1: Void?) {
          Log.e("::", "login success")
        }

        override fun onFailure(var1: ErrorInfo?) {
          Log.e("::", "login failed, Description: ${var1?.errorDescription}, errorCode: ${var1?.errorCode}")
        }
      })
      ARUICalling.getInstance(this) {
        userModel.removeSelf()
        startActivity(Intent(this, LoginActivity::class.java).also {
          it.putExtra("anotherLogin", true)
        })
        finish()
      }

      HttpAPI().init(selfInfo.phoneNumber, selfInfo.avatar, selfInfo.nickname) { initSuccess ->
        if (!initSuccess) {
          Toast.makeText(this, "网络连接失败，请重试", Toast.LENGTH_LONG).show()
          return@init
        }
      }
      XGPushManager.registerPush(this, object : XGIOperateCallback {
        override fun onSuccess(p0: Any?, p1: Int) {
          Log.e("::", "registerPush success, $p0, $p1")
          //XGPushManager.upsertAccounts(this@HomeActivity, selfInfo.phoneNumber)
          XGPushManager.upsertAccounts(this@HomeActivity, mutableListOf(XGPushManager.AccountInfo(0, selfInfo.phoneNumber)), object : XGIOperateCallback {
            override fun onSuccess(p0: Any?, p1: Int) {
              Log.e("::", "register success, $p0, $p1")
            }

            override fun onFail(p0: Any?, p1: Int, p2: String?) {
              Log.e("::", "register failed, $p0, $p1, $p2")
            }
          })
        }

        override fun onFail(p0: Any?, p1: Int, p2: String?) {
          Log.e("::", "registerPush failed, $p0, $p1, $p2")
        }
      })
    }

    checkNotification()
  }

  private fun checkNotification() {
    val compat = NotificationManagerCompat.from(this)
    if (compat.areNotificationsEnabled()) {
      return
    }

    val intent = Intent()
    intent.action = "android.settings.APP_NOTIFICATION_SETTINGS"
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      intent.putExtra("android.provider.extra.APP_PACKAGE", packageName)
    } else {
      intent.putExtra("app_package", packageName)
      intent.putExtra("app_uid", applicationInfo.uid)
    }
    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
    startActivity(intent)
  }

  private fun initWidget() {
    val resourceId = resources.getIdentifier("status_bar_height", "dimen", "android")
    if (resourceId > 0) {
      val statusBarHeight = resources.getDimensionPixelSize(resourceId)
      val bundle = Bundle()
      bundle.putInt("statusBarHeight", statusBarHeight)
      homeFragment.arguments = bundle
      myselfFragment.arguments = bundle
    }

    val selectedColor = ContextCompat.getColor(this, R.color.primaryColor)
    val defColor = Color.parseColor("#333333")

    replaceFragment(homeFragment)
    binding.radioGroup.setOnCheckedChangeListener { _, checkedId ->
      when (checkedId) {
        R.id.home -> {
          replaceFragment(homeFragment)
          binding.home.setTextColor(selectedColor)
          binding.myself.setTextColor(defColor)
        }
        R.id.myself -> {
          replaceFragment(myselfFragment)
          binding.myself.setTextColor(selectedColor)
          binding.home.setTextColor(defColor)
        }
      }
    }
    supportFragmentManager.addOnBackStackChangedListener {
      if (supportFragmentManager.backStackEntryCount < 1)
        displayBottomBar()
    }
  }

  fun hideBottomBar() {
    binding.radioGroup.visibility = View.GONE
  }

  private fun displayBottomBar() {
    binding.radioGroup.visibility = View.VISIBLE
  }

  private fun replaceFragment(f: Fragment) {
    supportFragmentManager.beginTransaction().replace(R.id.fragment_parent, f).commit()
  }

  override fun onDestroy() {
    //ARUILogin.logout()
    //ARUILogin.unInit()
    super.onDestroy()
  }
}

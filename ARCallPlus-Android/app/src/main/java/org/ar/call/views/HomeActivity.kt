package org.ar.call.views

import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.AnimationDrawable
import android.os.Build
import android.os.Bundle
import android.view.View
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
    showLoading()
    val userModel = UserModel()
    userModel.queryDB {
      val selfInfo = userModel.selfInfo!!
      ARUILogin.init(applicationContext, BuildConfig.APP_ID)
      ARUILogin.login(ARCallUser(selfInfo.phoneNumber, selfInfo.nickname, selfInfo.avatar), object : org.ar.rtm.ResultCallback<Void> {
        override fun onSuccess(var1: Void?) {
          ARUICalling.getInstance(applicationContext) {
            //userModel.removeSelf()
            runOnUiThread {
              dismissLoading()
              startActivity(Intent(applicationContext, LoginActivity::class.java).also { a ->
                a.putExtra("anotherLogin", true)
                a.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_NEW_TASK)
              })
              finish()
            }
          }
          httpInit(selfInfo)
        }

        override fun onFailure(var1: ErrorInfo?) {
          initCore()
        }
      })
    }

    checkNotification()
  }

  private fun httpInit(selfInfo: UserModel.UserInfo) {
    HttpAPI().init(selfInfo.phoneNumber, selfInfo.avatar, selfInfo.nickname) { initSuccess ->
      if (!initSuccess) {
        httpInit(selfInfo)
        return@init
      }
      initPush(selfInfo)
    }
  }

  private fun initPush(selfInfo: UserModel.UserInfo) {
    XGPushManager.registerPush(applicationContext, object : XGIOperateCallback {
      override fun onSuccess(p0: Any?, p1: Int) {
        //XGPushManager.upsertAccounts(this@HomeActivity, selfInfo.phoneNumber)
        setPushUser(selfInfo)
      }

      override fun onFail(p0: Any?, p1: Int, p2: String?) {
        initPush(selfInfo)
      }
    })
  }

  private fun setPushUser(selfInfo: UserModel.UserInfo) {
    XGPushManager.upsertAccounts(applicationContext, mutableListOf(XGPushManager.AccountInfo(0, selfInfo.phoneNumber)), object : XGIOperateCallback {
      override fun onSuccess(p0: Any?, p1: Int) {
        runOnUiThread { dismissLoading() }
      }

      override fun onFail(p0: Any?, p1: Int, p2: String?) {
        setPushUser(selfInfo)
      }
    })
  }

  private fun checkNotification() {
    val compat = NotificationManagerCompat.from(applicationContext)
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

    val selectedColor = ContextCompat.getColor(applicationContext, R.color.primaryColor)
    val defColor = Color.parseColor("#333333")

    replaceFragment(homeFragment)
    binding.loadingMask.setOnClickListener {  }
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

  private var showingFragment: Fragment? = null
  private fun replaceFragment(f: Fragment) {
    val sfm = supportFragmentManager
    if (sfm.fragments.contains(f)) { //added
      if (showingFragment != null) {
        sfm.beginTransaction().hide(showingFragment!!).show(f).commitNow()
      } else {
        sfm.beginTransaction().show(f).commitNow()
      }
    } else {
      sfm.beginTransaction().add(R.id.fragment_parent, f).commitNow()
    }

    showingFragment = f
  }

  private fun showLoading() {
    binding.loadingGroup.visibility = View.VISIBLE
    (binding.loadingView.drawable as AnimationDrawable).start()
  }

  private fun dismissLoading() {
    binding.loadingGroup.visibility = View.GONE
    (binding.loadingView.drawable as AnimationDrawable).stop()
  }

  override fun onDestroy() {
    ARUILogin.logout()
    //ARUILogin.unInit()
    super.onDestroy()
  }
}

package org.ar.call.views

import android.content.Intent
import android.net.Uri
import android.view.View
import com.bumptech.glide.Glide
import org.ar.call.BuildConfig
import org.ar.call.R
import org.ar.call.databinding.FragmentMyselfBinding
import org.ar.call.model.UserModel
import org.ar.rtc.RtcEngine

class MyselfFragment : BaseFragment() {

  override fun layoutId(): Int {
    return R.layout.fragment_myself
  }

  override fun initWidget(view: View) {
    val binding = FragmentMyselfBinding.bind(view)
    val userModel = UserModel()
    userModel.queryDB {
      val selfInfo = userModel.selfInfo ?: throw NullPointerException("Cannot find uid")
      Glide.with(binding.avatar).load(selfInfo.avatar).into(binding.avatar)
      binding.nickname.text = selfInfo.nickname
      binding.phoneNumber.text = selfInfo.phoneNumber
    }

    binding.privacy.setOnClickListener {
      openWithBrowser("https://anyrtc.io/anyrtc/privacy")
    }
    binding.signUp.setOnClickListener {
      openWithBrowser("https://console.anyrtc.io/signup")
    }
    binding.disclaimer.setOnClickListener {
      val disclaimerFragment = DisclaimerFragment()
      disclaimerFragment.arguments = requireArguments()
      activity?.supportFragmentManager?.beginTransaction()?.let {
        it.setCustomAnimations(R.anim.slide_in, R.anim.fade_out)
        it.replace(R.id.fragment_parent, disclaimerFragment)
        it.addToBackStack(null)
        it.commit()
        (requireActivity() as HomeActivity).hideBottomBar()
      }
    }

    binding.tvSdkVersion.text = String.format("%s", "v ${RtcEngine.getSdkVersion()}")
    binding.tvAppVersion.text = String.format("%s", "v ${BuildConfig.VERSION_NAME}")
    binding.tvPubTime.text = BuildConfig.releaseDate
  }

  private fun openWithBrowser(url: String) {
    startActivity(Intent().apply {
      action = "android.intent.action.VIEW"
      data = Uri.parse(url)
    })
  }
}

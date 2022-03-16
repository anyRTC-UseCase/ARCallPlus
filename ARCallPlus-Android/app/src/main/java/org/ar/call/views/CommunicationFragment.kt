package org.ar.call.views

import android.os.Bundle
import android.view.View
import org.ar.call.R
import org.ar.call.databinding.FragmentCommunicationBinding

class CommunicationFragment : BaseFragment() {

  override fun layoutId(): Int {
    return R.layout.fragment_communication
  }

  override fun initWidget(view: View) {
    val binding = FragmentCommunicationBinding.bind(view)
    binding.peerByPeerAudio.setOnClickListener {
      gotoSearchingFragment(false, isVideo = false, "点对点音频呼叫")
    }
    binding.peerByPeerVideo.setOnClickListener {
      gotoSearchingFragment(false, isVideo = true, "点对点视频呼叫")
    }
    binding.groupAudio.setOnClickListener {
      gotoSearchingFragment(true, isVideo = false, "多人语音呼叫")
    }
    binding.groupVideo.setOnClickListener {
      gotoSearchingFragment(true, isVideo = true, "多人视频呼叫")
    }
  }

  override fun setStatusBarPadding(view: View, statusBarHeight: Int) {
    val dp16 = resources.getDimensionPixelOffset(R.dimen.dp16)
    view.findViewById<View>(R.id.scroll_view).setPadding(dp16, statusBarHeight, dp16, 0)
  }

  private fun gotoSearchingFragment(isMultiple: Boolean, isVideo: Boolean, title: String) {
    val searchingFragment = SearchingFragment()
    val searchingBundle = requireArguments()
    activity?.supportFragmentManager?.beginTransaction()?.let {
      searchingFragment.arguments = searchingBundle
      searchingBundle.putBoolean("isMultiple", isMultiple)
      searchingBundle.putBoolean("isVideo", isVideo)
      searchingBundle.putString("title", title)
      it.setCustomAnimations(R.anim.slide_in, R.anim.fade_out)
      it.replace(R.id.fragment_parent, searchingFragment)
      it.addToBackStack(null)
      it.commit()
      (requireActivity() as HomeActivity).hideBottomBar()
    }
  }
}
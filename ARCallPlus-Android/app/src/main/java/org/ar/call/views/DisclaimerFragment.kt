package org.ar.call.views

import android.view.View
import org.ar.call.R

class DisclaimerFragment : BaseFragment() {

  override fun layoutId(): Int {
    return R.layout.fragment_disclaimer
  }


  override fun initWidget(view: View) {
    view.findViewById<View>(R.id.back).setOnClickListener {
      activity?.onBackPressed()
    }
  }
}
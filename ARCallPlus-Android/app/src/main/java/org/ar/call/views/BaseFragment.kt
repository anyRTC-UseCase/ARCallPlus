package org.ar.call.views

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment

abstract class BaseFragment : Fragment() {

  override fun onCreateView(
    inflater: LayoutInflater,
    container: ViewGroup?,
    savedInstanceState: Bundle?
  ): View? {
    return inflater.inflate(layoutId(), container, false)
  }

  override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
    arguments?.let {
      val statusBarHeight = it.getInt("statusBarHeight")
      setStatusBarPadding(view, statusBarHeight)
    }
    initWidget(view)
  }

  abstract fun layoutId(): Int
  abstract fun initWidget(view: View)
  open fun setStatusBarPadding(view: View, statusBarHeight: Int) {
    view.setPadding(0, statusBarHeight, 0, 0)
  }
}
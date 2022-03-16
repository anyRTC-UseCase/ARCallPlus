package org.ar.call.views

import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.content.Intent
import android.graphics.Color
import android.graphics.drawable.AnimationDrawable
import android.os.Bundle
import android.view.View
import android.view.animation.AccelerateDecelerateInterpolator
import android.widget.Toast
import androidx.appcompat.widget.AppCompatImageView
import androidx.cardview.widget.CardView
import androidx.core.animation.doOnEnd
import androidx.recyclerview.widget.GridLayoutManager
import com.bumptech.glide.Glide
import com.kongzue.dialog.v3.MessageDialog
import org.ar.call.R
import org.ar.call.databinding.ActivityLoginBinding
import org.ar.call.model.UserModel
import org.ar.call.tools.Adapter
import org.ar.call.tools.HttpAPI
import kotlin.random.Random

class LoginActivity : BaseActivity() {

  private lateinit var binding: ActivityLoginBinding
  private var isAvatarSelectorShowing = false
  private var selectedIconPosition = 0

  private val itemSelectedColor = Color.parseColor("#294BFF")
  private var cachedPhoneNumber = ""

  private val recyclerAdapter by lazy {
    Adapter(ArrayList(), ::onBind, R.layout.item_avatar)
  }

  private val defNicknames = arrayOf(
    "Rose",
    "Lily",
    "Daisy",
    "Jasmine",
    "Poppy",
    "Violet",
    "Camellia",
    "Rosemary",
    "Daffodil",
    "Gardenia",
    "Jackson",
    "Aiden",
    "Liam",
    "Lucas",
    "Noah",
    "Mason",
    "Ethan",
    "Caden",
    "Logan",
    "Jacob"
  )

  private val avatars = arrayOf(
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/1be8f37f883172e2627d130b22f03658.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/471525db8a6ee469036989bb2d9458cc.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/61e7fad153a7c82109de496e5a5a1aeb.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/4a1802f74394e4a957b26dc121aae99e.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/2b09c26bcf7dc36259558e974c4b84db.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/46781d0c51c577f8aca7e30d1c84c906.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/938009652658253930a0897a69a21601.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/439f9305715ba98e8ad5b9f6a1632d21.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/5708fca0acb456a858ec09f326eb71f8.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/b78196cf6b67815ab50b26433eebf4e6.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/f971d600f491aa7f5a3033349c706868.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/0c768308bd376e1254fd66b5c24d0db6.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/2d1a53a1cb9888294f33904fec86a73a.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/6f33e3577cf740c505fbc54af0966605.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/72edb9881cae6721ebb49d43eb0312e8.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/b195f5854851a7dd4a55deee2db7c271.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/1a05d5741cb4d2802190ef9a73624bbc.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/6d80cdd0c7f0cf9876a9e59fda6aa439.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/8bd23da352df7daffffe06f69dec4ba8.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/d00c5df0ab369290b0ea87f7ce5acad9.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/7e18965e9903fb1212c1c04546d4abcc.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/0f61ca1a4423ce46caa2ad16d8e43342.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/761cdd252d67afd69eaece9b5901edfc.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/9c4dca89e0aeb2fdfce04443fc9a935a.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/5aed7263e2effdd365e815a7f6f91417.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/f5f3ff9c1c81e8e25afea070b69bac93.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/0f8518bf057ae4ab7c269847aae86811.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/67ab3f38ea4c685381f13ca597692db6.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/0a97a0a19de5214b42c7478134d35607.jpg",
    "https://anyrtc.oss-cn-shanghai.aliyuncs.com/fbbb28b56158f3d77732d3a2c3a1d1b5.jpg"
  )

  private val http by lazy {
    HttpAPI()
  }
  private val userModel = UserModel()

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    binding = ActivityLoginBinding.inflate(layoutInflater)
    setContentView(binding.root)

    val anotherLogin = intent.getBooleanExtra("anotherLogin", false)
    if (anotherLogin) {
      MessageDialog.show(this, "账号异地登录", "", "确认")
    } else userModel.queryDB {
      if (userModel.selfInfo != null) {
        startActivity(Intent(this, HomeActivity::class.java))
        finish()
      }
    }

    initWidget()
  }

  private fun initWidget() {
    binding.secondPage.post {
      binding.secondPage.translationX = binding.secondPage.measuredWidth.toFloat()
    }
    binding.chooseAvatarParent.post {
      binding.chooseAvatarParent.translationY = binding.chooseAvatarParent.measuredHeight.toFloat()
    }
    binding.chooseAvatarParentShadow.setOnClickListener { dismissAvatarSelector() }
    binding.loadingMask.setOnClickListener { }
    binding.phoneConfirm.setOnClickListener {
      val phoneNumber = binding.phoneNumber.text.toString()
      if (phoneNumber.isBlank() || !phoneNumber.startsWith('1') || phoneNumber.length != 11) {
        Toast.makeText(this, "请输入有效的手机号码", Toast.LENGTH_SHORT).show()
        return@setOnClickListener
      }

      showLoading()
      binding.phoneConfirm.postDelayed({
        http.userExists(phoneNumber) { isExists, failed, userInfo ->
          dismissLoading()
          if (failed) {
            Toast.makeText(this, "网络连接失败，请重试", Toast.LENGTH_LONG).show()
            return@userExists
          }
          if (isExists) {
            userModel.updateDB(userInfo!!, isSelf = true)
            startActivity(Intent(this, HomeActivity::class.java))
            finish()
            return@userExists
          }
          cachedPhoneNumber = phoneNumber
          switchToSecondPage()
        }
      }, 300)
    }
    binding.avatarReplacement.setOnClickListener {
      showAvatarSelector()
    }
    binding.avatarConfirm.setOnClickListener {
      dismissAvatarSelector()
      Glide.with(binding.avatar).load(avatars[selectedIconPosition]).into(binding.avatar)
    }
    binding.nicknameDice.setOnClickListener {
      val randomInt = Random.nextInt(0, defNicknames.size)
      binding.nicknameEdit.setText(defNicknames[randomInt])
    }
    binding.complete.setOnClickListener {
      // phone number, avatar, nickname
      // goto home page
      val nickname = binding.nicknameEdit.text.toString()
      if (nickname.isBlank()) {
        Toast.makeText(this, "昵称不能为空", Toast.LENGTH_LONG).show()
        return@setOnClickListener
      }
      /*val regex = Regex("(?=[^\\x{4e00}-\\x{9fa5}]+)(?=[^a-zA-Z0-9]+)")
      if (regex.findAll(nickname).iterator().hasNext()) {
        MessageDialog.show(this, "昵称不能包含非法字符", "只支持：汉字、英文、数字", "确认")
        return@setOnClickListener
      }*/

      val avatar = avatars[selectedIconPosition]
      val phoneNumber = cachedPhoneNumber

      userModel.updateDB(
        UserModel.UserInfo(
          System.currentTimeMillis(),
          phoneNumber,
          avatar,
          nickname
        ), true
      )
      startActivity(Intent(this, HomeActivity::class.java))
      finish()
    }

    binding.avatarGrid.run {
      layoutManager = GridLayoutManager(context, 4, GridLayoutManager.VERTICAL, false)
      adapter = recyclerAdapter
      recyclerAdapter.data.addAll(avatars)
      recyclerAdapter.notifyItemRangeChanged(0, avatars.size)
    }
  }

  private fun switchToSecondPage() {
    val width = binding.firstPage.measuredWidth

    val firstPage =
      ObjectAnimator.ofFloat(binding.firstPage, "translationX", 0.0f, -width.toFloat())
    val secondPage =
      ObjectAnimator.ofFloat(binding.secondPage, "translationX", width.toFloat(), 0.0f)
    val animSet = AnimatorSet()
    animSet.playTogether(firstPage, secondPage)
    animSet.duration = 325
    animSet.interpolator = AccelerateDecelerateInterpolator()
    animSet.start()

    val randomIndex = Random.nextInt(0, defNicknames.size)
    binding.nicknameEdit.setText(defNicknames[randomIndex])
    Glide.with(binding.avatar).load(avatars[0]).into(binding.avatar)
  }

  private fun showAvatarSelector() {
    if (isAvatarSelectorShowing)
      return

    val height = binding.chooseAvatarParent.measuredHeight
    val avatarParent =
      ObjectAnimator.ofFloat(binding.chooseAvatarParent, "translationY", height.toFloat(), 0.0f)
    avatarParent.duration = 325
    avatarParent.interpolator = AccelerateDecelerateInterpolator()
    avatarParent.start()

    avatarParent.addUpdateListener {
      it.doOnEnd {
        binding.chooseAvatarParentShadow.visibility = View.VISIBLE
      }
    }
    isAvatarSelectorShowing = true
  }

  private fun dismissAvatarSelector() {
    if (!isAvatarSelectorShowing)
      return

    val height = binding.chooseAvatarParent.measuredHeight
    val avatarParent =
      ObjectAnimator.ofFloat(binding.chooseAvatarParent, "translationY", 0.0f, height.toFloat())
    avatarParent.duration = 325
    avatarParent.interpolator = AccelerateDecelerateInterpolator()
    avatarParent.start()

    binding.chooseAvatarParentShadow.visibility = View.GONE
    isAvatarSelectorShowing = false
  }

  private fun showLoading() {
    binding.loadingGroup.visibility = View.VISIBLE
    (binding.loadingView.drawable as AnimationDrawable).start()
  }

  private fun dismissLoading() {
    binding.loadingGroup.visibility = View.GONE
    (binding.loadingView.drawable as AnimationDrawable).stop()
  }

  private fun onBind(holder: Adapter.Holder, url: String, position: Int, payload: List<Any>?) {
    val icon = holder.findView<AppCompatImageView>(R.id.icon)
    val cardBg = holder.findView<CardView>(R.id.card_bg)
    Glide.with(icon).load(url).into(icon)
    cardBg.setCardBackgroundColor(
      if (selectedIconPosition == position)
        itemSelectedColor
      else
        Color.WHITE
    )
    icon.setOnClickListener {
      recyclerAdapter.notifyItemChanged(selectedIconPosition)
      recyclerAdapter.notifyItemChanged(position)
      selectedIconPosition = position
    }
  }
}

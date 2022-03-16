package org.ar.call.views

import android.content.Context
import android.graphics.Color
import android.util.Log
import android.view.View
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.widget.AppCompatImageView
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import io.anyrtc.aruicall.ARCallUser
import io.anyrtc.aruicall.ARUICalling
import org.ar.call.R
import org.ar.call.databinding.FragmentSearchBinding
import org.ar.call.model.UserModel
import org.ar.call.tools.Adapter
import org.ar.call.tools.HttpAPI
import java.util.*
import kotlin.collections.ArrayList

class SearchingFragment : BaseFragment() {

  private lateinit var binding: FragmentSearchBinding
  private var isMultiple = false
  private var isVideo = false
  private lateinit var title: String
  private val adapter = Adapter(ArrayList(), this::bindItem, R.layout.item_contact)

  private val httpApi by lazy { HttpAPI() }
  private lateinit var selectedContact: Any

  private val makeCallEnableColor = Color.parseColor("#FF294BFF")
  private val makeCallDisableColor = Color.parseColor("#FFB4B4CC")

  override fun onAttach(context: Context) {
    super.onAttach(context)
    isMultiple = arguments?.getBoolean("isMultiple") ?: false
    isVideo = arguments?.getBoolean("isVideo") ?: false
    title = arguments?.getString("title") ?: ""
    selectedContact = if (isMultiple)
      LinkedList<ItemInfo>()
    else
      arrayOfNulls<ItemInfo>(1)
  }

  override fun layoutId(): Int {
    return R.layout.fragment_search
  }

  override fun initWidget(view: View) {
    binding = FragmentSearchBinding.bind(view)
    val userModel = UserModel()
    userModel.queryDB {
      if (it.isEmpty()) {
        binding.emptyContact.visibility = View.VISIBLE
        return@queryDB
      }
      adapter.data.clear()
      adapter.data.addAll(it.map { item -> ItemInfo(item) })
      adapter.notifyItemRangeChanged(0, it.size)

      if (isMultiple) {
        binding.selected.text = String.format("已选择 0/%d", it.size)
      }
    }

    binding.back.setOnClickListener {
      activity?.onBackPressed()
    }

    binding.title.text = title
    binding.search.setOnClickListener {
      val inputNumber = binding.editPhoneNumber.text.toString()
      if (inputNumber.isBlank() || inputNumber.length != 11 || !inputNumber.startsWith('1')) {
        Toast.makeText(view.context, "请输入正确手机号码", Toast.LENGTH_LONG).show()
        return@setOnClickListener
      }
      binding.loadingView.showLoading("请稍等")
      if (inputNumber == userModel.selfInfo!!.phoneNumber) {
        binding.loadingView.hideLoading()
        Toast.makeText(it.context, "不能搜索自己", Toast.LENGTH_LONG).show()
        return@setOnClickListener
      }

      var findIndex = -1
      for (i in 0 until adapter.data.size) {
        val item = adapter.data[i]
        if (item.userInfo.phoneNumber == inputNumber) {
          findIndex = i
          break
        }
      }
      if (findIndex != -1) {
        binding.loadingView.hideLoading()
        val removedElem = adapter.data.removeAt(findIndex)
        adapter.data.add(0, removedElem)
        adapter.notifyItemRangeChanged(0, adapter.data.size)
        return@setOnClickListener
      }
      httpApi.userExists(inputNumber) { isExists, failed, userInfo ->
        binding.loadingView.hideLoading()
        if (failed) {
          Toast.makeText(view.context, "搜索出错", Toast.LENGTH_LONG).show()
          return@userExists
        }
        if (!isExists) {
          Toast.makeText(view.context, "用户不存在", Toast.LENGTH_LONG).show()
          return@userExists
        }
        if (binding.emptyContact.visibility != View.GONE)
          binding.emptyContact.visibility = View.GONE
        userModel.updateDB(userInfo!!)
        adapter.data.add(0, ItemInfo(userInfo))
        adapter.notifyItemRangeChanged(0, adapter.data.size)
      }
    }
    binding.loadingView.run {
      setCardColor(Color.parseColor("#CCFFFFFF"))
      setFontColor(Color.parseColor("#FF5A5A67"))
    }

    val calling = ARUICalling.getInstance(view.context)
    calling.setCallingListener(object : ARUICalling.ARUICallingListener {
      override fun onCallEnd(
        users: Array<ARCallUser>,
        type: ARUICalling.Type,
        role: ARUICalling.Role,
        totalTime: Long
      ) {
        binding.loadingView.hideLoading()
      }

      override fun onCallEvent(
        event: ARUICalling.Event,
        type: ARUICalling.Type,
        role: ARUICalling.Role,
        message: String?
      ) {
      }

      override fun onCallStart(
        users: Array<ARCallUser>,
        type: ARUICalling.Type,
        role: ARUICalling.Role,
        tuiCallingView: View?
      ) {
      }

      override fun onPushToOfflineUser(users: Array<ARCallUser>, type: ARUICalling.Type) {
        userModel.selfInfo?.let {
          httpApi.pushNotification(
            it.phoneNumber,
            title,
            users.map { it.userId }.toTypedArray(),
            getCallType(type), 0
          ) { success ->
            Log.e("::", "push success=$success")
          }
        }
      }

      override fun shouldShowOnCallView(): Boolean {
        return true
      }
    })
    binding.makingCall.setOnClickListener {
      if (isContactEmpty()) {
        return@setOnClickListener
      }
      binding.loadingView.showLoading("请稍等..")
      if (isMultiple) {
        val timeMillis = System.currentTimeMillis()
        calling.call(
          (selectedContact as LinkedList<ItemInfo>).map { item ->
            item.userInfo.createDate = timeMillis; userModel.updateDB(item.userInfo); ARCallUser(
            item.userInfo.phoneNumber,
            item.userInfo.nickname,
            item.userInfo.avatar
          )
          }.toTypedArray(),
          if (isVideo)
            ARUICalling.Type.VIDEO
          else
            ARUICalling.Type.AUDIO
        )
      } else {
        val item = (selectedContact as Array<ItemInfo>)[0]
        item.userInfo.createDate = System.currentTimeMillis()
        userModel.updateDB(item.userInfo)
        calling.call(
          ARCallUser(item.userInfo.phoneNumber, item.userInfo.nickname, item.userInfo.avatar),
          if (isVideo)
            ARUICalling.Type.VIDEO
          else
            ARUICalling.Type.AUDIO
        )
      }
    }
    binding.recycler.let {
      it.layoutManager = LinearLayoutManager(view.context, LinearLayoutManager.VERTICAL, false)
      it.adapter = adapter
    }
  }

  private fun isContactEmpty(): Boolean {
    if (isMultiple) {
      val s = selectedContact as LinkedList<*>
      return s.isEmpty()
    }
    val s = selectedContact as Array<*>
    return s[0] == null
  }

  private fun addSelectedContact(item: ItemInfo): Boolean {
    if (isMultiple) {
      val s = selectedContact as LinkedList<ItemInfo>
      if (s.size == 8)
        return false
      s.add(item)
      binding.selected.text = String.format("已选择 %d/%d", s.size, adapter.data.size)
    } else {
      val s = selectedContact as Array<ItemInfo?>
      s[0]?.isSelected = false
      s[0] = item
    }
    item.isSelected = true
    adapter.notifyItemRangeChanged(0, adapter.data.size, "1")
    binding.makingCall.setCardBackgroundColor(makeCallEnableColor)
    return true
  }

  private fun removeSelectedContact(item: ItemInfo) {
    if (isMultiple) {
      val s = selectedContact as LinkedList<ItemInfo>
      if (s.isEmpty())
        return
      val iterator = s.iterator()
      while (iterator.hasNext()) {
        val next = iterator.next()
        if (next.userInfo.id == item.userInfo.id) {
          next.isSelected = false
          iterator.remove()
          break
        }
      }
      binding.selected.text = String.format("已选择 %d/%d", s.size, adapter.data.size)
      if (s.isEmpty()) binding.makingCall.setCardBackgroundColor(makeCallDisableColor)
    } else {
      val s = selectedContact as Array<ItemInfo?>
      s[0]?.isSelected = false
      s[0] = null
      binding.makingCall.setCardBackgroundColor(makeCallDisableColor)
    }
    item.isSelected = false
    adapter.notifyItemRangeChanged(0, adapter.data.size, "1")
  }

  private fun bindItem(holder: Adapter.Holder, item: ItemInfo, position: Int, payload: List<Any>?) {
    val avatarView = holder.findView<AppCompatImageView>(R.id.avatar)
    val nicknameView = holder.findView<TextView>(R.id.nickname)
    val phoneNumberView = holder.findView<TextView>(R.id.phone_number)
    val selectedView = holder.findView<AppCompatImageView>(R.id.selected)

    if (payload != null) {
      selectedView.setImageResource(if (item.isSelected) R.drawable.selector_checked else R.drawable.selector_unchecked)
      return
    }

    Glide.with(avatarView).load(item.userInfo.avatar).into(avatarView)
    nicknameView.text = item.userInfo.nickname
    phoneNumberView.text = item.userInfo.phoneNumber

    selectedView.setImageResource(if (item.isSelected) R.drawable.selector_checked else R.drawable.selector_unchecked)
    holder.itemView.setOnClickListener {
      if (item.isSelected) {
        removeSelectedContact(item)
        return@setOnClickListener
      }
      val addSuccess = addSelectedContact(item)
      if (!addSuccess) {
        Toast.makeText(holder.itemView.context, "最大选择8人", Toast.LENGTH_LONG).show()
      }
    }
  }

  private fun getCallType(type: ARUICalling.Type) = if (isMultiple)
    if (type == ARUICalling.Type.AUDIO) 2 else 3
  else
    if (type == ARUICalling.Type.AUDIO) 0 else 1

  private data class ItemInfo(
    val userInfo: UserModel.UserInfo,
    var isSelected: Boolean = false
  )
}

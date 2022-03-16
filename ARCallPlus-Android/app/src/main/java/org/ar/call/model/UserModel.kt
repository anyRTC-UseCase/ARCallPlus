package org.ar.call.model

import android.annotation.SuppressLint
import org.ar.call.App
import org.ar.call.tools.SQLDataHelper
import java.lang.NullPointerException

class UserModel {

  private val list = mutableListOf<UserInfo>()
  var selfInfo: UserInfo? = null
    private set

  private val db by lazy {
    SQLDataHelper.INSTANCE
  }

  private val keyObj = Any()

  @Synchronized
  @SuppressLint("Range")
  fun queryDB(complete: (MutableList<UserInfo>) -> Unit) {
    synchronized(keyObj) {
      Thread {
        val reader = db.readableDatabase
        val query =
          reader.rawQuery(
            "SELECT * FROM User_account WHERE Id != 0 ORDER BY Create_date DESC;",
            null
          )
        if (query.moveToFirst() && query.count != 0) {
          list.clear()
          do {
            val id = query.getInt(query.getColumnIndex("Id"))
            val cDate = query.getLong(query.getColumnIndex("Create_date"))
            val pNumber = query.getString(query.getColumnIndex("Phone_number"))
            val avatar = query.getString(query.getColumnIndex("Avatar"))
            val nickname = query.getString(query.getColumnIndex("Nickname"))

            list.add(UserInfo(cDate, pNumber, avatar, nickname, id))
          } while (query.moveToNext())
        }
        query.close()

        val sQuery = reader.rawQuery("SELECT * FROM User_account WHERE Id = 0;", null)
        if (sQuery.moveToFirst() && sQuery.count != 0) {
          val id = sQuery.getInt(query.getColumnIndex("Id"))
          val cDate = sQuery.getLong(query.getColumnIndex("Create_date"))
          val pNumber = sQuery.getString(query.getColumnIndex("Phone_number"))
          val avatar = sQuery.getString(query.getColumnIndex("Avatar"))
          val nickname = sQuery.getString(query.getColumnIndex("Nickname"))

          selfInfo = UserInfo(cDate, pNumber, avatar, nickname, id)
        }
        sQuery.close()
        reader.close()
        App.runOnUiThread {
          complete.invoke(list)
        }
      }.start()
    }
  }

  @Synchronized
  fun updateDB(userInfo: UserInfo, isSelf: Boolean = false) {
    synchronized(keyObj) {
      val writer = db.writableDatabase
      if (userInfo.id != null) {
        writer.execSQL("UPDATE User_account SET Create_date=${userInfo.createDate}, Phone_number='${userInfo.phoneNumber}', Avatar='${userInfo.avatar}', Nickname='${userInfo.nickname}' WHERE Id=${userInfo.id};")
      } else {
        writer.execSQL("INSERT INTO User_account (${if (isSelf) "Id, " else ""}Create_date, Phone_number, Avatar, Nickname) VALUES(${if (isSelf) "0, " else ""}${userInfo.createDate}, '${userInfo.phoneNumber}', '${userInfo.avatar}', '${userInfo.nickname}');")
        val query = writer.rawQuery(
          "SELECT Id FROM User_account WHERE Phone_number = ${userInfo.phoneNumber};",
          null
        )
        if (!query.moveToFirst()) {
          query.close()
          throw NullPointerException("cannot found Id")
        }
        val id = query.getInt(0)
        userInfo.id = id
        query.close()
      }
      writer.close()
    }
  }

  @Synchronized
  fun updateAllDate() {
    synchronized(keyObj) {
      if (list.isEmpty())
        return
      // maybe need to get the new thread

      val writer = db.writableDatabase
      writer.beginTransaction()
      list.forEach {
        if (it.id != null) {
          writer.execSQL("UPDATE User_account SET Create_date=${it.createDate}, Phone_number='${it.phoneNumber}', Avatar='${it.avatar}', Nickname='${it.nickname}' WHERE Id=${it.id};")
        } else {
          writer.execSQL("INSERT INTO User_account (Create_date, Phone_number, Avatar, Nickname) VALUES(${it.id}, ${it.createDate}, '${it.phoneNumber}', '${it.avatar}', '${it.nickname}');")
        }
      }
      writer.endTransaction()
      writer.setTransactionSuccessful()
      writer.close()
    }
  }

  @Synchronized
  fun removeSelf() {
    synchronized(keyObj) {
      if (null != selfInfo) {
        selfInfo = null
        val writer = db.writableDatabase
        writer.execSQL("DELETE FROM User_account WHERE Id = 0;")
        writer.close()
        selfInfo = null
      }
    }
  }

  data class UserInfo(
    var createDate: Long,
    val phoneNumber: String,
    val avatar: String,
    val nickname: String,
    var id: Int? = null,
  )
}

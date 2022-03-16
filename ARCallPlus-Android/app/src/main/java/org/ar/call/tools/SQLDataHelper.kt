package org.ar.call.tools

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import org.ar.call.App

class SQLDataHelper
private constructor(context: Context) : SQLiteOpenHelper(context, "account", null, 1) {

  companion object {
    val INSTANCE by lazy {
      SQLDataHelper(App.context)
    }
  }

  override fun onCreate(db: SQLiteDatabase?) {
    db ?: return
    db.execSQL("CREATE TABLE IF NOT EXISTS User_account(Id integer PRIMARY KEY AUTOINCREMENT, Create_date int, Phone_number char(11), Avatar varchar(40), Nickname nvarchar(10));")
  }

  override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
  }
}
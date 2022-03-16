package org.ar.call.ARCallPlus

import android.util.JsonReader
import android.util.Log
import org.junit.Test

import org.junit.Assert.*
import java.util.regex.Pattern

/**
 * Example local unit test, which will execute on the development machine (host).
 *
 * See [testing documentation](http://d.android.com/tools/testing).
 */
class ExampleUnitTest {
    @Test
    fun addition_isCorrect() {
        val regex = Regex("(?=[^\\x{4e00}-\\x{9fa5}]+)(?=[^a-zA-Z0-9]+)")
        println(regex.findAll("abd123+哈哈哈").iterator().hasNext())
    }
}
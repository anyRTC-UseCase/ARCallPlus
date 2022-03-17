package org.ar.call.widgets

import android.content.Context
import android.graphics.*
import android.util.AttributeSet
import android.view.View
import androidx.core.content.ContextCompat
import org.ar.call.R
import java.util.*

class MaterialLoadingProgress
@JvmOverloads
constructor(
  context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
): View(context, attrs, defStyleAttr) {

  private var circleRadius: Float
  private var cardColor: Int
  private var cardPadding: Float
  private var strokeWidth: Float
  private var strokeColor: Int
  private var text: String = ""
  private var textWidth: Float = 0f
  private var textSize: Float
  private var textColor: Int

  private val rectF = RectF()
  private val paint = Paint()

  private lateinit var bufferCanvas: Canvas
  private lateinit var bufferBitmap: Bitmap
  private val bufferMatrix = Matrix()

  private val taskList: LinkedList<AnimTask> = LinkedList()

  private var timer: Timer? = null
  private var showing = false

  init {
    val defCircleRadius = context.resources.getDimension(R.dimen.dp24)
    val defCardColor = Color.WHITE
    val defCardPadding = context.resources.getDimension(R.dimen.dp12)
    val defStrokeWidth = context.resources.getDimension(R.dimen.dp5)
    val defStrokeColor = ContextCompat.getColor(context, R.color.teal_200)
    val defTextSize = context.resources.getDimension(R.dimen.sp14)
    val defTextColor = Color.parseColor("#333333")
    if (attrs != null) {
      val attrSet = context.resources.obtainAttributes(attrs, R.styleable.MaterialLoadingProgress)
      circleRadius = attrSet.getDimension(R.styleable.MaterialLoadingProgress_loadingProgress_circleRadius, defCircleRadius)
      cardColor = attrSet.getColor(R.styleable.MaterialLoadingProgress_loadingProgress_cardColor, defCardColor)
      cardPadding = attrSet.getDimension(R.styleable.MaterialLoadingProgress_loadingProgress_cardPadding, defCardPadding)
      strokeWidth = attrSet.getDimension(R.styleable.MaterialLoadingProgress_loadingProgress_strokeWidth, defStrokeWidth)
      strokeColor = attrSet.getColor(R.styleable.MaterialLoadingProgress_loadingProgress_strokeColor, defStrokeColor)
      text = attrSet.getString(R.styleable.MaterialLoadingProgress_loadingProgress_text) ?: ""
      textSize = attrSet.getDimension(R.styleable.MaterialLoadingProgress_loadingProgress_textSize, defTextSize)
      textColor = attrSet.getColor(R.styleable.MaterialLoadingProgress_loadingProgress_textColor, defTextColor)
      attrSet.recycle()
    } else {
      circleRadius = defCircleRadius
      cardColor = defCardColor
      cardPadding = defCardPadding
      strokeWidth = defStrokeWidth
      strokeColor = defStrokeColor
      textSize = defTextSize
      textColor = defTextColor
    }
    paint.textSize = textSize
    if (text.isNotBlank())
      textWidth = paint.measureText(text)
  }

  override fun onDraw(canvas: Canvas) {
    val centerX = measuredWidth.shr(1)
    val centerY = measuredHeight.shr(1)

    val rectHalfDimension = if (circleRadius > textWidth / 2f) circleRadius + cardPadding else textWidth / 2f + cardPadding
    rectF.set(
      centerX - rectHalfDimension,
      centerY - rectHalfDimension,
      centerX + rectHalfDimension,
      if (text.isNotBlank()) centerY + paint.textSize + rectHalfDimension else centerY + rectHalfDimension
    )

    paint.color = cardColor
    paint.style = Paint.Style.FILL
    canvas.drawRoundRect(rectF, 12f, 12f, paint)

    if (text.isNotBlank()) {
      val dx = measuredWidth.shr(1) - textWidth / 2
      paint.color = textColor
      canvas.drawText(text, dx, rectF.bottom - paint.textSize, paint)
    }

    if (this::bufferBitmap.isInitialized)
      canvas.drawBitmap(bufferBitmap, bufferMatrix, paint)
  }

  private fun drawFrame(task: AnimTask) {
    bufferBitmap.eraseColor(Color.TRANSPARENT)

    val centerX = measuredWidth.shr(1)
    val centerY = measuredHeight.shr(1)
    rectF.set(
      centerX - circleRadius, centerY - circleRadius,
      centerX + circleRadius, centerY + circleRadius
    )
    paint.strokeWidth = strokeWidth
    paint.color = strokeColor
    paint.strokeCap = Paint.Cap.ROUND
    paint.style = Paint.Style.STROKE

    if (task.convert) {
      bufferCanvas.drawArc(
        rectF, task.startAngle.toFloat(), -(320.0f - task.currentAngle.toFloat()), false, paint
      )
    } else {
      bufferCanvas.drawArc(
        rectF, task.startAngle.toFloat(), task.currentAngle.toFloat(), false, paint
      )
    }
    invalidate()
  }

  private fun initCanvas() {
    bufferBitmap = Bitmap.createBitmap(measuredWidth, measuredHeight, Bitmap.Config.ARGB_8888)
    bufferCanvas = Canvas(bufferBitmap)
  }

  fun showProgress() {
    if (showing)
      return

    if (!this::bufferBitmap.isInitialized) {
      initCanvas()
    }

    taskList.add(AnimTask {
      drawFrame(it)
    })
    taskList.add(AnimTask(duration = 5000) {
      drawRotation(it)
    })
    startTimerTask()
    showing = true
    visibility = VISIBLE
  }

  fun dismissProgress() {
    if (!showing)
      return

    purgeTimer()
    showing = false
    visibility = GONE
  }

  private fun startTimerTask() {
    val t = Timer()
    t.schedule(object : TimerTask() {
      override fun run() {
        if (taskList.isEmpty())
          return

        val taskIterator = taskList.iterator()
        while (taskIterator.hasNext()) {
          val task = taskIterator.next()

          task.progress += 17
          if (task.progress > task.duration) {
            task.progress = task.duration
          }

          if (task.progress == task.duration) {
            if (!task.convert) {
              task.startAngle -= 40
              if (task.startAngle < 0)
                task.startAngle += 360
            }
            task.progress = 0
            task.convert = !task.convert
          }

          task.progressFloat = task.progress / task.duration.toFloat()
          task.interpolatorProgress = interpolator(task.progress / task.duration.toFloat())
          task.currentAngle = (320 * task.interpolatorProgress).toInt()
          post { task.onProgress(task)  }
        }
      }
    }, 0, 16)
    timer = t
  }

  private fun drawRotation(task: AnimTask) {
    val centerX = measuredWidth.shr(1)
    val centerY = measuredHeight.shr(1)
    bufferMatrix.reset()
    bufferMatrix.postRotate(task.progressFloat * 360f, centerX.toFloat(), centerY.toFloat())
    bufferCanvas.setMatrix(bufferMatrix)
  }

  private fun purgeTimer() {
    timer?.let {
      it.cancel()
      it.purge()
    }
    timer = null
    taskList.clear()
  }

  private fun interpolator(x: Float) = x * x * (3 - 2 * x)

  private data class AnimTask(
    var startAngle: Int = 0,
    val duration: Int = 700,
    var progress: Int = 0,
    var interpolatorProgress: Float = 0f,
    var progressFloat: Float = 0f,
    var convert: Boolean = false,
    var currentAngle: Int = 0,
    val onProgress: (AnimTask) -> Unit
  )
}

package org.ar.call.views

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
  private var cardPadding: Float
  private var strokeWidth: Float
  private var strokeColor: Int
  private var text: String = ""

  private val rectF = RectF()
  private val paint = Paint()

  private lateinit var bufferCanvas: Canvas
  private lateinit var bufferBitmap: Bitmap
  private val bufferMatrix = Matrix()

  private val taskList: LinkedList<AnimTask> = LinkedList()

  private var timer: Timer? = null

  init {
    val defCircleRadius = context.resources.getDimension(R.dimen.dp12)
    val defCardPadding = context.resources.getDimension(R.dimen.dp5)
    val defStrokeWidth = context.resources.getDimension(R.dimen.dp2)
    val defStrokeColor = ContextCompat.getColor(context, R.color.purple_200)
    if (attrs != null) {
      val attrSet = context.resources.obtainAttributes(attrs, R.styleable.MaterialLoadingProgress)
      circleRadius = attrSet.getDimension(R.styleable.MaterialLoadingProgress_loadingProgress_circleRadius, defCircleRadius)
      cardPadding = attrSet.getDimension(R.styleable.MaterialLoadingProgress_loadingProgress_cardPadding, defCardPadding)
      strokeWidth = attrSet.getDimension(R.styleable.MaterialLoadingProgress_loadingProgress_strokeWidth, defStrokeWidth)
      strokeColor = attrSet.getColor(R.styleable.MaterialLoadingProgress_loadingProgress_strokeColor, defStrokeColor)
      text = attrSet.getString(R.styleable.MaterialLoadingProgress_loadingProgress_text) ?: ""
      attrSet.recycle()
    } else {
      circleRadius = defCircleRadius
      cardPadding = defCardPadding
      strokeWidth = defStrokeWidth
      strokeColor = defStrokeColor
    }
    paint.textSize = context.resources.getDimension(R.dimen.sp14)
  }

  override fun onDraw(canvas: Canvas) {
    val centerX = measuredWidth.shr(1)
    val centerY = measuredHeight.shr(1)

    val rectHalfDimension = circleRadius + cardPadding
    rectF.set(
      centerX - rectHalfDimension,
      centerY - rectHalfDimension,
      centerX + rectHalfDimension,
      if (text == "") centerY + paint.textSize + rectHalfDimension else centerY + rectHalfDimension
    )

    paint.color = Color.WHITE
    canvas.drawRect(rectF, paint)

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
        rectF, task.startAngle.toFloat(), -(340.0f - task.currentAngle.toFloat()), false, paint
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
    if (!this::bufferBitmap.isInitialized) {
      initCanvas()
    }

    taskList.add(AnimTask(done = {
      it.startAngle = 360 % (it.startAngle + 340)
      it.progress = 0
      it.convert = !it.convert
      taskList.add(it)
    }))
    startTimerTask()
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
          val progressFloat = task.duration.toFloat() / task.progress
          task.currentAngle = (340 * progressFloat).toInt()
          post { drawFrame(task) }

          if (task.progress == task.duration) {
            task.done.invoke(task)
            taskIterator.remove()
          }
        }
      }
    }, 0, 17)
    timer = t
  }

  private fun purgeTimer() {
    timer?.let {
      it.cancel()
      it.purge()
    }
    timer = null
    taskList.clear()
  }

  private data class AnimTask(
    val done: (AnimTask) -> Unit,
    var startAngle: Int = 0,
    val duration: Int = 500,
    var progress: Int = 0,
    var convert: Boolean = false
  ) {
    var endAngle: Int = 0
    private set

    var currentAngle: Int = 0

    init {
      endAngle = if ((startAngle - 20) < 0) (startAngle - 20) + 360 else startAngle - 20
    }
  }
}

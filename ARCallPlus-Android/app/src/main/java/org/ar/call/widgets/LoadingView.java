package org.ar.call.widgets;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;

import androidx.annotation.Nullable;

import org.ar.call.R;

import java.util.Timer;
import java.util.TimerTask;


public class LoadingView extends View {

  // 渐出动画 因缓冲问题暂时取消
  private float percent = 0.0f;
  private final float verticalOffset;
  private float contentWidth;
  private float contentHeight;

  // 颜色渐变
  private final ColorTransition ct;
  private final Paint paint;
  private final RectF rectF;
  private int centerX;
  private int centerY;

  // colors
  private final int[] originColors = new int[12];

  private int counting = 1;
  private String text = "";

  // 缓冲层
  private Bitmap mBufferBitmap;
  private Canvas mBufferCanvas;

  // 遮照颜色 (mask) 默认灰色
  private int backgroundMaskColor = Color.parseColor("#3F000000");
  // 卡片颜色 默认白色
  private int cardColor = Color.WHITE;
  // 字体颜色 默认灰色
  private int fontColor = Color.parseColor("#999999");
  // 光圈颜色  默认起始灰色 结尾浅灰色
  private int startRoundColor = Color.parseColor("#DCDCDC");
  private int endRoundColor = Color.parseColor("#929292");
  // 光圈半径，默认卡片去除文字剩余空间的30%
  private float radius = 0.30f;
  // 卡片内边距(padding) 默认45pixel
  private float cardPadding = 45.0f;

  private Timer timer = new Timer();

  public LoadingView(Context context) {
    this(context, null);
  }

  public LoadingView(Context context, @Nullable AttributeSet attrs) {
    this(context, attrs, 0);
  }

  public LoadingView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
    super(context, attrs, defStyleAttr);

    this.ct = new ColorTransition(Color.parseColor("#00000000"), backgroundMaskColor);
    final Resources res = getResources();
    this.verticalOffset = res.getDimension(R.dimen.dp25);
    this.rectF = new RectF();
    float progressWidth = res.getDimension(R.dimen.dp35);

    this.paint = new Paint(Paint.ANTI_ALIAS_FLAG);
    this.paint.setTextSize(res.getDimension(R.dimen.sp14));

    this.upgradeColors();
    //final Typeface helvetica = Typeface.createFromAsset(res.getAssets(), "fonts/helvetica.ttf");
    //Log.e("typeface: ", helvetica.toString());
    //this.paint.setTypeface(helvetica);
    timer.schedule(new TimerTask() {
      @Override
      public void run() {
        if (!hidden)
          post(() -> drawLoad(mBufferCanvas));
                /* if (percent < 1.0f) {
                    setPercent(percent + 0.08f);
                } else {
                    // timer.cancel();
                    timer.purge();

                    timer = new Timer();
                    timer.schedule(new TimerTask() {
                        @Override
                        public void run() {
                            drawLoad(mBufferCanvas);
                        }
                    }, 128, 128);
                } */
      }
    }, 0, 128);
  }

  private void upgradeColors() {
    final ColorTransition tempCt = new ColorTransition(
        this.startRoundColor, this.endRoundColor
    );
    for (int i = 0; i < 12; ++i) {
      originColors[i] = tempCt.getValue((i + 1) * 0.0834f);
    }
  }

  @SuppressLint("DrawAllocation")
  @Override
  protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
    super.onMeasure(widthMeasureSpec, heightMeasureSpec);
    int mWidth = MeasureSpec.getSize(widthMeasureSpec);
    int mHeight = MeasureSpec.getSize(heightMeasureSpec);

    if (mWidth <= 0 || mHeight <= 0) {
      if (mWidth <= 0) {
        mWidth = 500;
      }
      if (mHeight <= 0) {
        mHeight = 300;
      }
      setMeasuredDimension(
          MeasureSpec.makeMeasureSpec(mWidth, MeasureSpec.EXACTLY),
          MeasureSpec.makeMeasureSpec(mHeight, MeasureSpec.EXACTLY)
      );
    }

    this.centerX = mWidth >> 1;
    this.centerY = mHeight >> 1;

    mBufferBitmap = Bitmap.createBitmap(mWidth, mHeight, Bitmap.Config.ARGB_8888);
    mBufferCanvas = new Canvas(mBufferBitmap);
  }

  @Override
  protected void onDraw(Canvas canvas) {
    canvas.drawBitmap(mBufferBitmap, 0, 0, null);
  }

  private void mDraw(Canvas canvas) {
    if (mBufferBitmap == null || canvas == null) {
      percent = 0.0f;
      return;
    }

    final int color = ct.getValue(percent);
    final float offset = (1.0f - percent) * verticalOffset;

    canvas.drawColor(color);

    canvas.save();
    canvas.translate(0, offset);

    final float left = this.centerX - this.contentWidth / 2.0f;
    final float top = this.centerY - this.contentHeight / 2.0f;
    final float right = this.centerX + this.contentWidth / 2.0f;
    final float bottom = this.centerY + this.contentHeight / 2.0f;
    rectF.set(
        left, top, right, bottom
    );

    this.paint.setColor(this.cardColor);
    canvas.drawRoundRect(rectF, 12f, 12f, this.paint);
    canvas.restore();

    invalidate();
  }

  private void drawLoad(Canvas canvas) {
    if (mBufferBitmap == null || canvas == null)
      return;

    mBufferBitmap.eraseColor(Color.TRANSPARENT);

    final float offset = (1.0f - percent) * verticalOffset;

    final float left = this.centerX - this.contentWidth / 2.0f;
    final float top = this.centerY - this.contentHeight / 2 + offset;
    final float right = this.centerX + this.contentWidth / 2.0f;
    final float bottom = this.centerY + this.contentHeight / 2 + offset;

    // final int color = ct.getValue(percent);
    canvas.drawColor(this.backgroundMaskColor);
        /*

    private int fontColor = Color.parseColor("#333333");
    // 光圈颜色  默认起始灰色 结尾浅灰色
    private int startRoundColor = Color.parseColor("#929292");
    private int endRoundColor = Color.parseColor("#DCDCDC");
    // 光圈半径，默认卡片去除文字剩余空间的30%
    private float radius = 0.30f;
    // 卡片内边距(padding) 默认15pixel
    private float cardPadding = 15.0f;
         */

    rectF.set(
        left, top, right, bottom
    );
    this.paint.setColor(this.cardColor);
    canvas.drawRoundRect(rectF, 12f, 12f, this.paint);

    Paint.FontMetrics fontMetrics = this.paint.getFontMetrics();

    // final float fontHeight = fontBottom - fontTop;
    final float progressWidth = right - left;
    final float baseline = bottom - 20.0f - fontMetrics.bottom;
    final float fontWidth = this.paint.measureText(text);
    this.paint.setColor(this.fontColor); // draw text
    canvas.drawText(text, (progressWidth / 2 - fontWidth / 2) + left, baseline, this.paint);

    final float progressBottom = baseline + fontMetrics.top + 5.0f;
    final float progressHeight = progressBottom - top;

    float finalRadius = (progressHeight - cardPadding * 2.0f) * this.radius;
    final float maxRadius = 30.0f;
    final float minRadius = 25.0f;
    if (finalRadius > maxRadius) {
      finalRadius = maxRadius;
    } else if (finalRadius < minRadius) {
      finalRadius = minRadius;
    }
    final float dx = left + progressWidth / 2.0f;
    final float dy = top + progressHeight / 2.0f;

    canvas.save();

    canvas.translate(dx, dy);
    for (int i = counting, j = 0; j < 12; ++i, ++j) {
      final int index = (j + ((12 - counting % 12) % 12)) % 12;
      this.paint.setColor(originColors[index]);

      canvas.rotate(30);
      this.rectF.set(finalRadius, -5.0f, finalRadius * 2, 5.0f);
      canvas.drawRoundRect(this.rectF, 7.5f, 7.5f, this.paint);
    }

    canvas.restore();

    counting++;
    invalidate();
  }

  private void setPercent(float percent) {
    if (percent > 1.0f)
      percent = 1.0f;
    if (percent < 0.0f)
      percent = 0.0f;

    this.percent = percent;
    mDraw(mBufferCanvas);
    // invalidate();
  }

  public void setBackgroundMaskColor(int color) {
    this.backgroundMaskColor = color;
  }

  public void setCardColor(int color) {
    this.cardColor = color;
  }

  public void setFontColor(int color) {
    this.fontColor = color;
  }

  public void setRoundColor(int startColor, int endColor) {
    this.startRoundColor = startColor;
    this.endRoundColor = endColor;
  }

  /**
   * must be 0.0f ~ 1.0f
   */
  public void setRadiusPercent(float radius) {
    if (radius < 0.0f || radius > 1.0f) {
      throw new IllegalArgumentException();
    }

    this.radius = radius;
  }

  public void setCardPadding(float padding) {
    this.cardPadding = padding;
  }

  public void showLoading(String text) {
    this.text = text;
    final float fontWidth = this.paint.measureText(text);
    this.contentHeight = this.contentWidth = (this.cardPadding * 2.0f) + fontWidth;

        /* post(new Runnable() {
                    @Override
                    public void run() {
                        invalidate();
                    }
                }); */
    // invalidate();
    if (hidden) {
      this.hidden = false;
      this.setVisibility(View.VISIBLE);
    }
  }

  private boolean hidden = true;

  public void hideLoading() {
    if (hidden) {
      return;
    }
//        timer.cancel();

    if (null != this.mBufferBitmap) {
      this.mBufferBitmap.eraseColor(Color.TRANSPARENT);
      invalidate();
    }
        /* timer.schedule(new TimerTask() {
            @Override
            public void run() {
                if (percent < 0.0f) {
                    timer.cancel();
                    timer.purge();
                    return;
                }
                setPercent(percent - 0.08f);
            }
        }, 16, 16); */
    this.hidden = true;
    this.setVisibility(View.GONE);
  }

  @Override
  public boolean onTouchEvent(MotionEvent event) {
    performClick();
    Log.e("DEBUG: ", String.format("hidden: %s", hidden));
    return !this.hidden;
  }

  @Override
  protected void onDetachedFromWindow() {
    timer.purge();
    timer.cancel();
    timer = null;
    super.onDetachedFromWindow();
  }

  @Override
  public boolean performClick() {
    return super.performClick();
  }
}

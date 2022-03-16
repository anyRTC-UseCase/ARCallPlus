package org.ar.call.widgets;

import android.graphics.Color;

public class ColorTransition {

  private final int fromColor;
  private final int toColor;

  public ColorTransition(int beginColor, int endColor) {
    this.fromColor = beginColor;
    this.toColor = endColor;
  }

  public int getValue(float percentage) {
    int fromA = Color.alpha(fromColor);
    int fromR = Color.red(fromColor);
    int fromG = Color.green(fromColor);
    int fromB = Color.blue(fromColor);

    int toA = Color.alpha(toColor);
    int toR = Color.red(toColor);
    int toG = Color.green(toColor);
    int toB = Color.blue(toColor);

    return Color.argb(
        (int) (fromA + ((toA - fromA) * percentage)),
        (int) (fromR + ((toR - fromR) * percentage)),
        (int) (fromG + ((toG - fromG) * percentage)),
        (int) (fromB + ((toB - fromB) * percentage))
    );
  }
}

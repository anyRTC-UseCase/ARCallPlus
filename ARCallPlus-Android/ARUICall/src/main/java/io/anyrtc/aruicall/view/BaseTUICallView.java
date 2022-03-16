package io.anyrtc.aruicall.view;

import android.app.NotificationManager;
import android.content.Context;
import android.widget.RelativeLayout;

public abstract class BaseTUICallView extends RelativeLayout {

    protected Context         mContext;
    public BaseTUICallView(Context context) {
        super(context);
        initView();
        mContext = context;
    }



    protected abstract void initView();

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        NotificationManager notificationManager =
                (NotificationManager) mContext.getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancelAll();
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
    }

    protected void finish(){}



}

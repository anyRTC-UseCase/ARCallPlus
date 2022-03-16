package io.anyrtc.aruicall.view;

import android.content.Context;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.widget.RelativeLayout;

import java.util.ArrayList;
import java.util.Iterator;

import io.anyrtc.aruicall.ARUICalling;
import io.anyrtc.aruicall.utils.LayoutUtils2;

/**
 */
public class ARTCGroupVideoLayoutManager extends RelativeLayout {
    private static final String TAG = "GroupVideoLayoutMng";

    public static final int MAX_USER = 9;

    private String  mSelfUserId;
    private Context mContext;
    private int     mCount     = 0;
    private boolean mInitParam = false;
    private ARUICalling.Type type;

    private ArrayList<LayoutParams>     mGrid1ParamList;
    private ArrayList<LayoutParams>     mGrid2ParamList;
    private ArrayList<LayoutParams>     mGrid3ParamList;
    private ArrayList<LayoutParams>     mGrid4ParamList;
    private ArrayList<LayoutParams>     mGrid9ParamList;
    private ArrayList<RTCLayoutEntity> mLayoutEntityList;
    private UserNoResponseListener noResponseListener;

    public void setNoResponseListener(UserNoResponseListener noResponseListener) {
        this.noResponseListener = noResponseListener;
    }

    public ARTCGroupVideoLayoutManager(Context context) {
        super(context);
        initView(context);
    }


    public ARTCGroupVideoLayoutManager(Context context, AttributeSet attrs) {
        super(context, attrs);
        initView(context);
    }


    public ARTCGroupVideoLayoutManager(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        initView(context);
    }

    private void initView(Context context) {
        Log.i(TAG, "initView: ");
        mContext = context;
        // 做成正方形
        mLayoutEntityList = new ArrayList<RTCLayoutEntity>();
        this.post(new Runnable() {
            @Override
            public void run() {
                makeGirdLayout(true);
            }
        });
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        final int widthSize = MeasureSpec.getSize(widthMeasureSpec);
        final int heightSize = MeasureSpec.getSize(heightMeasureSpec);

        if (widthSize == 0 && heightSize == 0) {
            // If there are no constraints on size, let FrameLayout measure
            super.onMeasure(widthMeasureSpec, heightMeasureSpec);

            // Now use the smallest of the measured dimensions for both dimensions
            final int minSize = Math.min(getMeasuredWidth(), getMeasuredHeight());
            setMeasuredDimension(minSize, minSize);
            return;
        }

        final int size;
        if (widthSize == 0 || heightSize == 0) {
            // If one of the dimensions has no restriction on size, set both dimensions to be the
            // on that does
            size = Math.max(widthSize, heightSize);
        } else {
            // Both dimensions have restrictions on size, set both dimensions to be the
            // smallest of the two
            size = Math.min(widthSize, heightSize);
        }

        final int newMeasureSpec = MeasureSpec.makeMeasureSpec(size, MeasureSpec.EXACTLY);
        super.onMeasure(newMeasureSpec, newMeasureSpec);
    }

    public void setMySelfUserId(String userId, ARUICalling.Type type) {
        mSelfUserId = userId;
        this.type = type;
    }

    /**
     * 根据 userId 找到已经分配的 View
     */
    public ARTCGroupVideoLayout findVideoCallLayout(String userId) {
        if (userId == null) return null;
        for (RTCLayoutEntity layoutEntity : mLayoutEntityList) {
            if (layoutEntity.userId.equals(userId)) {
                return layoutEntity.layout;
            }
        }
        return null;
    }

    /**
     * 根据 userId 分配对应的 view
     *
     * @param userId
     * @return
     */
    public ARTCGroupVideoLayout allocVideoCallLayout(String userId,boolean noResponseClean) {
        if (userId == null) return null;
        if (mCount > MAX_USER) {
            return null;
        }
        RTCLayoutEntity layoutEntity = new RTCLayoutEntity();
        layoutEntity.userId = userId;
        layoutEntity.layout = new ARTCGroupVideoLayout(mContext,type,noResponseClean);
        layoutEntity.layout.setVisibility(VISIBLE);
        layoutEntity.layout.setUid(userId);
        layoutEntity.layout.setNoResponseListener(noResponseListener);
        mLayoutEntityList.add(layoutEntity);
        addView(layoutEntity.layout);
        mCount++;
        post(new Runnable() {
            @Override
            public void run() {
                makeGirdLayout(true);
            }
        });
        return layoutEntity.layout;
    }

    /**
     * 根据 userId 回收对应的 view
     *
     * @param userId
     */
    public void recyclerVideoCallLayout(String userId) {
        if (userId == null) return;
        Iterator iterator = mLayoutEntityList.iterator();
        while (iterator.hasNext()) {
            RTCLayoutEntity item = (RTCLayoutEntity) iterator.next();
            if (item.userId.equals(userId)) {
                item.layout.releaseView();
                removeView(item.layout);
                iterator.remove();
                mCount--;
                break;
            }
        }
        post(new Runnable() {
            @Override
            public void run() {
                makeGirdLayout(true);
            }
        });
    }

    private RTCLayoutEntity findEntity(ARTCGroupVideoLayout layout) {
        for (RTCLayoutEntity entity : mLayoutEntityList) {
            if (entity.layout == layout) return entity;
        }
        return null;
    }

    private RTCLayoutEntity findEntity(String userId) {
        for (RTCLayoutEntity entity : mLayoutEntityList) {
            if (entity.userId.equals(userId)) return entity;
        }
        return null;
    }

    /**
     * 切换到九宫格布局
     *
     * @param needUpdate 是否需要更新布局
     */
    private void makeGirdLayout(boolean needUpdate) {
        if (!mInitParam) {
            mGrid1ParamList = LayoutUtils2.initGrid1Param(getContext(), getWidth(), getHeight());
            mGrid2ParamList = LayoutUtils2.initGrid2Param(getContext(), getWidth(), getHeight());
            mGrid3ParamList = LayoutUtils2.initGrid3Param(getContext(), getWidth(), getHeight());
            mGrid4ParamList = LayoutUtils2.initGrid4Param(getContext(), getWidth(), getHeight());
            mGrid9ParamList = LayoutUtils2.initGrid9Param(getContext(), getWidth(), getHeight());
            mInitParam = true;
        }
        if (needUpdate) {
            if (mLayoutEntityList.isEmpty()) {
                return;
            }
            ArrayList<LayoutParams> paramList;
            if (mCount <= 1) {
                paramList = mGrid1ParamList;
                RTCLayoutEntity entity = mLayoutEntityList.get(0);
                entity.layout.setLayoutParams(paramList.get(0));
                return;
            } else if (mCount == 2) {
                paramList = mGrid2ParamList;
            } else if (mCount == 3) {
                paramList = mGrid3ParamList;
            } else if (mCount == 4) {
                paramList = mGrid4ParamList;
            } else {
                paramList = mGrid9ParamList;
            }
            int layoutIndex = TextUtils.isEmpty(mSelfUserId) ? 0 : 1;
            for (int i = 0; i < mLayoutEntityList.size(); i++) {
                RTCLayoutEntity entity = mLayoutEntityList.get(i);
                // 我自己要放在布局的左上角
                if (entity.userId.equals(mSelfUserId)) {
                    entity.layout.setLayoutParams(paramList.get(0));
                } else if (layoutIndex < paramList.size()) {
                    entity.layout.setLayoutParams(paramList.get(layoutIndex++));
                }
            }
        }
    }

    public int  getCount(){
        return mCount;
    }



    private static class RTCLayoutEntity {
        public ARTCGroupVideoLayout layout;
        public String               userId = "";
    }

    protected interface UserNoResponseListener{
        void noResponse(String userId);
    }
}

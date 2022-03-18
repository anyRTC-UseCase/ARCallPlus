package io.anyrtc.aruicall.view;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.TextureView;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;


import org.ar.rtc.RtcEngine;
import org.webrtc.TextureViewRenderer;

import java.util.concurrent.TimeUnit;

import io.anyrtc.aruicall.ARUICalling;
import io.anyrtc.aruicall.R;
import io.anyrtc.aruicall.utils.ImageLoader;
import io.anyrtc.aruicall.utils.Interval;
import kotlin.Unit;
import kotlin.jvm.functions.Function1;

/**
 * Module: RTCGroupVideoLayout
 * 视频通话界面中，显示多个用户的自定义布局
 */
public class ARTCGroupVideoLayout extends RelativeLayout {
    private static final int MIN_AUDIO_VOLUME = 10;

    private TextureView videoView;
    private ProgressBar          mProgressAudio;
    private RoundCornerImageView mImageHead;
    private TextView             mTextUserName;
    private ImageView            mImageAudioInput;
    private ImageView            mImgLoading;
    private ARUICalling.Type type;
    private Interval interval;
    private String uid;

    private boolean mMuteAudio = false; // 静音状态 true : 开启静音
    private ARTCGroupVideoLayoutManager.UserNoResponseListener noResponseListener;
    private boolean needNotifyNoResponse = true;


    public void setNoResponseListener(ARTCGroupVideoLayoutManager.UserNoResponseListener noResponseListener) {
        this.noResponseListener = noResponseListener;
    }

    public void setUid(String uid) {
        this.uid = uid;
    }

    public ARTCGroupVideoLayout(Context context, ARUICalling.Type type, Boolean needClean) {
        super(context);
        this.type = type;
        initView();
        setClickable(true);
        if (needClean) {
            interval = new Interval(1L, TimeUnit.SECONDS, 1L);
            interval.setEnd(30);
            interval.finish(new Function1<Long, Unit>() {
                @Override
                public Unit invoke(Long aLong) {
                    Log.d("interval", aLong + "finish");
                    if (noResponseListener!=null&&needNotifyNoResponse){
                        noResponseListener.noResponse(uid);
                    }
                    return null;
                }
            });
            interval.start();
        }
    }

    public ARTCGroupVideoLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
    }


    public TextureView getVideoView() {
        return videoView;
    }

    public RoundCornerImageView getHeadImg() {
        return mImageHead;
    }

    public void setVideoAvailable(boolean available) {
        if (available) {
            videoView.setVisibility(VISIBLE);
            mImageHead.setVisibility(GONE);
            mTextUserName.setVisibility(VISIBLE);
        } else {
            videoView.setVisibility(GONE);
            mImageHead.setVisibility(VISIBLE);
            mTextUserName.setVisibility(VISIBLE);
        }
    }

    public void setRemoteIconAvailable(boolean available) {
        mImageHead.setVisibility(available ? VISIBLE : GONE);
        mTextUserName.setVisibility(available ? VISIBLE : GONE);
    }

    public void setAudioVolumeProgress(int progress) {
        if (mProgressAudio != null) {
            mProgressAudio.setProgress(progress);
        }
    }

    public void setAudioVolumeProgressBarVisibility(int visibility) {
        if (mProgressAudio != null) {
            mProgressAudio.setVisibility(visibility);
        }
    }

    private void initView() {
        LayoutInflater.from(getContext()).inflate(R.layout.aruicalling_group_videocall_item_user_layout, this, true);
        if (type == ARUICalling.Type.VIDEO) {
            videoView = RtcEngine.CreateRendererView(getContext());
            addView(videoView, 0, new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        }
        mProgressAudio = findViewById(R.id.progress_bar_audio);
        mImageHead = findViewById(R.id.img_head);
        mTextUserName = findViewById(R.id.tv_name);
        mImageAudioInput = findViewById(R.id.iv_audio_input);
        mImgLoading = (ImageView) findViewById(R.id.img_loading);
        ImageLoader.loadGifImage(getContext(), mImgLoading, R.drawable.aruicalling__loading);
    }

    public void setUserName(String userName) {
        mTextUserName.setText(userName);
    }

    public void setAudioVolume(int vol) {
        if (mMuteAudio) {
            return;
        }
        mImageAudioInput.setVisibility(vol > MIN_AUDIO_VOLUME ? VISIBLE : GONE);
    }

    public void setHeaderUrl(String url){
        ImageLoader.loadImage(getContext(), mImageHead, url);
    }

    public void muteMic(boolean mute) {
        mMuteAudio = mute;
        mImageAudioInput.setVisibility(mMuteAudio ? GONE : VISIBLE);
    }
    public void releaseView(){
        if (videoView!=null){
            if (videoView instanceof TextureViewRenderer){
                ((TextureViewRenderer) videoView).release();
            }
        }
        if (interval!=null){
            interval.stop();
            interval = null;
        }
    }
    public void startLoading() {
        mImgLoading.setVisibility(VISIBLE);
    }

    public void stopLoading() {
        mImgLoading.setVisibility(GONE);
    }

    public void stopInterval(){
        needNotifyNoResponse = false;
        if (interval!=null){
            interval.stop();
            interval = null;
        }
    }
}
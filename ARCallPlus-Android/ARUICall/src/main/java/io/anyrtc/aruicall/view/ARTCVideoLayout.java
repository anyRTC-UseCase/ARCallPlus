package io.anyrtc.aruicall.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.TextureView;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;


import org.ar.rtc.RtcEngine;
import org.webrtc.TextureViewRenderer;

import io.anyrtc.aruicall.ARUICalling;
import io.anyrtc.aruicall.R;

/**
 * Module: RTCVideoLayout
 * <p>
 * Function:
 * <p>
 */
public class ARTCVideoLayout extends RelativeLayout {
    private boolean              mMoveAble;
    private TextureView videoView;
    private ProgressBar          mProgressAudio;
    private RoundCornerImageView mImageHead;
    private TextView             mTextUserName;
    private ImageView mImageAudioInput;
    private ARUICalling.Type type;



    public ARTCVideoLayout(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public ARTCVideoLayout(Context context, ARUICalling.Type type) {
        super(context);
        this.type = type;
        initView();
        setClickable(true);
    }

    public void setType(ARUICalling.Type type) {
        this.type = type;
    }

    public TextureView getVideoView() {
        return videoView;
    }

    public void releaseView(){
        if (videoView!=null){
            if (videoView instanceof TextureViewRenderer){
                ((TextureViewRenderer) videoView).release();
            }
        }
    }

    public RoundCornerImageView getHeadImg() {
        return mImageHead;
    }

    public void setVideoAvailable(boolean available) {
        if (available) {
            videoView.setVisibility(VISIBLE);
        } else {
            videoView.setVisibility(GONE);
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
        LayoutInflater.from(getContext()).inflate(R.layout.artccalling_videocall_item_user_layout, this, true);
        if (type== ARUICalling.Type.VIDEO) {
            videoView = RtcEngine.CreateRendererView(getContext());
            addView(videoView, 0, new LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        }
        mProgressAudio = (ProgressBar) findViewById(R.id.progress_bar_audio);
        mImageHead = (RoundCornerImageView) findViewById(R.id.iv_avatar);
        mTextUserName = (TextView) findViewById(R.id.tv_user_name);
        mImageAudioInput = findViewById(R.id.iv_audio_input);
    }

    public boolean isMoveAble() {
        return mMoveAble;
    }

    public void openAudio(boolean enable) {
        mImageAudioInput.setVisibility(enable ? VISIBLE : GONE);
    }

    public void setMoveAble(boolean enable) {
        mMoveAble = enable;
    }

    public void setUserName(String userName) {
        mTextUserName.setText(userName);
    }

    public void setUserNameColor(int color) {
        mTextUserName.setTextColor(color);
    }
}

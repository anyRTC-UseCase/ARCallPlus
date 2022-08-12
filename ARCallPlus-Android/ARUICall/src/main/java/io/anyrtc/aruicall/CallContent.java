package io.anyrtc.aruicall;

import java.util.ArrayList;
import java.util.List;

 class CallContent {
    private int Mode;//1视频0音频
    private boolean Conference;
    private String ChanId;
    private ArrayList<String> UserData;
    private String SipData;
    private ArrayList<ARCallUser> UserInfo;
    private String VidCodec;
    private String AudCodec;
    private int CallType = 0;//1监看 2 上报

     public int getCallType() {
         return CallType;
     }

     public void setCallType(int callType) {
         CallType = callType;
     }

     public int getMode() {
        return Mode;
    }

    public void setMode(int mode) {
        Mode = mode;
    }

    public boolean getConference() {
        return Conference;
    }

    public void setConference(boolean conference) {
        Conference = conference;
    }

    public String getChanId() {
        return ChanId;
    }

    public void setChanId(String chanId) {
        ChanId = chanId;
    }

    public ArrayList<String> getUserData() {
        return UserData;
    }

    public void setUserData(ArrayList<String>  userData) {
        UserData = userData;
    }

    public String getSipData() {
        return SipData;
    }

    public void setSipData(String sipData) {
        SipData = sipData;
    }

    public ArrayList<ARCallUser> getUserInfo() {
        return UserInfo;
    }

    public void setUserInfo(ArrayList<ARCallUser> userInfo) {
        UserInfo = userInfo;
    }

    public boolean isConference() {
        return Conference;
    }

    public String getVidCodec() {
        return VidCodec;
    }

    public void setVidCodec(String vidCodec) {
        VidCodec = vidCodec;
    }

    public String getAudCodec() {
        return AudCodec;
    }

    public void setAudCodec(String audCodec) {
        AudCodec = audCodec;
    }

    @Override
    public String toString() {
        return "CallContent{" +
                "Mode=" + Mode +
                ", Conference=" + Conference +
                ", ChanId='" + ChanId + '\'' +
                ", UserData=" + UserData +
                ", SipData='" + SipData + '\'' +
                ", UserInfo=" + UserInfo +
                '}';
    }
}

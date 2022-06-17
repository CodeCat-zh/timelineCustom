using System;
using UnityEngine.Timeline;
using UnityEditor.Timeline;
using PJBNEditor.Cutscene;
public class CreateTrackInfo
{
    public string createTrackMenuName = "";
    public string createClipMenuName = "";
    public Type trackType = null;
    public Type clipType = null;
    public bool isSingleTrack = false;
    public GroupTrackType trackGroupType;
    public string trackName = "";
    public string clipName = "";
    public string trackExtParams = null;
    public string clipExtParams = null;
    public bool canDeleteSelf = true;
    public bool canAddInMenu = true;


    public delegate bool CheckIsTrackInfoCallback(TrackAsset trackAsset, CreateTrackInfo createTrackInfo);
    public delegate void AddTrackCallback(TrackAsset trackAsset, CreateTrackInfo createTrackInfo, string extParams = null);
    public delegate void AddClipCallback(TimelineClip timelineClip, CreateTrackInfo createTrackInfo, string extParams = null);
    public delegate TrackAsset AddTrackFunc(Type trackType, TrackAsset parentTrack, string trackName, string extParams);

    public delegate void AddClipFunc(TrackAsset trackAsset, CreateTrackInfo createTrackInfo, string extParams);
    public AddTrackCallback addTrackCallback;
    public AddClipCallback addClipCallback;
    public CheckIsTrackInfoCallback checkIsTrackInfoCallback;
    public AddClipFunc addClipFunc;
    public AddTrackFunc addTrackFunc;

    public CreateTrackInfo()
    {

    }

    public CreateTrackInfo(string createTrackMenuName, string createClipMenuName, Type trackType, Type clipType, bool isSingleTrack, GroupTrackType trackGroupType, string trackName, string clipName, bool canDeleteSelf, bool canAddInMenu, CheckIsTrackInfoCallback checkIsTrackInfoCallback = null,
        AddClipFunc addClipFunc = null, AddTrackCallback addTrackCallback = null,
        AddClipCallback addClipCallback = null, string trackExtParams = null, string clipExtParams = null)
    {
        this.createTrackMenuName = createTrackMenuName;
        this.createClipMenuName = createClipMenuName;
        this.trackType = trackType;
        this.clipType = clipType;
        this.isSingleTrack = isSingleTrack;
        this.trackGroupType = trackGroupType;
        this.trackName = trackName;
        this.clipName = clipName;
        this.canDeleteSelf = canDeleteSelf;
        this.canAddInMenu = canAddInMenu;
        this.addTrackCallback = addTrackCallback;
        this.addClipCallback = addClipCallback;
        this.addClipFunc = addClipFunc;
        this.checkIsTrackInfoCallback = checkIsTrackInfoCallback;
        this.trackExtParams = trackExtParams;
        this.clipExtParams = clipExtParams;
    }

    public bool CheckIsTrackInfo(TrackAsset trackAsset)
    {
        if (checkIsTrackInfoCallback != null)
        {
            return checkIsTrackInfoCallback(trackAsset, this);
        }
        var trackType = trackAsset.GetType();
        return this.trackType == trackType;
    }

    public void AddClip(TrackAsset trackAsset, string extParams)
    {
        if (addClipFunc != null)
        {
            addClipFunc(trackAsset, this, extParams);
            return;
        }
        var clip = trackAsset.CreateDefaultClip();
        clip.displayName = this.clipName;
        if (this.addClipCallback != null)
        {
            this.addClipCallback(clip, this, extParams);
        }
        TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
    }
}
using UnityEngine.Timeline;
using PJBNEditor.Cutscene;
using LitJson;
using System;

public class CreateActorFollowTrackInfo : CreateTrackInfo
{
    public CreateActorFollowTrackInfo()
    {
        this.createTrackMenuName = "新增角色跟随轨道";
        this.createClipMenuName = "新增跟随片段";
        this.trackType = typeof(E_CutsceneActorFollowTrack);
        this.clipType = typeof(E_CutsceneActorFollowPlayableAsset);
        this.isSingleTrack = true;
        this.trackGroupType = GroupTrackType.Actor;
        this.trackName = "角色跟随轨道";
        this.clipName = "角色跟随片段";
        this.canDeleteSelf = true;
        this.canAddInMenu = true;
        this.checkIsTrackInfoCallback = CheckIsTrackInfoCallback;
        this.addClipCallback = AddTrackCallback;
    }

    bool CheckIsTrackInfoCallback(TrackAsset trackAsset, CreateTrackInfo createTrackInfo)
    {
        var type = trackAsset.GetType();
        if (type == createTrackInfo.trackType)
        {
            if ((CutsceneEditorUtil.CheckTrackIsActorSubTrack(trackAsset) || trackAsset.parent.GetType() == typeof(E_CutsceneActorFollowTrack)))
            {
                return true;
            }
        }
        return false;
    }
    
    void AddTrackCallback(TimelineClip timelineClip, CreateTrackInfo createTrackInfo,string extParams = null)
    {
        if (extParams == null)
        {
            return;
        }

        var extParamsInfo = JsonMapper.ToObject<ExtParamsInfo>(extParams);
        var customParams = extParamsInfo.customExtParams;
        var key = Int32.Parse(customParams[0]);
        var script = timelineClip.asset as E_CutsceneActorFollowPlayableAsset;
        script.key = key;
    }
}


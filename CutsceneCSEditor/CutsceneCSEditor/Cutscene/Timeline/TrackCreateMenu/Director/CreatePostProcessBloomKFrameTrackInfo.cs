using PJBN.Cutscene;

namespace PJBNEditor.Cutscene
{
    public class CreatePostProcessBloomKFrameTrackInfo: CreateTrackInfo
    {
        public CreatePostProcessBloomKFrameTrackInfo()
        {
            this.createTrackMenuName = "新增后处理K帧轨道/Bloom K帧";
            this.createClipMenuName = "新增Bloom K帧片段";
            this.trackType = typeof(E_CutscenePostProcessBloomKFrameTrack);
            this.clipType = typeof(E_CutscenePostProcessBloomKFramePlayableAsset);
            this.isSingleTrack = true;
            this.trackGroupType = GroupTrackType.Director;
            this.trackName = "Bloom K帧轨道";
            this.clipName = "Bloom K帧片段";
            this.canDeleteSelf = true;
            this.canAddInMenu = true;
        }
    }
}
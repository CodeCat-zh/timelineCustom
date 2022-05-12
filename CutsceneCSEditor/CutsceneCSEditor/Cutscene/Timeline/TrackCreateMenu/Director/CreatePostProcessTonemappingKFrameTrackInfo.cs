using PJBN.Cutscene;

namespace PJBNEditor.Cutscene
{
    public class CreatePostProcessTonemappingKFrameTrackInfo: CreateTrackInfo
    {
        public CreatePostProcessTonemappingKFrameTrackInfo()
        {
            this.createTrackMenuName = "新增后处理K帧轨道/Tonemapping K帧";
            this.createClipMenuName = "新增Tonemapping K帧片段";
            this.trackType = typeof(E_CutscenePostProcessTonemappingKFrameTrack);
            this.clipType = typeof(E_CutscenePostProcessTonemappingKFramePlayableAsset);
            this.isSingleTrack = true;
            this.trackGroupType = GroupTrackType.Director;
            this.trackName = "Tonemapping K帧轨道";
            this.clipName = "Tonemapping K帧片段";
            this.canDeleteSelf = true;
            this.canAddInMenu = true;
        }
    }
}
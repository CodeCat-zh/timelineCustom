using PJBN.Cutscene;

namespace PJBNEditor.Cutscene
{
    public class CreatePostProcessVignetteKFrameTrackInfo: CreateTrackInfo
    {
        public CreatePostProcessVignetteKFrameTrackInfo()
        {
            this.createTrackMenuName = "新增后处理K帧轨道/Vignette K帧";
            this.createClipMenuName = "新增Vignette K帧片段";
            this.trackType = typeof(E_CutscenePostProcessVignetteKFrameTrack);
            this.clipType = typeof(E_CutscenePostProcessVignetteKFramePlayableAsset);
            this.isSingleTrack = true;
            this.trackGroupType = GroupTrackType.Director;
            this.trackName = "Vignette K帧轨道";
            this.clipName = "Vignette K帧片段";
            this.canDeleteSelf = true;
            this.canAddInMenu = true;
        }
    }
}
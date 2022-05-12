using PJBN.Cutscene;

namespace PJBNEditor.Cutscene
{
    public class CreateActorGhostTrackInfo: CreateTrackInfo
    {
        public CreateActorGhostTrackInfo()
        {
            this.createTrackMenuName = "新增残影轨道";
            this.createClipMenuName = "新增残影片段";
            this.trackType = typeof(E_CutsceneActorGhostTrack);
            this.clipType = typeof(E_CutsceneGhostPlayableAsset);
            this.isSingleTrack = true;
            this.trackGroupType = GroupTrackType.Actor;
            this.trackName = "残影轨道";
            this.clipName = "残影片段";
            this.canDeleteSelf = true;
            this.canAddInMenu = true;
            this.addClipCallback = CutsTimelineCreateConstant.ActorClipCommonAddCallback;
        }
    }
}
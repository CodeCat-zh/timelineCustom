namespace PJBNEditor.Cutscene
{
    public class CreateChangeMaterialTrackInfo: CreateTrackInfo
    {
        public CreateChangeMaterialTrackInfo()
        {
            this.createTrackMenuName = "新增替换材质轨道";
            this.createClipMenuName = "新增替换材质片段";
            this.trackType = typeof(E_CutsceneChangeMaterialTrack);
            this.clipType = typeof(E_CutsceneChangeMaterialPlayableAsset);
            this.isSingleTrack = false;
            this.trackGroupType = GroupTrackType.SceneEffectGroup;
            this.trackName = "替换材质轨道";
            this.clipName = "替换材质片段";
            this.canDeleteSelf = true;
            this.canAddInMenu = true;
        }
    }
}
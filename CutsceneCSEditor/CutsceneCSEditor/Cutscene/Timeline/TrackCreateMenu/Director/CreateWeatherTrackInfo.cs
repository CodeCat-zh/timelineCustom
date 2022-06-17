using PJBN.Cutscene;

namespace PJBNEditor.Cutscene
{
    public class CreateWeatherTrackInfo: CreateTrackInfo
    {
        public CreateWeatherTrackInfo()
        {
            this.createTrackMenuName = "新增天气轨道";
            this.createClipMenuName = "新增天气片段";
            this.trackType = typeof(E_CutsceneWeatherTrack);
            this.clipType = typeof(E_CutsceneWeatherPlayableAsset);
            this.isSingleTrack = true;
            this.trackGroupType = GroupTrackType.Director;
            this.trackName = "天气轨道";
            this.clipName = "天气片段";
            this.canDeleteSelf = true;
            this.canAddInMenu = true;
        }
    }
}
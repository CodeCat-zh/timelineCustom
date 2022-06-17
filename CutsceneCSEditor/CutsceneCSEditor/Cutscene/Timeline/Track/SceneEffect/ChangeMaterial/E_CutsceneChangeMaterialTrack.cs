using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Timeline;

namespace PJBNEditor.Cutscene
{
    [TrackColor(255f / 255, 80f / 255, 255f / 255)]
    [TrackClipType(typeof(E_CutsceneChangeMaterialPlayableAsset), false)]
    [ExcludeFromPreset]
    [TimelineTrackConvert((int)CutsceneTrackType.ChangeRolePartMaterialTrackType, "CutsceneChangeMaterialTrack")]
    public class E_CutsceneChangeMaterialTrack: TrackAsset
    {
        
    }
}
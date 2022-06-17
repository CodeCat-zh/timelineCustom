using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Timeline;
using Polaris.CutsceneEditor;

namespace PJBNEditor.Cutscene
{
    [TrackColor(255f / 255, 80f / 255, 255f / 255)]
    [TrackClipType(typeof(E_CutsceneLightControlPlayableAsset), false)]
    [ExcludeFromPreset]
    [TimelineTrackConvert((int)CutsceneTrackType.DirectorLightControlTrackType, "CutsceneLightControlTrack")]
    public class E_CutsceneLightControlTrack : CutsceneTrackAssetBase
    {

    }
}
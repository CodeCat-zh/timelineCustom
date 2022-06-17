using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.Playables;
using Polaris.CutsceneEditor;

namespace PJBNEditor.Cutscene
{
    [TrackColor(255f / 255, 80f / 255, 255f / 255)]
    [TrackClipType(typeof(E_CutsceneImpulsePlayableAsset), false)]
    [ExcludeFromPreset]
    [TimelineTrackConvert((int)CutsceneTrackType.DirectorImpulseTrackType, "CutsceneImpulseTrack")]
    public class E_CutsceneImpulseTrack : CutsceneTrackAssetBase
    {

    }
}
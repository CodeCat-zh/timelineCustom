using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.Playables;
using Polaris.CutsceneEditor;

namespace PJBNEditor.Cutscene
{
    [TrackColor(255f / 255, 80f / 255, 255f / 255)]
    [TrackClipType(typeof(E_CutsceneTimeScalePlayableAsset), false)]
    [ExcludeFromPreset]
    [TimelineTrackConvert((int)CutsceneTrackType.DirectorTimeScaleTrackType, "CutsceneEffectTrack")]
    public class E_CutsceneTimeScaleTrack : CutsceneTrackAssetBase
    {

    }
}
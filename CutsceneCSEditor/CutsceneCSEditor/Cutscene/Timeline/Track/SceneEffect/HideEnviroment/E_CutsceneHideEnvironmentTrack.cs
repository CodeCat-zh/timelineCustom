using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Timeline;

namespace PJBNEditor.Cutscene
{
    [TrackColor(255f / 255, 80f / 255, 255f / 255)]
    [TrackClipType(typeof(E_CutsceneHideEnvironmentPlayableAsset), false)]
    [TimelineTrackConvert((int)CutsceneTrackType.HideEnvironmentTrackType, "CutsceneHideEnvironmentTrack")]
    public class E_CutsceneHideEnvironmentTrack: TrackAsset
    {
    }
}
using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.Playables;
using Polaris.CutsceneEditor;

namespace PJBNEditor.Cutscene
{
    [TrackColor(0.53f, 0.0f, 0.08f)]
    [TrackClipType(typeof(E_CutsceneDollyCameraPlayableAsset), false)]
    [ExcludeFromPreset]
    [TimelineTrackConvert((int)CutsceneTrackType.DirectorDollyCameraTrackType, "CutsceneDollyCameraTrack")]
    public class E_CutsceneDollyCameraTrack : CutsceneTrackAssetBase
    {

    }
}
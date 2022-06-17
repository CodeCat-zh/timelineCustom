using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.Playables;

namespace Polaris.CutsceneEditor
{
    [TrackColor(152f / 255, 183f / 255, 85f / 255)]
    [TrackClipType(typeof(E_CutsceneActorControlPlayableAsset), false)]
    [ExcludeFromPreset]
    [TimelineTrackConvert((int)PolarisCutsceneTrackType.ActorControlTrackType, "CutsceneActorControlTrack")]
    public class E_CutsceneActorControlTrack : CutsceneTrackAssetBase
    {
    }
}

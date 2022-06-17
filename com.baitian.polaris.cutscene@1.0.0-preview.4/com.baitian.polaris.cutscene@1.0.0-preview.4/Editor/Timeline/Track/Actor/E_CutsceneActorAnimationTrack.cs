using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.Playables;

namespace Polaris.CutsceneEditor
{
    [TrackColor(152f / 255, 183f / 255, 85f / 255)]
    [TrackClipType(typeof(E_CutsceneActorAnimationPlayableAsset), false)]
    [ExcludeFromPreset]
    [TimelineTrackConvert((int)PolarisCutsceneTrackType.ActorAnimationTrackType, "CutsceneActorAnimationTrack")]
    public class E_CutsceneActorAnimationTrack : CutsceneTrackAssetBase
    {

    }
}

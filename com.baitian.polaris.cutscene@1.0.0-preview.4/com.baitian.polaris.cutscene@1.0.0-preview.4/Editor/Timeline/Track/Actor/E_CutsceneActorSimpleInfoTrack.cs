using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Timeline;

namespace Polaris.CutsceneEditor
{
    [TrackColor(152f / 255, 183f / 255, 85f / 255)]
    [TrackClipType(typeof(E_CutsceneActorSimpleInfoPlayableAsset), false)]
    [ExcludeFromPreset]
    [TimelineTrackConvert((int)PolarisCutsceneTrackType.ActorSimpleInfoTrackType, "CutsceneActorSimpleInfoTrack")]
    public class E_CutsceneActorSimpleInfoTrack : CutsceneTrackAssetBase
    {

    }
}

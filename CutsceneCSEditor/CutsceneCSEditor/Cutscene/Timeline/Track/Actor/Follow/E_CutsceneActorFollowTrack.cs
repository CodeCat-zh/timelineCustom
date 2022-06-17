using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Timeline;
using Polaris.CutsceneEditor;

namespace PJBNEditor.Cutscene
{
    [TrackColor(152f / 255, 183f / 255, 85f / 255)]
    [TrackClipType(typeof(E_CutsceneActorFollowPlayableAsset), false)]
    [ExcludeFromPreset]
    [TimelineTrackConvert((int)CutsceneTrackType.ActorFollowTrackType, "CutsceneActorFollowTrack")]
    public class E_CutsceneActorFollowTrack : CutsceneTrackAssetBase
    {

    }
}

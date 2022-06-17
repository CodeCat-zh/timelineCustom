using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.Playables;
using Polaris.ToLuaFramework;

namespace Polaris.CutsceneEditor
{
    [TrackColor(152f / 255, 183f / 255, 85f / 255)]
    [TrackClipType(typeof(E_CutsceneCameraPlayableAsset), false)]
    [ExcludeFromPreset]
    [TimelineTrackConvert((int)PolarisCutsceneTrackType.CameraTrackType, "CutsceneCameraTrack")]
    public class E_CutsceneCameraTrack : CutsceneTrackAssetBase
    {
   
    }
}

using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.Playables;
using Polaris.CutsceneEditor;

namespace PJBNEditor.Cutscene
{
    [TrackColor(152f / 255, 183f / 255, 85f / 255)]
    [TrackClipType(typeof(E_CutsDirectorHideCinemachineClipVirCamPlayableAsset), false)]
    [ExcludeFromPreset]
    [TimelineTrackConvert((int)CutsceneTrackType.HideCinemachineClipVirCamTrackType, "CutsDirectorHideCinemachineClipVirCamTrack")]
    public class E_CutsDirectorHideCinemachineClipVirCamTrack : CutsceneTrackAssetBase
    {

    }
}
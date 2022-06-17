using System.ComponentModel;
using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Timeline;

namespace PJBNEditor.Cutscene
{
    [TrackColor(0.066f, 0.134f, 0.244f)]
    [TrackClipType(typeof(E_CutsceneGhostPlayableAsset))]
    [ExcludeFromPreset]
    [TimelineTrackConvert((int) CutsceneTrackType.GhostTrackType,"CutsceneGhostTrack")]
    public class E_CutsceneActorGhostTrack : TrackAsset
    {
    }
}
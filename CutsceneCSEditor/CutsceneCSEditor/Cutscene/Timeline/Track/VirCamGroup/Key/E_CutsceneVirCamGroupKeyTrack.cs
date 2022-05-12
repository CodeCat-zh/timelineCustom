using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Timeline;

namespace PJBNEditor.Cutscene
{
    [TrackColor(152f / 255, 183f / 255, 85f / 255)]
    [ExcludeFromPreset]
    [OnlyEditTrack]
    public class E_CutsceneVirCamGroupKeyTrack : TrackAsset
    {
        [HideInInspector] public int key;
    }
}
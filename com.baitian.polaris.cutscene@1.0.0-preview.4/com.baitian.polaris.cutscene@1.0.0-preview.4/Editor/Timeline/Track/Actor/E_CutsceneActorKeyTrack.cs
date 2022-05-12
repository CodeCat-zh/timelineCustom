

using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Timeline;

namespace Polaris.CutsceneEditor
{
    [TrackColor(152f / 255, 183f / 255, 85f / 255)]
    [ExcludeFromPreset]
    [OnlyEditTrack]
    public class E_CutsceneActorKeyTrack : TrackAsset
    {
        [HideInInspector] public int key;
    }
}

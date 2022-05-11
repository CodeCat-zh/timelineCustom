using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace Cutscene
{
    [Serializable]
    [TrackClipType(typeof(CommonPlayableAsset))]
    [TrackBindingType(typeof(GameObject))]
    [ExcludeFromPreset]
    public class CommonTrack : TrackAsset
    {
        public int type;
    }
}

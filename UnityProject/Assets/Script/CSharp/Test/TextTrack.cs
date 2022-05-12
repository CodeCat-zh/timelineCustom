using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Timeline;


[Serializable]
[TrackClipType(typeof(TextPlayAsset))]
[TrackBindingType(typeof(GameObject))]
[ExcludeFromPreset]
public class TextTrack : TrackAsset
{

}

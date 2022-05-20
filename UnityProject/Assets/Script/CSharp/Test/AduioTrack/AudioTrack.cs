using System;
using UnityEngine;
using UnityEngine.Timeline;

[Serializable]
[TrackClipType(typeof(AudioPlayableAsset))]
[TrackBindingType(typeof(AudioSource))]
[ExcludeFromPreset]
public class AudioTrack : TrackAsset
{
  
}

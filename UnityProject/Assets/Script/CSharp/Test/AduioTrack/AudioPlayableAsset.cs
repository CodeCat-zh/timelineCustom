using Cutscene;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioPlayableAsset : CommonPlayableAsset
{
    [SerializeField]
    [FieldConvertToString(PlayableFieldEnum.Int)]
    public float volume;
    [FieldConvertToString(PlayableFieldEnum.Vector3)]
    public Vector3 pos;
    [FieldConvertToString(PlayableFieldEnum.GameObejct)]
    public AudioClip audioClip;
    public AudioPlayableAsset()
    {
        this.type = "AudioClip";
    }

}

using Cutscene;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraPlayableAsset : CommonPlayableAsset
{
    [SerializeField]
    [FieldConvertToString(PlayableFieldEnum.Vector3)]
    public Vector3 cameraPos;
    [FieldConvertToString(PlayableFieldEnum.Vector3)]
    public Vector3 cameraRota;
    [FieldConvertToString(PlayableFieldEnum.Float)]
    public float speed;


    public CameraPlayableAsset()
    {
        this.type = "CameraClip";
    }
}

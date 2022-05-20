using Cutscene;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightPlayAsset : CommonPlayableAsset
{
    [SerializeField]
    [FieldConvertToString(PlayableFieldEnum.Vector3)]
    public Vector3 initPos;

    [SerializeField]
    [FieldConvertToString(PlayableFieldEnum.Vector3)]
    public Vector3 initRota;

    [SerializeField]
    [FieldConvertToString(PlayableFieldEnum.Vector3)]
    public Vector3 endRota;

    [SerializeField]
    [FieldConvertToString(PlayableFieldEnum.Float)]
    public float speed;
    [SerializeField]
    [FieldConvertToString(PlayableFieldEnum.Color)]
    public Color lightColor;
    [SerializeField]
    [FieldConvertToString(PlayableFieldEnum.Float)]
    public float lightPower;


    public LightPlayAsset()
    {
        this.type = "LightClip";
    }
}

using Cutscene;
using UnityEngine;

public class TextPlayAsset : CommonPlayableAsset
{
    [SerializeField]
    [FieldConvertToString(PlayableFieldEnum.GameObejct)]
    public GameObject preGameObject;
    [SerializeField]
    [FieldConvertToString(PlayableFieldEnum.Float)]
    public float speed = 1.0f;
    [SerializeField]
    [FieldConvertToString(PlayableFieldEnum.String)]
    public string text = "This is Test About CSharp Executed Lua Function";
    [SerializeField]
    [FieldConvertToString(PlayableFieldEnum.Bool)]
    public bool isPlay = true;
    [SerializeField]
    [FieldConvertToString(PlayableFieldEnum.Int)]
    public int testNum = 1;


    public TextPlayAsset()
    {
        this.type = "TextClip";
    }





}

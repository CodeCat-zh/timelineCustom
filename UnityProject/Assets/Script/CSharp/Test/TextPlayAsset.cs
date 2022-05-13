using Cutscene;
using UnityEngine;
public class TextPlayAsset : CommonPlayableAsset
{
    [FieldConvertToString(PlayableFieldEnum.Float)]
    public float speed = 1.0f; 
    [FieldConvertToString(PlayableFieldEnum.String)]
    public string text = "This is Test About CSharp Executed Lua Function";
    [FieldConvertToString(PlayableFieldEnum.Bool)]
    public bool isPlay = true;
    [FieldConvertToString(PlayableFieldEnum.GameObejct)]
    public GameObject gameObject;


    public TextPlayAsset()
    {
        this.type = "TextClip";
    }
   
}

using Cutscene;
using UnityEngine;
public class TextPlayAsset : CommonPlayableAsset
{
    [FieldConvertToString(PlayableFieldEnum.Float)]
    private float speed = 1.0f;
    [FieldConvertToString(PlayableFieldEnum.String)]
    private string text = "This is Test About CSharp Executed Lua Function";
    [FieldConvertToString(PlayableFieldEnum.Bool)]
    private bool isPlay = true;
    [FieldConvertToString(PlayableFieldEnum.GameObejct)]
    private GameObject preGameObject;
    [FieldConvertToString(PlayableFieldEnum.Int)]
    private int testNum = 1;


    public TextPlayAsset()
    {
        this.type = "TextClip";
    }
   
}

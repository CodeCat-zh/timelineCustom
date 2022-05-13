using Cutscene;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class TimeLineUnities 
{
    public List<string> ConvertFieldToString(CommonPlayableAsset commonPlayableAsset)
    {
        List<string> fieldList = new List<string>();
        Type type = typeof(CommonPlayableAsset);
        foreach(System.Object attributes in type.GetCustomAttributes(false))
        {
            FieldConvertToString fieldConvert = attributes as FieldConvertToString;
            if ( fieldConvert != null )
            {
               
                switch (fieldConvert.FieldEnum)
                {
                    case PlayableFieldEnum.GameObejct:

                        break;
                    case PlayableFieldEnum.Enum:

                        break;
                    case PlayableFieldEnum.Bool:

                        break;
                    case PlayableFieldEnum.Int:

                        break;
                    case PlayableFieldEnum.Float:

                        break;
                    case PlayableFieldEnum.String:

                        break;
                    default:
                        break;
                }
            }
        }
        return new List<string>();
    }



    public void ExportLoadAssetConfig(CommonPlayableAsset commonPlayableAsset)
    {

    }

    public void ConvertToCommonClipPlayable(Playable playable)
    {

    }
}

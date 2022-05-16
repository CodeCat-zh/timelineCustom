using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ExportABName : Attribute
{
    private string assetBundleName;
    private string assetName;
    
    public ExportABName(string assetBundleName,string assetName)
    {
        this.assetBundleName = assetBundleName;
        this.assetName = assetName;
    }

    public string GetAssetBundleName()
    {
        return this.assetBundleName;
    }

    public string GetAssetName()
    {
        return this.assetName;
    }
}

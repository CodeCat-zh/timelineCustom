using System;

namespace Polaris.CutsceneEditor
{
    [AttributeUsage(AttributeTargets.All)]
    public sealed class CutsceneExportAssetAttribute:Attribute
    {
        public CutsceneExportAssetType Type
        {
            get { return _type; }
        }

        private CutsceneExportAssetType _type;
        
        public CutsceneExportAssetAttribute(CutsceneExportAssetType _type)
        {
            this._type = _type;
        } 
    }

    public enum CutsceneExportAssetType
    {
        Json = 1,
        GameObject = 2,
        String = 3,
        Material = 4,
        AnimationClip = 5,
        RuntimeAnimatorController = 6,
    }
}
using System;

namespace Polaris.CutsceneEditor
{
    [AttributeUsage(AttributeTargets.All)]
    public sealed class CutsceneExportTrackAttribute:Attribute
    {
        private string propertyName;
        
        public CutsceneExportTrackAttribute(string propertyName)
        {
            this.propertyName = propertyName;
        } 
    }
}
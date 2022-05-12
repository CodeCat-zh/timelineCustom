
using System;

namespace Polaris.CutsceneEditor
{
    [AttributeUsage(AttributeTargets.All)]
    public sealed class CutscenePlayableSelectTypeAttribute : Attribute
    {
        private readonly int _category;
        private readonly int _clipType;
        private readonly string _clipName;
        private readonly int _order;

        public int Category
        {
            get { return _category; }
        }

        public int ClipType
        {
            get { return _clipType; }
        }

        public string ClipName
        {
            get { return _clipName; }
        }

        public int Order => _order;

        public CutscenePlayableSelectTypeAttribute(int category,int clipType, string clipName,int order = 0)
        {
            _category = category;
            _clipType = clipType;
            _clipName = clipName;
            _order = order;
        }
    }
}

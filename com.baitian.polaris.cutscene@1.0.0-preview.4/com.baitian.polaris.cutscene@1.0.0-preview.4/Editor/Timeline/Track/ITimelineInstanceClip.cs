using UnityEngine.Timeline;

namespace Polaris.CutsceneEditor
{
    public interface ITimelineInstanceClip
    {
        TimelineClip instanceClip { set; get; }
    }
}
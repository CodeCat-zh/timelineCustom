
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Cutscene
{
    public class CommonPlayableAsset : PlayableAsset, ITimelineClipAsset
    {
        public string type;

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            return Playable.Create(graph);
        }

        public ClipCaps clipCaps
        {
            get { return ClipCaps.None; }
        }
    }
}

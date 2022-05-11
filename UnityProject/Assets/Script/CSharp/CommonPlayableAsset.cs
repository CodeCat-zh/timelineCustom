
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Cutscene
{
    public class CommonPlayableAsset : PlayableAsset, ITimelineClipAsset
    {
        public int type;
        public int id;
        public List<string> parameters;


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

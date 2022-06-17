using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Polaris.CutsceneEditor
{
    public class CutsceneTrackAssetBase:TrackAsset
    {
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            foreach (var clip in GetClips())
            {
                var playableAsset = clip.asset as ITimelineInstanceClip;

                if (playableAsset!=null)
                {
                    playableAsset.instanceClip = clip;
                }
            }

            var scriptPlayable = ScriptPlayable<DefaultCutscenePlayableBehaviour>.Create(graph, inputCount);
            return scriptPlayable;
        }
        
        public class DefaultCutscenePlayableBehaviour : PlayableBehaviour
        {
        }
    }
}
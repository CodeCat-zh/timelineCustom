using System.ComponentModel;

using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

#if UNITY_EDITOR
using Polaris.ToLuaFrameworkEditor;
using UnityEditor;
#endif

namespace PJBN.Cutscene
{
#if UNITY_EDITOR
    [TrackColor(0.066f, 0.134f, 0.244f)]
    [TrackClipType(typeof(E_CutsceneRadialBlurKFramePlayableAsset))]
    [TimelineTrackConvert((int) CSharpRuntimeEditorCutsceneTrackType.DirectorRadialBlurTrackType,"Cutscene_RadialBlur")]
    public class E_CutsceneRadialBlurKFrameTrack : TrackAsset
    {
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            var director = go.GetComponent<PlayableDirector>();
            var trackTargetObject = director.GetGenericBinding(this) as GameObject;

            foreach (var clip in GetClips())
            {
                var playableAsset = clip.asset as E_CutsceneRadialBlurKFramePlayableAsset;

                if (playableAsset)
                {
                    playableAsset.OwningClip = clip;
                }
            }

            var scriptPlayable = ScriptPlayable<E_RadialBlurPlayableMixerBehavior>.Create(graph, inputCount);
            return scriptPlayable;
        }
    }
#else

#endif
    public class E_RadialBlurPlayableMixerBehavior : PlayableBehaviour
    {
        
    }
}
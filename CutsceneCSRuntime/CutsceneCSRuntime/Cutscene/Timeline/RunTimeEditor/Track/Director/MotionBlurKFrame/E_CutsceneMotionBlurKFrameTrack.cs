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
    [TrackClipType(typeof(E_CutsceneMotionBlurKFramePlayableAsset))]
    [TimelineTrackConvert((int) CSharpRuntimeEditorCutsceneTrackType.DirectorMotionBlurKFrameTrackType,"Cutscene_MotionBlur")]
    public class E_CutsceneMotionBlurKFrameTrack : TrackAsset
    {
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            var director = go.GetComponent<PlayableDirector>();
            var trackTargetObject = director.GetGenericBinding(this) as GameObject;

            foreach (var clip in GetClips())
            {
                var playableAsset = clip.asset as E_CutsceneMotionBlurKFramePlayableAsset;

                if (playableAsset)
                {
                    playableAsset.OwningClip = clip;
                }
            }

            var scriptPlayable = ScriptPlayable<E_MotionBlurKFramePlayableMixerBehavior>.Create(graph, inputCount);
            return scriptPlayable;
        }
    }
#else

#endif
    
    public class E_MotionBlurKFramePlayableMixerBehavior : PlayableBehaviour
    {
        
    }
}
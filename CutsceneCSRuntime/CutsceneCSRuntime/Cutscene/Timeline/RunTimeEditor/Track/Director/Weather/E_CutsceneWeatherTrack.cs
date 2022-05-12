using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

#if UNITY_EDITOR
using Polaris.ToLuaFrameworkEditor;
using UnityEditor;
using PJBNEditor.Cutscene;
#endif

namespace PJBN.Cutscene
{
#if UNITY_EDITOR
    [TrackColor(255f / 255, 80f / 255, 255f / 255)]
    [TrackClipType(typeof(E_CutsceneWeatherPlayableAsset))]
    [TimelineTrackConvert((int) CSharpRuntimeEditorCutsceneTrackType.DirectorWeatherTrackType,"CutsceneWeatherTrack")]
    public class E_CutsceneWeatherTrack : TrackAsset
    {
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            var director = go.GetComponent<PlayableDirector>();
            var trackTargetObject = director.GetGenericBinding(this) as GameObject;

            foreach (var clip in GetClips())
            {
                var playableAsset = clip.asset as E_CutsceneWeatherPlayableAsset;

                if (playableAsset)
                {
                    playableAsset.OwningClip = clip;
                }
            }

            var scriptPlayable = ScriptPlayable<E_CutsWeatherPlayableMixerBehavior>.Create(graph, inputCount);
            return scriptPlayable;
        }
    }
#else

#endif

    public class E_CutsWeatherPlayableMixerBehavior : PlayableBehaviour
    {
        
    }
}
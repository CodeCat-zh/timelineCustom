using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

#if UNITY_EDITOR
using Polaris.ToLuaFrameworkEditor;
#endif

namespace PJBN.Cutscene
{
#if UNITY_EDITOR
    [TrackColor(0.066f, 0.134f, 0.244f)]
    [TrackClipType(typeof(E_CutscenePostProcessTonemappingKFramePlayableAsset))]
    [TimelineTrackConvert((int) CSharpRuntimeEditorCutsceneTrackType.DirectorPostProcessTonemappingKFrameTrackType, "Cutscene_PostProcessBloom")]
    public class E_CutscenePostProcessTonemappingKFrameTrack : TrackAsset
    {
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            var director = go.GetComponent<PlayableDirector>();
            var trackTargetObject = director.GetGenericBinding(this) as GameObject;

            foreach (var clip in GetClips())
            {
                var playableAsset = clip.asset as E_CutscenePostProcessTonemappingKFramePlayableAsset;

                if (playableAsset)
                {
                    playableAsset.OwningClip = clip;
                }
            }

            var scriptPlayable = ScriptPlayable<E_CutscenePostProcessTonemappingKFramePlayableMixerBehavior>.Create(graph, inputCount);
            return scriptPlayable;
        }
    }
#endif

    public class E_CutscenePostProcessTonemappingKFramePlayableMixerBehavior : PlayableBehaviour
    {

    }
}

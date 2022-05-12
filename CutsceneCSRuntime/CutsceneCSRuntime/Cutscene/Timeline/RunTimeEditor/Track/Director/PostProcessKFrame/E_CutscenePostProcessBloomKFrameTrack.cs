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
    [TrackClipType(typeof(E_CutscenePostProcessBloomKFramePlayableAsset))]
    [TimelineTrackConvert((int) CSharpRuntimeEditorCutsceneTrackType.DirectorPostProcessBloomKFrameTrackType, "Cutscene_PostProcessBloom")]
    public class E_CutscenePostProcessBloomKFrameTrack : TrackAsset
    {
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            var director = go.GetComponent<PlayableDirector>();
            var trackTargetObject = director.GetGenericBinding(this) as GameObject;

            foreach (var clip in GetClips())
            {
                var playableAsset = clip.asset as E_CutscenePostProcessBloomKFramePlayableAsset;

                if (playableAsset)
                {
                    playableAsset.OwningClip = clip;
                }
            }

            var scriptPlayable = ScriptPlayable<E_CutscenePostProcessBloomKFramePlayableMixerBehavior>.Create(graph, inputCount);
            return scriptPlayable;
        }
    }
#endif

    public class E_CutscenePostProcessBloomKFramePlayableMixerBehavior : PlayableBehaviour
    {

    }
}

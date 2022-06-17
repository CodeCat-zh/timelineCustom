
using System.ComponentModel;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

#if UNITY_EDITOR
using Polaris.CutsceneEditor;
using Polaris.ToLuaFrameworkEditor;
#endif

namespace PJBN.Cutscene
{
#if UNITY_EDITOR
    [TrackColor(255f / 255, 80f / 255, 255f / 255)]
    [TrackClipType(typeof(E_CutsceneDarkScenePlayable), false)]
    [ExcludeFromPreset]
    [TimelineTrackConvert((int)CSharpRuntimeEditorCutsceneTrackType.DirectorDarkSceneTrackType, "CutsceneDarkSceneTrack")]
    public class E_CutsceneDarkSceneTrack : CutsceneTrackAssetBase
    {
        public override Playable CreateTrackMixer(PlayableGraph graph, GameObject go, int inputCount)
        {
            var director = go.GetComponent<PlayableDirector>();
            var trackTargetObject = director.GetGenericBinding(this) as GameObject;

            foreach (var clip in GetClips())
            {
                var playableAsset = clip.asset as E_CutsceneDarkScenePlayable;

                if (playableAsset)
                {
                    playableAsset.OwningClip = clip;
                }
            }

            var scriptPlayable = ScriptPlayable<E_CutsceneDarkScenePlayableMixerBehavior>.Create(graph, inputCount);
            return scriptPlayable;
        }
    }
#else
  
#endif

    public class E_CutsceneDarkScenePlayableMixerBehavior : PlayableBehaviour
    {

    }
}

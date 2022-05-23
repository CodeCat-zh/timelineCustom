
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Cutscene
{
    public class CommonPlayableAsset : PlayableAsset, ITimelineClipAsset
    {
        public string type;
        public int id;
        public List<string> paramList;
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
#if UNITY_EDTIOR
            paramList = GetParamList();
#endif
            return CreateCommonPlayAsset(graph,owner, type,paramList);
        }

        public static Playable CreateCommonPlayAsset(PlayableGraph graph,GameObject go,string type,List<string> paramList)
        {

            LuaFunctionCallBack behaviourPlayCallBack = null;
            LuaFunctionCallBack behaviourPauseCallBack = null;
            LuaFunctionCallBack prepareFrameCallBack = null;
            LuaFunctionCallBack processFrameCallBack = null;

            var serach = go.GetComponent<SerachTimelineLua>();

            if ( serach )
            {
                var binder = serach.GetBinderByType(type);

                behaviourPlayCallBack = binder.BehaviourPlayCallBack;
                behaviourPauseCallBack = binder.BehaviourPauseCallBack;
                prepareFrameCallBack = binder.PrepareFrameCallBack;
                processFrameCallBack = binder.ProcessFrameCallBack;
            }

            CommonPlayableBehaviour behaviourTemplate = new CommonPlayableBehaviour
            {
                behaviourPlayCallBack = behaviourPlayCallBack,
                behaviourPauseCallBack = behaviourPauseCallBack,
                prepareFrameCallBack = prepareFrameCallBack,
                processFrameCallBack = processFrameCallBack,
                type = type,
                id = IdCounter++,
                parmaList = paramList,

            };
            var playable = ScriptPlayable<CommonPlayableBehaviour>.Create(graph, behaviourTemplate);
            
            
            return playable;
        }

        public ClipCaps clipCaps
        {
            get { return ClipCaps.None; }
        }

        public static int IdCounter { get; private set ; }

        public virtual List<string> GetParamList()
        {
            return TimeLineUnities.ConvertFieldToString(this);
        }
    }
}

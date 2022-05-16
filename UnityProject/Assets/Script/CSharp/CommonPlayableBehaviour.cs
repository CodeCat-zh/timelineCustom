using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

namespace Cutscene
{
    public class CommonPlayableBehaviour : PlayableBehaviour
    {
        public LuaFunctionCallBack behaviourPlayCallBack;
        public LuaFunctionCallBack behaviourPauseCallBack;
        public LuaFunctionCallBack prepareFrameCallBack;
        public LuaFunctionCallBack processFrameCallBack;
        public List<string> parmaList;
        public int id;
        public string type;
        public override void OnBehaviourPlay(Playable playable, FrameData info)
        {
            if ( behaviourPlayCallBack != null )
            {
                int paramCount = 4 + parmaList.Count;
                object[] args = new object[paramCount];
                args[0] = type;
                args[1] = id;
                args[2] = playable;
                args[3] = info;
                for (int i = 0; i < parmaList.Count; i++)
                {
                    args[i + 4] = parmaList[i];
    
                }
                LuaFunctionCallBack.Invoke(behaviourPlayCallBack, args);
            }
        }


        public override void OnBehaviourPause(Playable playable, FrameData info)
        {
            if ( behaviourPauseCallBack != null )
            {
                object[] args = GetParamArray(playable, info);
                LuaFunctionCallBack.Invoke(behaviourPauseCallBack, args);
            }
        }

        public override void PrepareFrame(Playable playable, FrameData info)
        {
            if (prepareFrameCallBack != null)
            {
                object[] args = GetParamArray(playable, info);
                LuaFunctionCallBack.Invoke(prepareFrameCallBack, args);
            }
        }

        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            if (processFrameCallBack != null)
            {
                object[] args = GetParamArray(playable, info);
                LuaFunctionCallBack.Invoke(processFrameCallBack, args);
            }
        }

        private object[] GetParamArray(Playable playable,FrameData info)
        {
            object[] args = new object[2];
            args[0] = playable;
            args[1] = info;
            return args;
        }
    }
}
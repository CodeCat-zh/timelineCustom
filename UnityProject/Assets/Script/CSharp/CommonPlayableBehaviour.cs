using System;
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
                parmaList.Add(type);
                parmaList.Add(Convert.ToString(id));
                LuaFunctionCallBack.Invoke(behaviourPlayCallBack, playable,info,parmaList);
            }
        }

        public override void OnBehaviourPause(Playable playable, FrameData info)
        {
            if ( behaviourPauseCallBack != null )
            {
                LuaFunctionCallBack.Invoke(behaviourPauseCallBack, playable, info);
            }
        }
        public override void PrepareFrame(Playable playable, FrameData info)
        {
            if (prepareFrameCallBack != null)
            {
                LuaFunctionCallBack.Invoke(behaviourPauseCallBack, playable, info);
            }
        }

        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            if (processFrameCallBack != null)
            {
                LuaFunctionCallBack.Invoke(behaviourPauseCallBack, playable, info,playerData);
            }
        }
      
    }
}
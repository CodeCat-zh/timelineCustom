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
        [SerializeField]
        public List<string> parmaList;
        [SerializeField]
        public int id;
        [SerializeField]
        public string type;
        private bool isAdd = false;
        public override void OnBehaviourPlay(Playable playable, FrameData info)
        {
            if ( behaviourPlayCallBack != null )
            {
                if (!isAdd)
                {
                    parmaList.Add(type);
                    parmaList.Add(Convert.ToString(id));
                    isAdd = true;
                }
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
                LuaFunctionCallBack.Invoke(prepareFrameCallBack, playable, info);
            }
        }

        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {          
            if (processFrameCallBack != null)
            {
                LuaFunctionCallBack.Invoke(processFrameCallBack, playable, info,playerData);
            }
        }
      
    }
}
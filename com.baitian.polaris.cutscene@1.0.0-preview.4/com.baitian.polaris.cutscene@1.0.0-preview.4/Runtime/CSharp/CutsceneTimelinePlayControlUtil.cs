using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using System;

namespace Polaris.Cutscene
{
    public class CutsceneTimelinePlayControlUtil : MonoBehaviour
    {
        private PlayableDirector director = null;
        private double nextContinueStartPlayTime = 0;

        public void Start()
        {
            director = this.gameObject.GetComponent<PlayableDirector>();
        }

        public void OnPause(double nextContinuePlayTime)
        {
            if (!CheckHasDirector())
            {
                return;
            }
            SetNextContinueStartPlayTime(nextContinuePlayTime);
            if (director.playableGraph.IsValid())
            {
                director.playableGraph.GetRootPlayable(0).SetSpeed(0);
            }
        }

        public void SetNextContinueStartPlayTime(double nextContinuePlayTime)
        {
            nextContinueStartPlayTime = Math.Max(nextContinuePlayTime, nextContinueStartPlayTime);
        }

        public void OnContinue(bool startWithTimeSetWhenPause)
        {
            if (!CheckHasDirector())
            {
                return;
            }
            if (startWithTimeSetWhenPause)
            {
                director.time = nextContinueStartPlayTime;
            }
            if (director.playableGraph.IsValid())
            {
                director.playableGraph.GetRootPlayable(0).SetSpeed(1);
            }
        }

        public void ChangePlaySpeed(double speed)
        {
            if (!CheckHasDirector())
            {
                return;
            }
            if (director.playableGraph.IsValid())
            {
                director.playableGraph.GetRootPlayable(0).SetSpeed(speed);
            }
        }

        public double GetNowPlayableSpeed()
        {
            if (!CheckHasDirector())
            {
                return 1;
            }
            if (director.playableGraph.IsValid())
            {
                return director.playableGraph.GetRootPlayable(0).GetSpeed();
            }
            return 1;
        }

        public void RecoverNormalPlaySpeed()
        {
            if (!CheckHasDirector())
            {
                return;
            }
            if (director.playableGraph.IsValid())
            {
                director.playableGraph.GetRootPlayable(0).SetSpeed(1);
            }
        }

        bool CheckHasDirector()
        {
            if (director == null)
            {
                director = this.gameObject.GetComponent<PlayableDirector>();
            }
            if (director == null)
            {
                return false;
            }
            return true;
        }
    }
}

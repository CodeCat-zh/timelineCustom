using System;
using UnityEngine;
using System.Collections;

namespace PJBN.Cutscene
{
    public class UnityCurveContainer {

        public string propertyName = "";
        public AnimationCurve animCurve;
        public Type bindType;
        public string path;

        public UnityCurveContainer( string _propertyName,Type _bindType,string _path) {
            animCurve = new AnimationCurve ();
            propertyName = _propertyName;
            bindType = _bindType;
            path = _path;
        }

        public void AddValue( float animTime, float animValue,float targetNowAnimValue,float animationLength )
        {
            if (targetNowAnimValue == animValue)
            {
                //because targetGO is also controlled by animation,their animTime is same
                return;
            }

            if (animCurve.keys.Length == 0)
            {
                Keyframe originKey = new Keyframe (0, targetNowAnimValue, 0.0f, 0.0f);
                animCurve.AddKey (originKey);
                
                Keyframe endKey = new Keyframe (animationLength, targetNowAnimValue, 0.0f, 0.0f);
                animCurve.AddKey (endKey);
            }
            
            for(int i=0;i<animCurve.keys.Length;i++)
            {
                var key = animCurve.keys[i];
                if (key.time == animTime)
                {
                    animCurve.RemoveKey(i);
                    break;
                }
            }
            
            Keyframe targetKey = new Keyframe (animTime, animValue, 0.0f, 0.0f);
            animCurve.AddKey (targetKey);
        }

        public void Reset(Keyframe[] keyframes)
        {
            animCurve = new AnimationCurve ();
            foreach (var keyframe in keyframes)
            {
                animCurve.AddKey (keyframe); 
            }
        }
    }
}
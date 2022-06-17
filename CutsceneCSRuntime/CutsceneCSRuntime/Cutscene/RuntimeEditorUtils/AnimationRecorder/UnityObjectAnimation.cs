using UnityEngine;
using System.Collections;
using Cinemachine;

namespace PJBN.Cutscene
{
    public class UnityObjectAnimation {

        public UnityCurveContainer[] curves;
        public Transform observeTrans;
        public string pathName = "";
        public Transform targetTrans;
        public CinemachineVirtualCamera targetVcm;
        public CinemachineVirtualCamera observerVcm;
        public float animLength = 0;
        public UnityObjectAnimation( string hierarchyPath, Transform observeObj ,Transform targetTransform,float animLength) {
            pathName = hierarchyPath;
            observeTrans = observeObj;
            targetTrans = targetTransform;
            targetVcm = targetTrans.gameObject.GetComponent<CinemachineVirtualCamera>();
            observerVcm = observeTrans.gameObject.GetComponent<CinemachineVirtualCamera>();
            this.animLength = animLength;

            curves = new UnityCurveContainer[16];

            curves [0] = new UnityCurveContainer( "m_LocalPosition.x" ,typeof(Transform),"");
            curves [1] = new UnityCurveContainer( "m_LocalPosition.y" ,typeof(Transform),"");
            curves [2] = new UnityCurveContainer( "m_LocalPosition.z" ,typeof(Transform),"");

            curves [3] = new UnityCurveContainer( "m_LocalRotation.x" ,typeof(Transform),"");
            curves [4] = new UnityCurveContainer( "m_LocalRotation.y" ,typeof(Transform),"");
            curves [5] = new UnityCurveContainer( "m_LocalRotation.z" ,typeof(Transform),"");
            curves [6] = new UnityCurveContainer( "m_LocalRotation.w" ,typeof(Transform),"");


            curves [7] = new UnityCurveContainer( "m_LocalScale.x" ,typeof(Transform),"");
            curves [8] = new UnityCurveContainer( "m_LocalScale.y" ,typeof(Transform),"");
            curves [9] = new UnityCurveContainer( "m_LocalScale.z" ,typeof(Transform),"");

            curves[10] = new UnityCurveContainer("m_FollowOffset.x",typeof(CinemachineTransposer),"cm");
            curves[11] = new UnityCurveContainer("m_FollowOffset.y",typeof(CinemachineTransposer),"cm");
            curves[12] = new UnityCurveContainer("m_FollowOffset.z",typeof(CinemachineTransposer),"cm");

            curves[13] = new UnityCurveContainer("m_TrackedObjectOffset.x",typeof(CinemachineComposer),"cm");
            curves[14] = new UnityCurveContainer("m_TrackedObjectOffset.y",typeof(CinemachineComposer),"cm");
            curves[15] = new UnityCurveContainer("m_TrackedObjectOffset.z",typeof(CinemachineComposer),"cm");
        }

        public void AddFrame ( float time) {

            curves [0].AddValue (time, observeTrans.localPosition.x,targetTrans.localPosition.x,animLength);
            curves [1].AddValue (time, observeTrans.localPosition.y,targetTrans.localPosition.y,animLength);
            curves [2].AddValue (time, observeTrans.localPosition.z,targetTrans.localPosition.z,animLength);

            curves [3].AddValue (time, observeTrans.localRotation.x,targetTrans.localRotation.x,animLength);
            curves [4].AddValue (time, observeTrans.localRotation.y,targetTrans.localRotation.y,animLength);
            curves [5].AddValue (time, observeTrans.localRotation.z,targetTrans.localRotation.z,animLength);
            curves [6].AddValue (time, observeTrans.localRotation.w,targetTrans.localRotation.w,animLength);

            curves [7].AddValue (time, observeTrans.localScale.x,targetTrans.localScale.x,animLength);
            curves [8].AddValue (time, observeTrans.localScale.y,targetTrans.localScale.y,animLength);
            curves [9].AddValue (time, observeTrans.localScale.z,targetTrans.localScale.z,animLength);
            
            if (targetVcm != null && observerVcm!=null)
            {
                var targetFollowComp = targetVcm.GetCinemachineComponent<CinemachineTransposer>();
                var observerFollowComp = observerVcm.GetCinemachineComponent<CinemachineTransposer>();
                if (targetFollowComp != null && observerFollowComp!=null)
                {
                    curves[10].AddValue (time, observerFollowComp.m_FollowOffset.x,targetFollowComp.m_FollowOffset.x,animLength);
                    curves[11].AddValue (time, observerFollowComp.m_FollowOffset.y,targetFollowComp.m_FollowOffset.y,animLength);
                    curves[12].AddValue (time, observerFollowComp.m_FollowOffset.z,targetFollowComp.m_FollowOffset.z,animLength);
                }

                var targetComposerComp = targetVcm.GetCinemachineComponent<CinemachineComposer>();
                var observerComposerComp = observerVcm.GetCinemachineComponent<CinemachineComposer>();
                if (targetComposerComp != null && observerComposerComp != null)
                {
                    curves[13].AddValue (time, observerComposerComp.m_TrackedObjectOffset.x,targetComposerComp.m_TrackedObjectOffset.x,animLength);
                    curves[14].AddValue (time, observerComposerComp.m_TrackedObjectOffset.y,targetComposerComp.m_TrackedObjectOffset.y,animLength);
                    curves[15].AddValue (time, observerComposerComp.m_TrackedObjectOffset.z,targetComposerComp.m_TrackedObjectOffset.z,animLength); 
                }
            }
        }
    }
}
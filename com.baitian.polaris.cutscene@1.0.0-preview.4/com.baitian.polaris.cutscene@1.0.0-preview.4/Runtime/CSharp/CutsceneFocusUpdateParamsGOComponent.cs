using System;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif

namespace Polaris.Cutscene
{
    [ExecuteAlways]
    public  class CutsceneFocusUpdateParamsGOComponent : MonoBehaviour
	{
        public GameObject bindGO = null;
        public GameObject nowFocusingGO = null;
        public float focusingCameraFieldOfView = 0;

        private void Awake()
        {
            bindGO = this.gameObject;
        }

        void Update()
        {
            UpdateBindGO();
        }

        void UpdateBindGO()
        {
            if(nowFocusingGO == null)
            {
                return;
            }
            bindGO.transform.position = nowFocusingGO.transform.position;
            bindGO.transform.rotation = nowFocusingGO.transform.rotation;
            bindGO.transform.localScale = nowFocusingGO.transform.localScale;

            UpdateCameraFieldOfView();
        }

        void UpdateCameraFieldOfView()
        {
            if (nowFocusingGO == null)
            {
                return;
            }
            var camera = nowFocusingGO.GetComponent<Camera>();
            if(camera == null)
            {
                return;
            }
            focusingCameraFieldOfView = camera.fieldOfView;
        }


        public void SetNowFocusGO(GameObject focusGO)
        {
            nowFocusingGO = focusGO;
            UpdateBindGO();
        }

        public bool CheckIsFocusingThisGO(GameObject focusGO)
        {
            return focusGO == nowFocusingGO;
        }

        public float GetFocusingCameraFieldOfView()
        {
            return focusingCameraFieldOfView;
        }

    }
}

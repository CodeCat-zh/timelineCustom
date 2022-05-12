using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace PJBN.Cutscene
{
    public class CutsceneEditorEffectDrag : MonoBehaviour
    {
        public UnityAction<Vector3> onBeginDrag = null;
        public UnityAction<Vector3> onDrag = null;
        public UnityAction<Vector3> onEndDrag = null;

        bool isBegin = false;
        bool isDown = false;
        int instanceID = 0;

        Vector3 mousePosition = Vector3.zero;

        Toggle toggle;

        private void Awake()
        {
            instanceID = this.gameObject.GetInstanceID();
            toggle = this.gameObject.GetComponent<Toggle>();
        }

        void Update()
        {
            if (toggle == null || toggle.isOn == false)
            {
                return;
            }
            if (EventSystem.current.IsPointerOverGameObject())
            {
                if (Input.GetMouseButtonDown(0) && EventSystem.current.currentSelectedGameObject != null && instanceID == EventSystem.current.currentSelectedGameObject.GetInstanceID())
                {
                    isDown = true;
                    isBegin = false;
                }
            }
            if (isDown)
            {
                if (Input.GetMouseButtonUp(0))
                {
                    isBegin = false;
                    isDown = false;
                    if (onEndDrag != null)
                    {
                        if (mousePosition != Input.mousePosition)
                        {
                            mousePosition = Input.mousePosition;
                            onEndDrag.Invoke(mousePosition);
                        }
                    }
                    return;
                }
                if (!EventSystem.current.IsPointerOverGameObject())
                {
                    if (isBegin)
                    {
                        if (onDrag != null)
                        {
                            if (mousePosition != Input.mousePosition)
                            {
                                mousePosition = Input.mousePosition;
                                onDrag.Invoke(mousePosition);
                            }
                        }
                    }
                    else
                    {
                        isBegin = true;
                        if (onBeginDrag != null)
                        {
                            mousePosition = Input.mousePosition;
                            onBeginDrag.Invoke(mousePosition);
                        }
                    }


                }
            }

        }
    }
}
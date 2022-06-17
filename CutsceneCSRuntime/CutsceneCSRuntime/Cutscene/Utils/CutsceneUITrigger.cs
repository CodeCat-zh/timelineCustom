using UnityEngine;
using LuaInterface;
using UnityEngine.EventSystems;
using System;

namespace PJBN.Cutscene
{
    public class CutsceneUITrigger : MonoBehaviour, IPointerDownHandler, IPointerClickHandler, IPointerUpHandler, IDragHandler, IEndDragHandler, IBeginDragHandler
    {
        private float fLongPressInterval = 0.2f;
        private float fDoubleClickInterval = 0.2f;

        private float fLastClickTime = 0;
        private float fLongPressStart = 0;
        private bool isLongPress = false;
        private bool isTouchDown = false;
        private int iLongPressIndex = 0;
        private bool longPressOnce = true;
        private LuaFunction doubleClickCallback = null;
        private LuaFunction singleClickCallback = null;
        private LuaFunction longPressCallback = null;
        private LuaFunction longPressPointUpCallback = null;
        private LuaFunction beginDragCallback = null;
        private LuaFunction onDragCallback = null;
        private LuaFunction endDragCallback = null;


        public static CutsceneUITrigger Get(GameObject go)
        {
            CutsceneUITrigger trigger = go.GetComponent<CutsceneUITrigger>();
            if (null == trigger)
            {
                trigger = go.AddComponent<CutsceneUITrigger>();
            }
            return trigger;
        }

        public void SetLongPressInterval(float value, bool once = true)
        {
            fLongPressInterval = value;
            longPressOnce = once;
        }

        public void RemoveAllListener()
        {
            singleClickCallback = null;
            doubleClickCallback = null;
            longPressCallback = null;
        }

        public void AddClickListener(LuaFunction click)
        {
            singleClickCallback = click;
        }

        public void AddDoubleClickListener(LuaFunction click)
        {
            doubleClickCallback = click;
        }

        public void AddLongPressListener(LuaFunction click, LuaFunction pointUp)
        {
            longPressCallback = click;
            longPressPointUpCallback = pointUp;
        }

        public void AddBeginDragListener(LuaFunction click)
        {
            beginDragCallback = click;
        }

        public void AddOnDragListener(LuaFunction click)
        {
            onDragCallback = click;
        }

        public void AddEndDragListener(LuaFunction click)
        {
            endDragCallback = click;
        }

        public void OnPointerClick(PointerEventData eventData)
        {
            if (isLongPress || Input.touchCount > 1) return;

            if (singleClickCallback == null && doubleClickCallback == null) return;

            if (Time.time - fLastClickTime < fDoubleClickInterval)
            {
                if (doubleClickCallback != null)
                {
                    doubleClickCallback.Call();
                }
            }
            else
            {
                if (singleClickCallback != null)
                {
                    singleClickCallback.Call();
                }
                fLastClickTime = Time.time;
            }
        }

        public void OnPointerDown(PointerEventData eventData)
        {
            
            if (longPressCallback == null || Input.touchCount > 1) return;
            isLongPress = false;
            fLongPressStart = Time.time;
            iLongPressIndex = 1;
            isTouchDown = true;
        }

        public void OnPointerUp(PointerEventData eventData)
        {
            
            isTouchDown = false;

            if (longPressCallback == null || !isLongPress || Input.touchCount > 1) return;

            if (longPressPointUpCallback != null)
            {
                longPressPointUpCallback.Call(eventData);
            }
        }

        private void Update()
        {
            if (longPressCallback == null) return;

            if (!isTouchDown) return;

            CheckLongPress();
        }

        private void CheckLongPress()
        {
            if (Time.time - fLongPressStart >= fLongPressInterval)
            {
                fLongPressStart = Time.time;
                isLongPress = true;
                if (longPressCallback != null)
                {
                    if (!longPressOnce || iLongPressIndex == 1)
                    {
                        longPressCallback.Call(iLongPressIndex);
                    }
                }
                iLongPressIndex++;
            }
        }

        public void OnEndDrag(PointerEventData eventData)
        {
            if (endDragCallback != null)
            {
                endDragCallback.Call();
            }
        }

        public void OnDrag(PointerEventData eventData)
        {
            if (onDragCallback != null)
            {
                onDragCallback.Call();
            }
        }

        public void OnBeginDrag(PointerEventData eventData)
        {
            if (beginDragCallback != null)
            {
                beginDragCallback.Call();
            }
        }
    }
}
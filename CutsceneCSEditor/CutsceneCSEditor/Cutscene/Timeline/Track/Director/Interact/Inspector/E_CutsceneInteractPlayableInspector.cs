using PJBN.Cutscene;
using System;
using UnityEditor;
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsceneInteractPlayableAsset))]
    public class E_CutsceneInteractPlayableInspector : Editor
    {
        private E_CutsceneInteractPlayableAsset playableAsset;

        private Vector2 clickPos = Vector2.zero;
        public int clickCount = 1;


        private Button test_button;

        private void OnEnable()
        {
            playableAsset = target as E_CutsceneInteractPlayableAsset;

            clickPos = playableAsset.clickPos;
            clickCount = playableAsset.clickCount;

            if (test_button != null)
            {
                Destroy(test_button.gameObject);
            }
        }

        private void OnDisable()
        {
            if (test_button != null)
            {
                Destroy(test_button.gameObject);
            }
        }

        public override void OnInspectorGUI()
        {
            EditorGUILayout.Space();
            clickPos = EditorGUILayout.Vector2Field("位置:", clickPos);
            playableAsset.clickPos = clickPos;

            EditorGUILayout.Space();
            clickCount = EditorGUILayout.IntField("点击次数:", clickCount);
            if (clickCount < 1)
            {
                clickCount = 1;
            }
            playableAsset.clickCount = clickCount;


            this.serializedObject.ApplyModifiedProperties();



            EditorGUILayout.Space();
            EditorGUILayout.Space();
            EditorGUILayout.Space();

            if (EditorApplication.isPlaying)
            {

                if (test_button == null)
                {
                    if (GUILayout.Button("采集坐标"))
                    {
                        GameObject POPUP = GameObject.Find("POPUP");
                        GameObject UICamera = GameObject.Find("UICamera");
                        if (POPUP != null && UICamera != null && test_button == null)
                        {
                            GameObject go = new GameObject("image");
                            Image image = go.AddComponent<Image>();
                            go.transform.SetParent(POPUP.transform);
                            go.transform.localScale = Vector3.one;
                            go.transform.localEulerAngles = Vector3.zero;
                            go.transform.localPosition = Vector3.zero;
                            RectTransform rect = go.GetComponent<RectTransform>();
                            rect.sizeDelta = new Vector2(1280 * 2, 720 * 2);
                            image.color = new Color(1, 1, 1, 0.3f);
                            test_button = go.AddComponent<Button>();
                            test_button.onClick.AddListener(() => {
                                Vector2 vector2 = Vector2.one;
                                if (RectTransformUtility.ScreenPointToLocalPointInRectangle(POPUP.GetComponent<RectTransform>(), Input.mousePosition, UICamera.GetComponent<Camera>(), out vector2))
                                {
                                    clickPos = vector2;
                                    playableAsset.clickPos = clickPos;
                                    Debug.Log(vector2);
                                }
                                if (test_button != null)
                                {
                                    Destroy(test_button.gameObject);
                                }
                            });
                        }
                    }
                }
                else
                {
                    GUILayout.Label("点击屏幕任意位置", "");
                    EditorGUILayout.Space();
                    EditorGUILayout.Space();
                    if (GUILayout.Button("不想采集坐标了"))
                    {
                        if (test_button != null)
                        {
                            Destroy(test_button.gameObject);
                        }
                    }
                }
            }


        }


 

    }
}
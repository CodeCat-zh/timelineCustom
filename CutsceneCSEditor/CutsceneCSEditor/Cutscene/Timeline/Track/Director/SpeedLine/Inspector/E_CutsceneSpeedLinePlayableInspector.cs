using PJBN.Cutscene;
using System;
using UnityEditor;
using UnityEditor.Timeline;
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsceneSpeedLinePlayableAsset))]
    public class E_CutsceneSpeedLinePlayableInspector : Editor
    {
        private E_CutsceneSpeedLinePlayableAsset playableAsset;

        private float timeSpace = 0.1f;
        private Vector2 centre = Vector2.zero;

        private int minSpace = 200;
        private int maxSpace = 800;

        private Color lineColor = Color.white;

        private bool lineClose = true;

        private Button test_button;

        private void OnEnable()
        {
            playableAsset = target as E_CutsceneSpeedLinePlayableAsset;

            timeSpace = playableAsset.timeSpace;
            centre = playableAsset.centre;

            minSpace = playableAsset.minSpace;
            maxSpace = playableAsset.maxSpace;

            lineColor = playableAsset.lineColor;
            lineClose = playableAsset.lineClose;

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

            timeSpace = EditorGUILayout.FloatField("闪动间隔(s):", timeSpace);
            if (timeSpace < 0.02f)
            {
                timeSpace = 0.02f;
            }
            else if (timeSpace > 0.2f)
            {
                timeSpace = 0.2f;
            }
            playableAsset.timeSpace = timeSpace;

            EditorGUILayout.Space();
            EditorGUILayout.Space();

            centre = EditorGUILayout.Vector2Field("焦点位置:", centre);
            playableAsset.centre = centre;

            EditorGUILayout.Space();
            EditorGUILayout.Space();

            EditorGUILayout.BeginHorizontal();
            GUILayout.Label("速度线距焦点最小距离:");
            minSpace = EditorGUILayout.IntField(minSpace);
            playableAsset.minSpace = minSpace;
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();
            GUILayout.Label("速度线距焦点最大距离:");
            maxSpace = EditorGUILayout.IntField(maxSpace);
            playableAsset.maxSpace = maxSpace;
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.BeginHorizontal();
            GUILayout.Label("速度线的颜色、透明度:");
            lineColor = EditorGUILayout.ColorField(lineColor);
            playableAsset.lineColor = lineColor;
            EditorGUILayout.EndHorizontal();



            EditorGUILayout.BeginHorizontal();
            GUILayout.Label("片段结束后关闭速度线:");
            lineClose = EditorGUILayout.Toggle(lineClose);
            playableAsset.lineClose = lineClose;
            EditorGUILayout.EndHorizontal();

            //this.serializedObject.ApplyModifiedProperties();
            TimelineEditor.Refresh(RefreshReason.ContentsModified);

            EditorGUILayout.Space();
            EditorGUILayout.Space();
            EditorGUILayout.Space();
            EditorGUILayout.Space();

            if (Application.isPlaying)
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
                                    centre = vector2;
                                    playableAsset.centre = centre;
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
                    GUILayout.Label("点击屏幕任意位置","");
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
using LitJson;
using PJBN.Cutscene;
using Polaris.CutsceneEditor;
using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.Timeline;

namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsceneEffectPlayableAsset))]
    public class E_CutsceneEffectPlayableInspector : Editor
    {
        public class EffectParamDataCls
        {
            public string effect_assetInfo = "";
        }

        private E_CutsceneEffectPlayableAsset playableAsset = null;

        public string assetName = "";
        public string assetBundleName = "";
        private Vector3 position = Vector3.zero;
        private Vector3 rotation = Vector3.zero;
        private float scale = 1;

        private float startTime;
        private float durationTime;


        private Vector3 cameraPos = Vector3.zero;
        CutsceneEditorEffectView editorView;
        TimelineClip timelineClip;

        private void OnEnable()
        {
            playableAsset = target as E_CutsceneEffectPlayableAsset;
            if (playableAsset == null)
            {
                return;
            }

            timelineClip = playableAsset.instanceClip;

            assetName = playableAsset.assetName;
            assetBundleName = playableAsset.assetBundleName;
            position = playableAsset.position;
            rotation = playableAsset.rotation;
            scale = playableAsset.scale;

            editorView = GetEditorView();
            RefreshEditorView();

            EffectEnable();
        }
        private void OnDisable()
        {
            
        }

        public void UpdateInfo1(Vector3 _pos, Vector3 _rot, float _scale)
        {
            position = _pos;
            rotation = _rot;
            scale = _scale;

            E_CutsceneEffectPlayableAsset playableAsset = timelineClip.asset as E_CutsceneEffectPlayableAsset;
            playableAsset.position = position;
            playableAsset.rotation = rotation;
            playableAsset.scale = scale;

            Repaint();
        }

        public void UpdateInfo2(string _assetName, string _assetBundleName, float _startTime, float _durationTime)
        {
            assetName = _assetName;
            assetBundleName = _assetBundleName;

            E_CutsceneEffectPlayableAsset playableAsset = timelineClip.asset as E_CutsceneEffectPlayableAsset;
            playableAsset.instanceClip.start = _startTime;
            playableAsset.instanceClip.duration = _durationTime;
            playableAsset.assetName = assetName;
            playableAsset.assetBundleName = assetBundleName;

            Repaint();
        }


        public override void OnInspectorGUI()
        {
            
            EditorGUILayout.Space();
            assetName = EditorGUILayout.TextField("assetName:", assetName);
            this.serializedObject.FindProperty("assetName").stringValue = assetName;

            EditorGUILayout.Space();
            assetBundleName = EditorGUILayout.TextField("assetBundleName:", assetBundleName);
            this.serializedObject.FindProperty("assetBundleName").stringValue = assetBundleName;

            EditorGUILayout.Space();
            position = EditorGUILayout.Vector3Field("位置:", position);
            this.serializedObject.FindProperty("position").vector3Value = position;

            EditorGUILayout.Space();
            rotation = EditorGUILayout.Vector3Field("角度:", rotation);
            this.serializedObject.FindProperty("rotation").vector3Value = rotation;

            EditorGUILayout.Space();
            scale = EditorGUILayout.FloatField("缩放:", scale);
            this.serializedObject.FindProperty("scale").floatValue = scale;

            this.serializedObject.ApplyModifiedProperties();


            EditorGUILayout.Space();
            EditorGUILayout.Space();
            EditorGUILayout.Space();

            if (EditorApplication.isPlaying == true)
            {
                if (editorView == null)
                {
                    if (GUILayout.Button("打开编辑界面"))
                    {
                        GameObject root = GameObject.Find("Root/UI/UIROOT/TOP");
                        if (root != null)
                        {
                            Transform oldView = root.transform.Find("CutsceneEditorEffectView");
                            if (oldView != null)
                                GameObject.Destroy(oldView.gameObject);

                            //GameObject obj = EditorGUIUtility.Load("Prefabs/CutsceneEditorEffectView.prefab") as GameObject;
                            GameObject obj = AssetDatabase.LoadAssetAtPath<GameObject>(@"Assets\GameAssets\Shared\Prefabs\Function\Cutscene\UI\Editor\EffectClip\CutsceneEditorEffectView.prefab");
                            GameObject go = Instantiate(obj);
                            go.transform.SetParent(root.transform);
                            go.name = "CutsceneEditorEffectView";
                            go.transform.localScale = Vector3.one;
                            go.transform.localPosition = Vector3.zero;
                            go.transform.localRotation = Quaternion.identity;
                            
                            editorView = go.GetComponent<CutsceneEditorEffectView>();
                            RefreshEditorView();

                        }

                    }
                }
                else
                {
                    if (GUILayout.Button("关闭编辑界面"))
                    {
                        GameObject.DestroyImmediate(editorView.gameObject);
                        editorView = null;
                    }
                    if (editorView != null && editorView.freedomCamera != null)
                    {
                        if (cameraPos != editorView.freedomCamera.centerPoint)
                        {
                            cameraPos = editorView.freedomCamera.centerPoint;
                        }
                        cameraPos = EditorGUILayout.Vector3Field("预览相机看向的坐标:", cameraPos);
                        editorView.freedomCamera.centerPoint = cameraPos;
                    }

                    EditorGUILayout.Space();
                    if (GUILayout.Button("选中创建的特效"))
                    {
                        editorView.SelectEffect();
                    }
                }
            }
            else
            {
                UpdateEffectShow();
            }
            UpdateEffectJson();
        }
        private EffectParamDataCls _effectParamDataCls = new EffectParamDataCls();
        void UpdateEffectJson()
        {
            if (assetBundleName != "" && assetName != "")
            {
                _effectParamDataCls.effect_assetInfo = $"{assetBundleName},{assetName}";
                string paramsStr = JsonMapper.ToJson(_effectParamDataCls);
                this.serializedObject.FindProperty("typeParamsStr").stringValue = paramsStr;
            }
        }

        CutsceneEditorEffectView GetEditorView()
        {
            CutsceneEditorEffectView cutsceneEditorEffectView = null;
            GameObject root = GameObject.Find("Root/UI/UIROOT/TOP");
            if (root != null)
            {
                Transform oldView = root.transform.Find("CutsceneEditorEffectView");
                if (oldView != null)
                {
                    cutsceneEditorEffectView = oldView.GetComponent<CutsceneEditorEffectView>();
                }
            }
            return cutsceneEditorEffectView;
        }

        void RefreshEditorView()
        {
            if (editorView != null)
            {
                editorView.timelineClip = timelineClip;
                editorView.updateAction1 = UpdateInfo1;
                editorView.updateAction2 = UpdateInfo2;

                startTime = (float)timelineClip.start;
                durationTime = (float)timelineClip.duration;
                editorView.InitValue(assetName, assetBundleName, startTime, durationTime, position, rotation, scale);
                editorView.SetViewName(timelineClip.displayName);
            }
        }



        private OptimizeScrollView effectEffectScrollView;
        List<string> effectList;
        string[] effect_assetNames;
        string[] effect_bundleNames;
        private void EffectEnable()
        {
            effectList = PolarisCutsceneEditorUtils.GetEffectInfoList();

            effect_assetNames = new string[effectList.Count];
            effect_bundleNames = new string[effectList.Count];
            for (int i = 0; i < effectList.Count; i++)
            {
                var infos = effectList[i].Split(',');
                effect_bundleNames[i] = infos[0];
                effect_assetNames[i] = infos[1];
            }

            effectEffectScrollView = new OptimizeScrollView(20, 200, 1, 1);
            effectEffectScrollView.SetDrawCellFunc(DrawEffectButtonCell);

        }
        void DrawEffectButtonCell(Rect cellRect, int index)
        {
            GUILayout.BeginArea(cellRect);
            if (GUILayout.Button(effect_assetNames[index]))
            {
                if (index < effect_assetNames.Length)
                {
                    assetName = effect_assetNames[index];
                    this.serializedObject.FindProperty("assetName").stringValue = assetName;
                    assetBundleName = effect_bundleNames[index];
                    this.serializedObject.FindProperty("assetBundleName").stringValue = assetBundleName;
                }
            }
            GUILayout.EndArea();
        }

        void UpdateEffectShow()
        {
            if (effectList == null || effectEffectScrollView == null)
            {
                return;
            }


            EditorGUILayout.LabelField("特效列表:");
            Rect effectAreaRect = EditorGUILayout.GetControlRect(GUILayout.Width(220), GUILayout.Height(100));
            if (effectList.Count > 0)
            {
                effectEffectScrollView.SetRowCount(effectList.Count);
                Rect rect = new Rect(effectAreaRect.x, effectAreaRect.y, 220, 100);
                effectEffectScrollView.Draw(rect);
            }
        }
    }
}
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using LitJson;

namespace Polaris.CutsceneEditor
{
    public class E_CutsceneCameraPlayableMoveTypeInspector :CutsceneInspectorExtBase,IMultiTypeInspector
    {
        public bool bIsStartFade = false;
        public Color clrStart = new Color(1,1,1,1);
        public bool bIsEndFade = false;
        public Color clrEnd = new Color(1, 1, 1, 1);
        public bool autoRotation = false;
        public List<MoveTypeNodeListInfo> moveTypeNodeInfo = new List<MoveTypeNodeListInfo>();

        private bool moveTypehasInitParams = false;

        private MoveTypeParamsDataCls moveTypeParamsDataCls = new MoveTypeParamsDataCls();

        private int nowPreviewNodeIndex = 0;
        private MoveTypeNodeListInfo nowPreviewNodeInfo = new MoveTypeNodeListInfo();

        public bool needInspectorExitEditMode = false;

        public class MoveTypeNodeListInfo
        {
            public Vector3 posNode = new Vector3(0, 0, 0);
            public Quaternion rotNode = new Quaternion(0, 0, 0, 0);
        }

        public class MoveTypeNodeListDataInfo
        {
            public string posNode = "";
            public string rotNode = "";
        }

        public class MoveTypeParamsDataCls
        {
            public bool bIsStartFade = false;
            public string clrStart = "";
            public bool bIsEndFade = false;
            public string clrEnd = "";
            public bool autoRotation = false;
            public List<MoveTypeNodeListDataInfo> moveTypeNodeInfo = new List<MoveTypeNodeListDataInfo>();
        }

        public E_CutsceneCameraPlayableMoveTypeInspector(SerializedObject serializedObject):base(serializedObject)
        {
            
        }
        
        public void GenerateTypeParamsGUI()
        {
            InitMoveTypeParams();
            bIsStartFade = EditorGUILayout.Toggle("开始渐隐：", bIsStartFade);
            clrStart = EditorGUILayout.ColorField("渐隐颜色：", clrStart);
            bIsEndFade = EditorGUILayout.Toggle("结束渐隐：", bIsEndFade);
            clrEnd = EditorGUILayout.ColorField("消隐颜色：", clrEnd);
            autoRotation = EditorGUILayout.Toggle("自动视角：", autoRotation);
            EditorGUILayout.LabelField("输出路径（路径点为绝对坐标）：");
            CheckNodeListAtLeastHasTwo();
            for(int i = 0;i<moveTypeNodeInfo.Count;i++)
            {
                MoveTypeDrawNodeInfoParamsGUI(moveTypeNodeInfo[i],i);
            }
            CloseupCheckUpdatePreviewNode();
            UpdateMoveTypeParamsStr();
            CheckInspectorExitEditMode();
        }

        void InitMoveTypeParams()
        {
            if (!moveTypehasInitParams)
            {
                ParseMoveTypeParamsStr();
                nowPreviewNodeIndex = 0;
                if(moveTypeNodeInfo.Count > 0)
                {
                    SetNowPreviewPosNodeInfo(moveTypeNodeInfo[0]);
                }
                moveTypehasInitParams = true;
            }
        }

        void MoveTypeDrawNodeInfoParamsGUI(MoveTypeNodeListInfo info,int index)
        {
            info.posNode = EditorGUILayout.Vector3Field(string.Format("路径点{0}:",index), info.posNode);
            Vector3 newRot = EditorGUILayout.Vector3Field(string.Format("路径点朝向{0}:", index), info.rotNode.eulerAngles);
            info.rotNode = Quaternion.Euler(newRot);
            EditorGUILayout.BeginHorizontal();
            if (GUILayout.Button("添加"))
            {
                AddNodeListInfo(index + 1);
            }

            if (GUILayout.Button("删除"))
            {
                DeleteNodeListInfo(index);
            }
            if (GUILayout.Button("应用当前镜头位置信息到timeline"))
            {
                var camera = PolarisCutsceneEditorUtils.FindCutsceneCamera();
                if (camera != null)
                {
                    var cameraObject = camera.gameObject;
                    var go = PolarisCutsceneEditorUtils.GetFocusUpdateParamsGO(cameraObject);
                    info.posNode = go.transform.position;
                    info.rotNode = go.transform.rotation;
                }
                SetNeedInspectorExitEditMode(true);
            }
            if (GUILayout.Button("设置为路径点为预览路径点"))
            {
                if(index != nowPreviewNodeIndex)
                {
                    nowPreviewNodeIndex = index;
                    SetNowPreviewPosNodeInfo(info);
                    CloseUpPreviewCameraModifyPos();
                }
            }
            EditorGUILayout.EndHorizontal();
        }

        void UpdateMoveTypeParamsStr()
        {
            moveTypeParamsDataCls.bIsStartFade = bIsStartFade;
            moveTypeParamsDataCls.clrStart = PolarisCutsceneEditorUtils.TransFormColorToColorStr(clrStart);
            moveTypeParamsDataCls.bIsEndFade = bIsEndFade;
            moveTypeParamsDataCls.clrEnd = PolarisCutsceneEditorUtils.TransFormColorToColorStr(clrEnd);
            moveTypeParamsDataCls.autoRotation = autoRotation;
            moveTypeParamsDataCls.moveTypeNodeInfo = ChangeMoveTypeNodeInfoToDataInfo();

            string paramsStr = JsonMapper.ToJson(moveTypeParamsDataCls);
            this.serializedObject.FindProperty("typeParamsStr").stringValue = paramsStr;
        }
        
        

        void ParseMoveTypeParamsStr()
        {
            string paramsStr = this.serializedObject.FindProperty("typeParamsStr").stringValue;
            if(!paramsStr.Equals("") && paramsStr != null)
            {
                MoveTypeParamsDataCls data = JsonMapper.ToObject<MoveTypeParamsDataCls>(paramsStr);
                bIsStartFade = data.bIsStartFade;
                clrStart = PolarisCutsceneEditorUtils.TransFormColorStrToColor(data.clrStart);
                bIsEndFade = data.bIsEndFade;
                clrEnd = PolarisCutsceneEditorUtils.TransFormColorStrToColor(data.clrEnd);
                autoRotation = data.autoRotation;
                moveTypeNodeInfo = ChangeMoveTypeNodeDataInfoToInfo(data.moveTypeNodeInfo);
             }
        }

        void CheckNodeListAtLeastHasTwo()
        {
            if(moveTypeNodeInfo.Count < 2)
            {
                for(int i=0;i< 2 - moveTypeNodeInfo.Count; i++)
                {
                    AddNodeListInfo();
                }
            }
        }

        void AddNodeListInfo(int insertIndex = -1)
        {
            var info = new MoveTypeNodeListInfo();
            var camera = UnityEngine.Camera.main;
            var cameraPos = camera.gameObject.transform.position;
            info.posNode = cameraPos;
            info.rotNode = Quaternion.Euler(new Vector3(0, 0, 0));
            if(insertIndex < 0)
            {
                moveTypeNodeInfo.Add(info);
            }
            else
            {
                moveTypeNodeInfo.Insert(insertIndex, info);
            }
        }

        void DeleteNodeListInfo(int deleteIndex)
        {
            moveTypeNodeInfo.RemoveAt(deleteIndex);
        }

        List<MoveTypeNodeListDataInfo> ChangeMoveTypeNodeInfoToDataInfo()
        {
            List<MoveTypeNodeListDataInfo> dataInfoList = new List<MoveTypeNodeListDataInfo>();
            foreach (var info in moveTypeNodeInfo)
            {
                var newInfo = new MoveTypeNodeListDataInfo();
                newInfo.posNode = PolarisCutsceneEditorUtils.TransFormVector3ToVector3Str(info.posNode);
                newInfo.rotNode = PolarisCutsceneEditorUtils.TransFormVector3ToVector3Str(info.rotNode.eulerAngles);
                dataInfoList.Add(newInfo);
            }
            return dataInfoList;
        }

        List<MoveTypeNodeListInfo> ChangeMoveTypeNodeDataInfoToInfo(List<MoveTypeNodeListDataInfo> dataInfoList)
        {
            List<MoveTypeNodeListInfo> infoList = new List<MoveTypeNodeListInfo>();
            foreach (var info in dataInfoList)
            {
                var newInfo = new MoveTypeNodeListInfo();
                newInfo.posNode = PolarisCutsceneEditorUtils.TransFormVec3StrToVec3(info.posNode);
                newInfo.rotNode = Quaternion.Euler(PolarisCutsceneEditorUtils.TransFormVec3StrToVec3(info.rotNode));
                infoList.Add(newInfo);
            }
            return infoList;
        }

        void CloseupCheckUpdatePreviewNode()
        {
            if(moveTypeNodeInfo.Count > 0)
            {
                nowPreviewNodeIndex = nowPreviewNodeIndex > moveTypeNodeInfo.Count - 1 ? moveTypeNodeInfo.Count - 1 : nowPreviewNodeIndex;
                var newNowPreviewNodeInfo = moveTypeNodeInfo[nowPreviewNodeIndex];
                if(nowPreviewNodeInfo!=null && newNowPreviewNodeInfo != null)
                {
                    var posIsEqual = newNowPreviewNodeInfo.posNode.ToString().Equals(nowPreviewNodeInfo.posNode.ToString());
                    var rotIsEqual = newNowPreviewNodeInfo.rotNode.ToString().Equals(nowPreviewNodeInfo.rotNode.ToString());
                    if (!(posIsEqual && rotIsEqual))
                    {
                        SetNowPreviewPosNodeInfo(newNowPreviewNodeInfo);
                        CloseUpPreviewCameraModifyPos();
                    }
                }
            }
            EditorGUILayout.LabelField("当前预览路径点为路径点："+ nowPreviewNodeIndex,PolarisCutsceneEditorConst.GetRedFontStyle());
        }

        void CloseUpPreviewCameraModifyPos()
        {
            if (nowPreviewNodeInfo != null)
            {
                var script = serializedObject.targetObject as E_CutsceneCameraPlayableAsset;
                var clip = script.instanceClip;
                if (clip != null && moveTypeNodeInfo.Count!=0)
                {
                    var time = clip.start + clip.duration * nowPreviewNodeIndex / moveTypeNodeInfo.Count;
                    LocalCutsceneLuaExecutorProxy.PreviewTimelineCurTime(time);
                }
            }
        }

        void SetNowPreviewPosNodeInfo(MoveTypeNodeListInfo info)
        {
            if (nowPreviewNodeInfo == null)
            {
                nowPreviewNodeInfo = new MoveTypeNodeListInfo();
            }
            nowPreviewNodeInfo.posNode = info.posNode;
            nowPreviewNodeInfo.rotNode = info.rotNode;
        }

        public void CheckInspectorExitEditMode()
        {
            if (needInspectorExitEditMode)
            {
                this.serializedObject.ApplyModifiedProperties();
                PolarisCutsceneEditorUtils.InspectorExitEditMode();
                needInspectorExitEditMode = false;
            }
        }

        public void SetNeedInspectorExitEditMode(bool value)
        {
            needInspectorExitEditMode = value;
        }

    }
}
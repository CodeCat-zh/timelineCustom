using System;
using System.Text;
using UnityEditor;
using UnityEngine;
using PJBN;
using Polaris.CutsceneEditor;

namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsceneActorFollowPlayableAsset))]
    public class E_CutsceneActorFollowPlayableInspector : PolarisCutsceneActorPlayableDrawer
    {
        private E_CutsceneActorFollowPlayableAsset followAsset = null;
        private Transform root = null;

        private void OnEnable()
        {
            followAsset = target as E_CutsceneActorFollowPlayableAsset;
            InitRoot();
        }

        public override void OnInspectorGUI()
        {
            EditorGUILayout.LabelField("跟随挂点:");
            Transform newRoot = EditorGUILayout.ObjectField(root, typeof(Transform), true) as Transform;
            followAsset.isNotFollowRotation = EditorGUILayout.Toggle("只跟随挂点位置及缩放:", followAsset.isNotFollowRotation);
            followAsset.posOffset = EditorGUILayout.Vector3Field("位置偏移：", followAsset.posOffset);
            followAsset.eurOffset = EditorGUILayout.Vector3Field("角度偏移：", followAsset.eurOffset);
            followAsset.scale = EditorGUILayout.FloatField("跟随缩放：", followAsset.scale);
            if (GUILayout.Button("重置跟随节点"))
            {
                ResetFollowRoot();
            }
            UpdateRoot(newRoot);
            this.serializedObject.ApplyModifiedProperties();
        }

        private void UpdateRoot(Transform newRoot)
        {
            if (newRoot == root)
            {
                return;
            }
            var key = followAsset.key;
            GameObject actorGO = CutsceneLuaExecutor.Instance.GetActorGOFollowRoot(key);
            if (actorGO != null)
            {
                if (newRoot != null)
                {
                    Transform parent = actorGO.transform.parent;
                    if (parent != newRoot)
                    {
                        root = newRoot;
                        UpdateRootPath();
                    }
                }
                else
                {
                    GameObject defaultRoot = CutsceneLuaExecutor.Instance.GetRoleGOsRoot();
                    if (defaultRoot != null)
                    {
                        root = defaultRoot.transform;
                        UpdateRootPath();
                    }
                }
            }
        }

        private void UpdateRootPath()
        {
            StringBuilder builder = new StringBuilder();
            GameObject roleRootGO = CutsceneLuaExecutor.Instance.GetRoleGOsRoot();
            Transform roleRootTrans = roleRootGO.transform;
            int followKey = -1;
            if (root != null && root != roleRootTrans)
            {
                Transform curPos = root;
                while (curPos != null)
                {
                    builder.Insert(0, curPos.name);
                    curPos = curPos.parent;
                    if (!curPos.name.Contains(CutsceneEditorConst.ACTOR_FOLLOW_ROOTGO_NAME_MARK))
                    {
                        builder.Insert(0, "/");
                    }
                    else
                    {
                        followKey = Int32.Parse(curPos.name.Replace(CutsceneEditorConst.ACTOR_FOLLOW_ROOTGO_NAME_MARK, ""));
                        break;
                    }
                }

                if (curPos == null || curPos.parent == null)
                {
                    builder.Clear();
                }
            }
            followAsset.followKey = followKey;
            followAsset.rootPath = builder.ToString();
            Debug.Log(string.Format("FolloeKey:{0}, Path:{1}", followKey, followAsset.rootPath));
        }

        private void InitRoot()
        {
            root = GetRoot();
        }

        private Transform GetRoot()
        {
            Transform root = null;
            if (followAsset != null)
            {
                string rootPath = followAsset.rootPath;
                int followKey = followAsset.followKey;
                if (followKey < 0)
                {
                    return root;
                }

                GameObject followGO = CutsceneLuaExecutor.Instance.GetActorGOFollowRoot(followKey);
                if (followGO == null)
                {
                    GameObject roleRoot = CutsceneLuaExecutor.Instance.GetRoleGOsRoot();
                    if (roleRoot != null)
                    {
                        root = roleRoot.transform;
                    }
                }
                else
                {
                    root = followGO.transform.Find(rootPath);
                }
            }

            return root;
        }

        private void ResetFollowRoot()
        {
            if (followAsset != null)
            {
                int key = followAsset.key;
                if (key < 0)
                {
                    return;
                }

                GameObject followGO = CutsceneLuaExecutor.Instance.GetActorGOFollowRoot(key);
                Transform followTrans = followGO.transform;
                followTrans.localPosition = followAsset.posOffset;
                float scale = followAsset.scale;
                followTrans.localScale = new Vector3(scale, scale, scale);
            }
        }
    }
}

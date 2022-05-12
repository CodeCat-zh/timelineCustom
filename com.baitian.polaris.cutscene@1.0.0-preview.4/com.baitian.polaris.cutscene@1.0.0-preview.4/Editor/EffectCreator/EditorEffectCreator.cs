using System.Collections;
using System.Collections.Generic;
using System.IO;
using DG.Tweening;
using UnityEngine;

namespace Polaris.CutsceneEditor
{
    public class EditorEffectCreator : IEffectCreator
    {
        string[] EFFECT_PARENT_FOLDERS = new []{"Assets/GameAssets/Shared/Effects/Combat/", "Assets/GameAssets/Shared/Effects/Common/", "Assets/GameAssets/Shared/Effects/Scene/", "Assets/GameAssets/Shared/Effects/Cutscene/" };
        
        public GameObject SpawnEffect(string effectName)
        {
            var prefab = SearchPrefab(effectName);
            if (prefab != null)
            {
                return Object.Instantiate(prefab);
            }
            else
            {
                return null;
            }
        }

        GameObject SearchPrefab(string effectName)
        {
#if UNITY_EDITOR
            var searchPattern = string.Format("*{0}.prefab", effectName);
            for (int i = 0; i < EFFECT_PARENT_FOLDERS.Length; i++)
            {
                var parentPath = EFFECT_PARENT_FOLDERS[i];
                var paths = Directory.GetFiles(parentPath, searchPattern, SearchOption.AllDirectories);
                for (int index = 0; index < paths.Length; index++)
                {
                    var filePath = paths[index];
                    var fileName = Path.GetFileNameWithoutExtension(filePath);
                    if (fileName.Equals(effectName))
                    {
                        var result = UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>(filePath);
                        return result;
                    }
                }
            }

            return null;
#else
            return null;
#endif
        }

        public void DespawnEffect(GameObject effectGO)
        {
            if (effectGO)
            {
                Object.DestroyImmediate(effectGO);
            }
        }
    }

}

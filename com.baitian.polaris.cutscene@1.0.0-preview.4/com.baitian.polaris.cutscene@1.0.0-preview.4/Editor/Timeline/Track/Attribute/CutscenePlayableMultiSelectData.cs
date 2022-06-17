using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEditor;

namespace Polaris.CutsceneEditor
{
    public class CutscenePlayableMultiSelectData
    {
        private int categoryType;
        Dictionary<int,CutsceneClipInspectorData> typeStructDic = new Dictionary<int, CutsceneClipInspectorData>();
        Dictionary<string,int> nameToClipTypeDic = new Dictionary<string, int>();
        Dictionary<int,int> clipTypeToIndexDic = new Dictionary<int, int>();
        
        public CutscenePlayableMultiSelectData(int categoryType)
        {
            this.categoryType = categoryType;
        }

        public void GenerateTypeDescription(out string[] typeNameArr)
        {
            typeStructDic.Clear();
            nameToClipTypeDic.Clear();
            clipTypeToIndexDic.Clear();
            Dictionary<Type,object> typeToAttributeDic = PolarisCutsceneEditorUtils.GetAtrritbuteTypeDescriptorTypes(typeof(CutscenePlayableSelectTypeAttribute));
            List<int> indexs = new List<int>();
            foreach (KeyValuePair<Type,object> kv in typeToAttributeDic)
            {
                CutsceneClipInspectorData newData =  new CutsceneClipInspectorData(kv.Key,kv.Value as CutscenePlayableSelectTypeAttribute );
                if (newData.categoryType != categoryType)
                {
                    continue;
                }
                CutsceneClipInspectorData data;
                if (typeStructDic.TryGetValue(newData.clipType, out data))
                {
                    if (newData.order > data.order)
                    {
                        continue;
                    }
                }
                else
                {
                    indexs.Add(newData.clipType);
                }
            
                typeStructDic[newData.clipType] = newData;
                nameToClipTypeDic[newData.clipName] = newData.clipType;
            }
                
            indexs.Sort();
            typeNameArr = new string[indexs.Count];
            for (int i = 0; i < typeNameArr.Length; i++)
            {
                typeNameArr[i] = typeStructDic[indexs[i]].clipName;
                clipTypeToIndexDic.Add(indexs[i],i);
            }
        }

        // public void Generate(out string[] typeNameArr)
        // {
        //     typeStructDic.Clear();
        //     nameToClipTypeDic.Clear();
        //     clipTypeToIndexDic.Clear();
        //     Type[] types = PolarisCutsceneEditorUtils.GetAttributeTypes(typeof(CutscenePlayableSelectTypeAttribute));
        //     List<int> indexs = new List<int>();
        //     foreach (Type type in types)
        //     {
        //         CutsceneClipInspectorData newData =  new CutsceneClipInspectorData(type);
        //         if (newData.categoryType != categoryType)
        //         {
        //             continue;
        //         }
        //         CutsceneClipInspectorData data;
        //         if (typeStructDic.TryGetValue(newData.clipType, out data))
        //         {
        //             if (newData.order > data.order)
        //             {
        //                 continue;
        //             }
        //         }
        //         else
        //         {
        //             indexs.Add(newData.clipType);
        //         }
        //     
        //         typeStructDic[newData.clipType] = newData;
        //         nameToClipTypeDic[newData.clipName] = newData.clipType;
        //     }
        //         
        //     indexs.Sort();
        //     typeNameArr = new string[indexs.Count];
        //     for (int i = 0; i < typeNameArr.Length; i++)
        //     {
        //         typeNameArr[i] = typeStructDic[indexs[i]].clipName;
        //         clipTypeToIndexDic.Add(indexs[i],i);
        //     }
        // }

        public int GetClipType(string clipName)
        {
            return nameToClipTypeDic[clipName];
        }

        public int GetIndex(int clipType)
        {
            if (clipTypeToIndexDic.ContainsKey(clipType))
            {
                return clipTypeToIndexDic[clipType];
            }
            

            return 0;
        }

        public IMultiTypeInspector GetInstance(SerializedObject serializedObject,int clipType)
        {
            CutsceneClipInspectorData data;
            if (typeStructDic.TryGetValue(clipType, out data))
            {
                return data.GetInstance(serializedObject);
            }
            
            return null;            
        }
    }
    
    public class CutsceneClipInspectorData
    {
        public int categoryType;
        public int clipType;
        public string clipName;
        public int order;
        public Type type;
        public IMultiTypeInspector instance;

        public CutsceneClipInspectorData(Type type)
        {
            CutscenePlayableSelectTypeAttribute typeAttribute = type.GetCustomAttribute<CutscenePlayableSelectTypeAttribute>();
            Init(type,typeAttribute);
        }

        public CutsceneClipInspectorData(Type type,CutscenePlayableSelectTypeAttribute typeAttribute)
        {
            Init(type,typeAttribute);
        }
        


        private void Init(Type type,CutscenePlayableSelectTypeAttribute typeAttribute)
        {
            this.categoryType = typeAttribute.Category;
            this.clipName = typeAttribute.ClipName;
            this.clipType = typeAttribute.ClipType;
            this.order = typeAttribute.Order;
            this.type = type;
        }

        public IMultiTypeInspector GetInstance(SerializedObject serializedObject)
        {
            if (instance == null)
            {
                instance = Activator.CreateInstance(type,serializedObject) as IMultiTypeInspector;
            }

            return instance;
        }
    }
}
using System.Collections.Generic;
using LitJson;
using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using System;

namespace Polaris.CutsceneEditor.Data
{
    public struct SimpleActorInfo
    {
        [PlayableFieldConvert(PlayableFieldType.String)]
        public string actorName;
        [PlayableFieldConvert(PlayableFieldType.String)]
        public string actorAssetInfo;
        [PlayableFieldConvert(PlayableFieldType.Int32)]
        public int bindId;
        [PlayableFieldConvert(PlayableFieldType.Float)]
        public float scale;
        [PlayableFieldConvert(PlayableFieldType.Vector3)]
        public Vector3 initPos;
        [PlayableFieldConvert(PlayableFieldType.Vector3)]
        public Vector3 initRot;
        [PlayableFieldConvert(PlayableFieldType.String)]
        public string actorModelInfo;
        [PlayableFieldConvert(PlayableFieldType.Bool)]
        public bool initHide;
        [PlayableFieldConvert(PlayableFieldType.String)]
        public string fashionListStr;

        public static SimpleActorInfo GetInitSimpleInfo()
        {
            return new SimpleActorInfo()
            {
                actorName = "",
                actorAssetInfo = "",
                bindId = 0,
                scale = 1,
                initPos = new Vector3(0, 0, 0),
                initRot = new Vector3(0, 0, 0),
                actorModelInfo = "",
                initHide = false,
                fashionListStr = ""
            };
        }
        
        public static SimpleActorInfo JsonToObject(string jsonDataStr)
        {
            JsonData jsonData = JsonMapper.ToObject<JsonData>(jsonDataStr);
            SimpleActorInfo actorInfo = GetInitSimpleInfo();
            actorInfo.actorName = (string)jsonData["actorName"];
            actorInfo.actorAssetInfo = (string)jsonData["actorAssetInfo"];
            actorInfo.bindId = Int32.Parse((string)jsonData["bindId"]);
            actorInfo.scale = Int32.Parse((string)jsonData["scale"]);
            actorInfo.initPos = TimelineConvertUtils.StringToVec3((string) jsonData["initPos"]);
            actorInfo.initRot = TimelineConvertUtils.StringToVec3((string) jsonData["initRot"]);
            actorInfo.actorModelInfo = (string)jsonData["actorModelInfo"];
            actorInfo.initHide = TimelineConvertUtils.StringToBool((string)jsonData["initHide"]);
            actorInfo.fashionListStr = (string)jsonData["fashionListStr"];
            return actorInfo;
        }

        public string ToJson()
        {
            JsonData jsonData = new JsonData();
            List<ClipParams> clipParamses = TimelineConvertUtils.GetConvertParamsList(this);
            foreach (ClipParams clipParams in clipParamses)
            {
                jsonData[clipParams.Key] = clipParams.Value;
            }

            return JsonMapper.ToJson(jsonData);
        }
    }
}
using System;
using System.Collections.Generic;
using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using Polaris.CutsceneEditor;

namespace PJBNEditor.Cutscene
{
    [Serializable]
    public class E_CutsceneImpulsePlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset, ITrackClipParamsConvert, ITimelineInstanceClip
    {
        [Serializable]
        public struct NoiseParams
        {
            public float Frequency;
            public float Amplitude;
            public bool Constant;
            public float GetValueAt(float time, float timeOffset)
            {
                float t = (Frequency * time) + timeOffset;
                if (Constant)
                    return Mathf.Cos(t * 2 * Mathf.PI) * Amplitude * 0.5f;
                return (Mathf.PerlinNoise(t, 0f) - 0.5f) * Amplitude;
            }

            public void InitNoiseParams(float frequency,float amplitude,bool constant)
            {
                this.Frequency = frequency;
                this.Amplitude = amplitude;
                this.Constant = constant;
            }
        }
        [Serializable]
        public struct TransformNoiseParams
        {
            public NoiseParams X;
            public NoiseParams Y;
            public NoiseParams Z;
            public Vector3 GetValueAt(float time, Vector3 timeOffsets)
            {
                return new Vector3(
                    X.GetValueAt(time, timeOffsets.x),
                    Y.GetValueAt(time, timeOffsets.y),
                    Z.GetValueAt(time, timeOffsets.z));
            }

            public void InitTransformNoiseParams(NoiseParams X,NoiseParams Y,NoiseParams Z)
            {
                this.X = X;
                this.Y = Y;
                this.Z = Z;
            }
        }

        [SerializeField]
        public TransformNoiseParams[] PositionNoise = new TransformNoiseParams[0];

        [SerializeField]
        public TransformNoiseParams[] OrientationNoise = new TransformNoiseParams[0];


        [PlayableFieldConvert(PlayableFieldType.List)]
        public List<string> position_x = new List<string>();
        [PlayableFieldConvert(PlayableFieldType.List)]
        public List<string> position_y = new List<string>();
        [PlayableFieldConvert(PlayableFieldType.List)]
        public List<string> position_z = new List<string>();

        [PlayableFieldConvert(PlayableFieldType.List)]
        public List<string> rotation_x = new List<string>();
        [PlayableFieldConvert(PlayableFieldType.List)]
        public List<string> rotation_y = new List<string>();
        [PlayableFieldConvert(PlayableFieldType.List)]
        public List<string> rotation_z = new List<string>();

        public void SetInitInfo()
        {
            if (PositionNoise.Length == 0)
            {
                PositionNoise = new TransformNoiseParams[5];
                for (int i = 0; i < PositionNoise.Length; i++)
                {
                    var transformNoiseParams = new TransformNoiseParams();
                    var noiseX = new NoiseParams();
                    var noiseY = new NoiseParams();
                    var noiseZ = new NoiseParams();
                    switch (i)
                    {
                       case 0:
                           noiseX.InitNoiseParams(3.2f,0.04f,true);
                           noiseY.InitNoiseParams(1.9f,0.059f,true);
                           noiseZ.InitNoiseParams(0,0,true);
                           break;
                       case 1:
                           noiseX.InitNoiseParams(7.7f,0.05f,false);
                           noiseY.InitNoiseParams(9.1f,0.04f,false);
                           noiseZ.InitNoiseParams(0,0,true);
                           break;
                       case 2:
                           noiseX.InitNoiseParams(51.51f,0.04f,true);
                           noiseY.InitNoiseParams(55.4f,0.05f,true);
                           noiseZ.InitNoiseParams(0,0,true);
                           break;
                       case 3:
                           noiseX.InitNoiseParams(0,0,false);
                           noiseY.InitNoiseParams(0,0,true);
                           noiseZ.InitNoiseParams(0,0,false);
                           break;
                       case 4:
                           noiseX.InitNoiseParams(0,0,true);
                           noiseY.InitNoiseParams(0,0,true);
                           noiseZ.InitNoiseParams(0,0,false);
                           break;
                    }
                    transformNoiseParams.InitTransformNoiseParams(noiseX,noiseY,noiseZ);
                    PositionNoise[i] = transformNoiseParams;
                }
            }
        }
        
        public void SaveInfo()
        {
            position_x.Clear();
            position_y.Clear();
            position_z.Clear();
            rotation_x.Clear();
            rotation_y.Clear();
            rotation_z.Clear();
            for (int i = 0; i < PositionNoise.Length; i++)
            {
                TransformNoiseParams _params = PositionNoise[i];
                position_x.Add($"{ _params.X.Frequency }_{ _params.X.Amplitude }_{ BoolToStr(_params.X.Constant) }");
                position_y.Add($"{ _params.Y.Frequency }_{ _params.Y.Amplitude }_{ BoolToStr(_params.Y.Constant) }");
                position_z.Add($"{ _params.Z.Frequency }_{ _params.Z.Amplitude }_{ BoolToStr(_params.Z.Constant) }");
            }
            for (int i = 0; i < OrientationNoise.Length; i++)
            {
                TransformNoiseParams _params = OrientationNoise[i];
                rotation_x.Add($"{ _params.X.Frequency }_{ _params.X.Amplitude }_{ BoolToStr(_params.X.Constant) }");
                rotation_y.Add($"{ _params.Y.Frequency }_{ _params.Y.Amplitude }_{ BoolToStr(_params.Y.Constant) }");
                rotation_z.Add($"{ _params.Z.Frequency }_{ _params.Z.Amplitude }_{ BoolToStr(_params.Z.Constant) }");
            }
        }

        private int BoolToStr(bool v)
        {
            if (v == true)
            {
                return 1;
            }
            return 0;
        }

        public TimelineClip instanceClip { set; get; }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int)CutsceneTrackType.DirectorImpulseTrackType, GetParamList());
            if (playable.IsValid())
            {
                return playable;
            }
            return Playable.Create(graph);
            
        }

        public void GatherProperties(PlayableDirector director, IPropertyCollector driver)
        {

        }

        public ClipCaps clipCaps { get; }

        public List<ClipParams> GetParamList()
        {
            List<ClipParams> paramList = TimelineConvertUtils.GetConvertParamsList(this);
            return paramList;
        }

    }
}
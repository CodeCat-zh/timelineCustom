using Pathfinding;
using Polaris.ToLuaFramework;
using System.Collections.Generic;
using System.Reflection;
using UnityEditor;
using UnityEditor.Timeline;
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.UI;

public class CutsceneAnimClipEditorWindow : EditorWindow
{
    static CutsceneAnimClipEditorWindow m_EditorView;
    public static void OpenView(TrackAsset trackAsset)
    {
        if (m_EditorView == null)
        {
            m_EditorView = EditorWindow.GetWindow<CutsceneAnimClipEditorWindow>("����Ƭ�β���");
            m_EditorView.Show();
            m_EditorView.OpenRefresh(trackAsset);
        }
        
    }

    private double clipStartValue;
    private float startSliderValue = 0;
    private float endSliderValue = 1;
    private float playSliderValue = 0;

    private Vector3 showPos = Vector3.zero;
    private Vector3 showRot = Vector3.zero;

    private Object m_SelectClip;
    private TimelineClip m_CurrentTimelineClip;

    private GameObject m_CameraObject;
    private RawImage m_ShowRawImage;
    private Animator m_ShowAnimator;
    private GameObject m_ModleObject;

    private bool isPlay = true;
    private bool isPlay_old = false;
    private float play_time = 0;
    private int updateValue = 0;

    private bool isEffective = false;


    //�򿪽���ʱˢ��һ��
    public void OpenRefresh(TrackAsset trackAsset)
    {
        if (m_CameraObject != null)
        {
            return;
        }

        //���������Ԥ��
        GameObject asset = AssetDatabase.LoadAssetAtPath<GameObject>(@"Assets\EditorResources\CutsceneResources\AnimTrack\AnimCamera.prefab");
        m_CameraObject = Instantiate(asset);
        //�õ�RawImage
        m_ShowRawImage = m_CameraObject.transform.Find("panel/RawImage").GetComponent<RawImage>();
        //����һ��ģ��
        Animator animator = TimelineEditor.inspectedDirector.GetGenericBinding(trackAsset) as Animator;
        m_ModleObject = Instantiate(animator.gameObject);
        CloseOtherMono();
        m_ModleObject.transform.SetParent(m_CameraObject.transform.Find("panel/modle").transform);
        m_ModleObject.transform.localPosition = Vector3.zero;
        //�õ�Animator
        m_ShowAnimator = m_ModleObject.GetComponent<Animator>();
        m_ShowAnimator.runtimeAnimatorController = null;

        showPos = m_ModleObject.transform.localPosition;
        showRot = m_ModleObject.transform.localEulerAngles;
        
    }
    private void CloseOtherMono()
    {
        MonoBehaviour[] monoBehaviours = m_ModleObject.GetComponents<MonoBehaviour>();
        for (int i = 0; i < monoBehaviours.Length; i++)
        {
            MonoBehaviour mono = monoBehaviours[i];
            Debug.Log(mono.GetType());
            if (mono.GetType() != typeof(Animator) && mono.GetType() != typeof(Seeker))
            {
                Destroy(mono);
            }
        }
    }

    //ѡ�й��ʱˢ��һ��
    private void SelectClipRefresh(Object selectClip, TimelineClip timelineClip)
    {
        m_SelectClip = selectClip;
        m_CurrentTimelineClip = timelineClip;

        startSliderValue = (float)m_CurrentTimelineClip.clipIn;
        endSliderValue = (float)(m_CurrentTimelineClip.clipIn + m_CurrentTimelineClip.duration);
        playSliderValue = startSliderValue;

        clipStartValue = m_CurrentTimelineClip.start;

    }
    
    private void Update()
    {
        if (m_CameraObject == null || m_ShowRawImage == null || m_ShowAnimator == null || m_ModleObject == null || m_SelectClip == null || m_CurrentTimelineClip == null || m_EditorView == null)
        {
            return;
        }

        updateValue++;
        if (updateValue % 2 == 0)
        {
            m_EditorView.Repaint(); //���»���
        }
        if (isPlay)
        {
            if (isPlay_old != isPlay)
            {
                isPlay_old = isPlay;
                play_time = playSliderValue;
            }
            if (play_time > endSliderValue)
            {
                play_time = startSliderValue;
            }
            play_time = play_time + Time.deltaTime;
            m_CurrentTimelineClip.animationClip.SampleAnimation(m_ShowAnimator.gameObject, play_time);
        }
        else
        {
            isPlay_old = isPlay;
        }
    }


    //private void UpDateAnimator(string name, AnimationClip clip)
    //{
    //    var tOverrideController = new AnimatorOverrideController(m_ShowAnimator.runtimeAnimatorController);
    //    //tOverrideController.runtimeAnimatorController = m_ShowAnimator.runtimeAnimatorController;
    //    if (tOverrideController[name] == null)
    //    {
    //        tOverrideController[name] = clip;
    //    }
    //    m_ShowAnimator.runtimeAnimatorController = null;
    //    m_ShowAnimator.runtimeAnimatorController = tOverrideController;
    //    //m_ShowAnimator.Play(name, 0, 0);
    //    Resources.UnloadUnusedAssets();
    //}
    //private void OnPlay()
    //{
    //    m_ShowAnimator.Play(m_CurrentTimelineClip.displayName, 0, 0);
    //}

    private void OnGUI()
    {
        if (!Application.isPlaying)
        {
            isClose();
            Close();
            return;
        }

        if (m_SelectClip == null)
        {
            GUILayout.Label("����Timeline�����,��������ѡ��һ������Ƭ��");
            return;
        }

        if (m_ShowRawImage != null)
        {
            GUILayout.Box("", new GUILayoutOption[] { GUILayout.Width(266), GUILayout.Height(266) });
            EditorGUI.DrawPreviewTexture(new Rect(10, 10, 256, 256), m_ShowRawImage.texture);
        }
        else
        {
            GUILayout.Label("δ���س���Ҫ��Դ������");
            return;
        }
        EditorGUILayout.Space();
        GUILayout.Label($"���ڵ�����Ƭ�� : {m_CurrentTimelineClip.displayName}");
        EditorGUILayout.Space();

        showPos = EditorGUILayout.Vector3Field("Ԥ��λ��:", showPos);
        showRot = EditorGUILayout.Vector3Field("Ԥ���Ƕ�:", showRot);
        m_ModleObject.transform.localPosition = showPos;
        m_ModleObject.transform.localEulerAngles = showRot;

        EditorGUILayout.Space();
        EditorGUILayout.Space();
        EditorGUILayout.Space();
        isEffective = EditorGUILayout.Toggle("����ʵʱ��Ч:", isEffective);
        EditorGUILayout.Space();
        EditorGUILayout.Space();
        EditorGUILayout.Space();

        float animLength = m_CurrentTimelineClip.animationClip.length;
        startSliderValue = EditorGUILayout.Slider("ͷ���ü�:", startSliderValue, 0, animLength);
        if (startSliderValue > endSliderValue)
        {
            startSliderValue = endSliderValue;
        }
        endSliderValue = EditorGUILayout.Slider("β���ü�:", endSliderValue, 0, animLength);
        if (endSliderValue < startSliderValue)
        {
            endSliderValue = startSliderValue;
        }
        
        if (isPlay)
        {
            if (GUILayout.Button($"��ͣ:{play_time.ToString("#0.000")}"))
            {
                playSliderValue = play_time;
                isPlay = false;
            }
        }
        else
        {
            playSliderValue = EditorGUILayout.Slider("����Ԥ��:", playSliderValue, 0, animLength);
            if (playSliderValue < startSliderValue)
            {
                playSliderValue = startSliderValue;
            }
            if (playSliderValue > endSliderValue)
            {
                playSliderValue = endSliderValue;
            }
            m_CurrentTimelineClip.animationClip.SampleAnimation(m_ShowAnimator.gameObject, playSliderValue);

            if (GUILayout.Button("����"))
            {
                isPlay = true;
            }
        }

        EditorGUILayout.Space();
        GUILayout.Label("�������ֵ��,�����ǰƬ��������Ƭ�η����ص�,�ص����־��Ƕ������ɲ���");
        clipStartValue = EditorGUILayout.DoubleField("ʱ��(s):", clipStartValue);
        EditorGUILayout.Space();

        if (isEffective)
        {
            m_CurrentTimelineClip.duration = endSliderValue - startSliderValue;
            m_CurrentTimelineClip.clipIn = startSliderValue;
            m_CurrentTimelineClip.start = clipStartValue;
            TimelineEditor.Refresh(RefreshReason.WindowNeedsRedraw);
        }
        else
        {
            if (GUILayout.Button("��������"))
            {
                m_CurrentTimelineClip.duration = endSliderValue - startSliderValue;
                m_CurrentTimelineClip.clipIn = startSliderValue;
                m_CurrentTimelineClip.start = clipStartValue;
                TimelineEditor.Refresh(RefreshReason.WindowNeedsRedraw);
            }
        }
    }

    private void OnSelectionChange()
    {
        //var types = Selection.activeObject.GetType().GetProperties();
        //foreach (var item in types)
        //{
        //    Debug.Log($"{item.Name} {item.PropertyType.Name}");
        //}

        Object selectClip = Selection.activeObject;
        Object[] selectClips = Selection.objects;
        Debug.Log(selectClip);
        if (selectClip != null)
        {
            PropertyInfo info = selectClip.GetType().GetProperty("clip");
            if (info != null)
            {
                TimelineClip timelineClip = info.GetValue(selectClip) as TimelineClip;
                if (timelineClip != null)
                {
                    SelectClipRefresh(selectClip, timelineClip);
                }
            }
        }

    }

    private void OnDestroy()
    {
        isClose();
    }

    private void isClose()
    {
        m_EditorView = null;
        m_SelectClip = null;
        m_CurrentTimelineClip = null;

        m_ShowRawImage = null;
        m_ShowAnimator = null;
        m_ModleObject = null;
        if (m_CameraObject != null)
        {
            Destroy(m_CameraObject);
            m_CameraObject = null;
        }
    }
    //private Object m_SelectClip;
    //private TimelineClip m_CurrentTimelineClip;

    //private GameObject m_CameraObject;
    //private RawImage m_ShowRawImage;
    //private Animator m_ShowAnimator;
    //private GameObject m_ModleObject;
    //TimelineAsset timelineAsset = PolarisCutsceneEditorUtils.GetCurrentTimelineAsset();
    //List<TrackAsset> trackAssets = TimelineUtils.GetOutputTracksByType(timelineAsset, typeof(AnimationTrack));

    //for (int i = 0; i < trackAssets.Count; i++)
    //{
    //    TrackAsset trackAsset = trackAssets[i];
    //    List<TimelineClip> timelineClips = TimelineUtils.GetTrackClips(trackAsset);
    //    for (int s = 0; s < timelineClips.Count; s++)
    //    {
    //        Debug.Log(timelineClips[s].displayName);
    //    }
    //}

}


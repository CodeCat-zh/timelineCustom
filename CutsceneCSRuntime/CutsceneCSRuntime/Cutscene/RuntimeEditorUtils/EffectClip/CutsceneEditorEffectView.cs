using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.Timeline;
using UnityEngine.EventSystems;

namespace PJBN.Cutscene
{
    public class CutsceneEditorEffectView : MonoBehaviour
    {
        private string effectPath = @"Assets\GameAssets\Shared\Effects";

        private List<string> toggleList = new List<string>();

        private Dictionary<string, string> effects_path = new Dictionary<string, string>();
        private List<string> searchList = new List<string>();
        private Dictionary<string, GameObject> effects_go = new Dictionary<string, GameObject>();

        private string selectEffect = "";

        private Button toggleBtn;
        private Button closeBtn;
        private InputField inputField;

        private Transform toggleContent;
        private Transform effectContent;

        private GameObject Cell;
        private GameObject toggleView;

        private InputField pos_x;
        private InputField pos_y;
        private InputField pos_z;

        private InputField rot_x;
        private InputField rot_y;
        private InputField rot_z;

        private InputField scale;
        private InputField start;
        private InputField duration;

        private Button createBtn;
        private Button getPosRotBtn;
        private Text clipName;

        private string assetName;
        private string assetBundleName;

        public TimelineClip timelineClip;

        public UnityAction<Vector3, Vector3, float> updateAction1;
        public UnityAction<string, string, float, float> updateAction2;



        private Camera currentCamera = null;
        private PJBN.CameraFollow cameraFollow = null;
        public FreedomCameraEditor freedomCamera = null;

        void Awake()
        {
            clipName = transform.Find("panel/clipName").GetComponent<Text>();
            toggleBtn = transform.Find("panel/ToggleBtn").GetComponent<Button>();
            closeBtn = transform.Find("panel/closeBtn").GetComponent<Button>();
            getPosRotBtn = transform.Find("panel/getPosRotBtn").GetComponent<Button>();
            
            inputField = transform.Find("panel/InputField").GetComponent<InputField>();
            toggleContent = transform.Find("panel/ToggleScrollView/Viewport/Content");
            effectContent = transform.Find("panel/EffectScrollView/Viewport/Content");
            Cell = transform.Find("panel/Cell").gameObject;
            toggleView = transform.Find("panel/ToggleScrollView").gameObject;

            pos_x = transform.Find("panel/pos_x").GetComponent<InputField>();
            pos_y = transform.Find("panel/pos_y").GetComponent<InputField>();
            pos_z = transform.Find("panel/pos_z").GetComponent<InputField>();
            pos_x.onValueChanged.AddListener((value) => { SetValue1(); });
            pos_y.onValueChanged.AddListener((value) => { SetValue1(); });
            pos_z.onValueChanged.AddListener((value) => { SetValue1(); });

            rot_x = transform.Find("panel/rot_x").GetComponent<InputField>();
            rot_y = transform.Find("panel/rot_y").GetComponent<InputField>();
            rot_z = transform.Find("panel/rot_z").GetComponent<InputField>();
            rot_x.onValueChanged.AddListener((value) => { SetValue1(); });
            rot_y.onValueChanged.AddListener((value) => { SetValue1(); });
            rot_z.onValueChanged.AddListener((value) => { SetValue1(); });

            scale = transform.Find("panel/scale").GetComponent<InputField>();
            scale.onValueChanged.AddListener((value) => { SetValue1(); });

            start = transform.Find("panel/start").GetComponent<InputField>();
            start.onValueChanged.AddListener((value) => { SetValue2(); });

            duration = transform.Find("panel/duration").GetComponent<InputField>();
            duration.onValueChanged.AddListener((value) => { SetValue2(); });

            createBtn = transform.Find("panel/createBtn").GetComponent<Button>();
            createBtn.onClick.AddListener(() => { CreateEffect(); });
            closeBtn.onClick.AddListener(() =>
            {
                Destroy(this.gameObject);
            });
            getPosRotBtn.onClick.AddListener(() => { GetEffectPosRot(); });
            toggleBtn.onClick.AddListener(() =>
            {
                toggleView.SetActive(toggleView.activeSelf == false);
            });

            inputField.onValueChanged.AddListener((str) =>
            {
                searchList.Clear();

                foreach (var item in effects_path)
                {
                    string name = item.Key.ToLower();
                    str = str.ToLower();
                    if (name.Contains(str))
                    {
                        searchList.Add(item.Key);
                    }
                }
                RefreshEffectView(searchList);
            });


            toggleList.Add("AllEffect");
            string[] allModule = Directory.GetDirectories(effectPath);
            foreach (var item in allModule)
            {
                toggleList.Add(Path.GetFileName(item));
            }
            RefreshToggleView(toggleList);

            InitInfo("AllEffect");

        }

        private void Update()
        {
            if (timelineClip == null || timelineClip.asset == null)
            {
                updateAction1 = null;
                updateAction2 = null;
                timelineClip = null;
                SetViewName("<color=#ff0000>未选中</color>");
            }
        }

        private void OnEnable()
        {
            currentCamera = PJBN.CutsceneLuaExecutor.Instance.GetMainCamera();
            if (currentCamera != null)
            {
                cameraFollow = currentCamera.GetComponent<PJBN.CameraFollow>();
                if (cameraFollow != null)
                {
                    cameraFollow.enabled = false;
                }
                freedomCamera = currentCamera.gameObject.AddComponent<FreedomCameraEditor>();
                freedomCamera.unityAction += DblClick_UpdatePos;
            }
        }

        private void OnDisable()
        {
            StopAllCoroutines();
            if (currentCamera != null)
            {
                if (cameraFollow != null)
                {
                    cameraFollow.enabled = true;
                }
                if (freedomCamera != null)
                {
                    freedomCamera.unityAction = null;
                    Destroy(freedomCamera);
                }
            }
            cameraFollow = null;
            freedomCamera = null;
        }

        private void OnDestroy()
        {
            foreach (var item in effects_go)
            {
                if (item.Value != null)
                {
                    Destroy(item.Value);
                }
            }
            effects_go.Clear();
        }

        private void DblClick_UpdatePos(Vector3 pos)
        {
            SetEffectTempPos(pos);
        }

        private void GetEffectPosRot()
        {
            GameObject go;
            if (effects_go.TryGetValue(timelineClip.displayName, out go))
            {
                Vector3 pos = go.transform.localPosition;
                Vector3 rot = go.transform.localEulerAngles;
                SetEffectTempPos(pos);
                SetEffectTempRot(rot);
            }
        }

        public void InitValue(string _assetName, string _assetBundleName, float _start, float _duration, Vector3 _pos, Vector3 _rot, float _scale)
        {
            assetName = _assetName;
            assetBundleName = _assetBundleName;
            start.text = _start.ToString();
            duration.text = _duration.ToString();

            pos_x.text = _pos.x.ToString();
            pos_y.text = _pos.y.ToString();
            pos_z.text = _pos.z.ToString();

            rot_x.text = _rot.x.ToString();
            rot_y.text = _rot.y.ToString();
            rot_z.text = _rot.z.ToString();

            scale.text = _scale.ToString();

        }

        public void SetViewName(string _clipName)
        {
            clipName.text = $"选中片段 : {_clipName}";
        }

        private void SetValue1()
        {
            Vector3 pos = new Vector3(GetFloat(pos_x.text), GetFloat(pos_y.text), GetFloat(pos_z.text));
            Vector3 rot = new Vector3(GetFloat(rot_x.text), GetFloat(rot_y.text), GetFloat(rot_z.text));
            float scaleValue = GetFloat(scale.text);
            if (updateAction1 != null)
                updateAction1.Invoke(pos, rot, scaleValue);

            SetEffectGoPos(pos, rot, scaleValue);
        }

        private void SetValue2()
        {
            if (updateAction2 != null)
                updateAction2.Invoke(assetName, assetBundleName, GetFloat(start.text), GetFloat(duration.text));
        }

        public float GetFloat(string str)
        {
            if (string.IsNullOrEmpty(str))
            {
                return 0;
            }
            float tempDecimal = 0;
            float.TryParse(str, out tempDecimal);
            return tempDecimal;
        }

        Coroutine coroutine_effect;
        void RefreshToggleView(List<string> vs)
        {
            StartCoroutine(InitCell(vs, toggleContent, (str) =>
            {
                if (coroutine_effect != null)
                {
                    StopCoroutine(coroutine_effect);
                    coroutine_effect = null;
                }
                InitInfo(str);
                toggleView.SetActive(false);
            }));
        }
        
        void RefreshEffectView(List<string> vs)
        {
#if UNITY_EDITOR
            for (int s = effectContent.childCount - 1; s >= 0; s--)
            {
                Transform t = effectContent.GetChild(s);
                if (t != null)
                {
                    Destroy(t.gameObject);
                }
            }

            coroutine_effect = StartCoroutine(InitCell(vs, effectContent, (str) =>
            {
                selectEffect = str;

                string path;
                if (effects_path.TryGetValue(selectEffect, out path))
                {
                    assetName = selectEffect;
                    assetBundleName = UnityEditor.AssetDatabase.GetImplicitAssetBundleName(path);
                    SetValue2();
                }

            }));
#endif
        }

        IEnumerator InitCell(List<string> vs, Transform content, UnityAction<string> unityAction)
        {
            for (int i = 0; i < vs.Count; i++)
            {
                yield return new WaitForEndOfFrame();
                string name = vs[i];

                GameObject go = Instantiate(Cell);
                Text text = go.transform.Find("Text").GetComponent<Text>();

                Toggle toggle = go.GetComponent<Toggle>();
                toggle.onValueChanged.AddListener((isOn) =>
                {
                    if (isOn == true)
                    {
                        unityAction(name);
                    }
                });
                text.text = name;
                go.transform.SetParent(content);
                go.transform.localScale = Vector3.one;
                go.transform.localPosition = Vector3.zero;
                go.transform.localEulerAngles = Vector3.zero;
                go.name = name;
                go.SetActive(true);

                CutsceneEditorEffectDrag dragsEditor = go.AddComponent<CutsceneEditorEffectDrag>();
                
                dragsEditor.onBeginDrag = (pos) => {
                    //Debug.Log($"��ʼ {name}");
                    CreateEffect();
                };
                dragsEditor.onDrag = (pos) => { 
                    
                    int layer = LayerMask.GetMask("Terrain");
                    RaycastHit hitInfo;
                    if (Physics.Raycast(currentCamera.ScreenPointToRay(pos), out hitInfo, 1000, layer))
                    {
                        SetEffectTempPos(hitInfo.point);
                        //Debug.Log($"�ƶ� {hitInfo.point}");
                    }
                };
                //dragsEditor.onEndDrag = (pos) => { 
                //    Debug.Log($"̧�� {name}"); 
                //};
            }

        }

        void InitInfo(string file)
        {
            toggleBtn.transform.Find("Text").GetComponent<Text>().text = file;

            string path = effectPath;
            if (file != "AllEffect")
            {
                path = $@"{effectPath}\{file}";
            }

            effects_path.Clear();
            searchList.Clear();

            string[] allPrefabPath = Directory.GetFiles(path, "*.prefab", SearchOption.AllDirectories);
            foreach (var item in allPrefabPath)
            {
                string name = Path.GetFileNameWithoutExtension(item);
                name = GetName(name);
                effects_path.Add(name, item);
                searchList.Add(name);
            }
            RefreshEffectView(searchList);
        }

        string GetName(string str)
        {
            if (effects_path.ContainsKey(str))
            {
                string name = str + "_repeat";
                for (int i = 0; i < 10; i++)
                {
                    if (effects_path.ContainsKey(name))
                    {
                        name = name + "_repeat";
                    }
                    else
                    {
                        return name;
                    }
                }

            }
            return str;
        }


        void CreateEffect()
        {
#if UNITY_EDITOR
            if (timelineClip == null)
            {
                return;
            }
            string path;
            if (effects_path.TryGetValue(selectEffect, out path))
            {
                GameObject obj = UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>(path);
                GameObject go = Instantiate(obj);
                Vector3 pos = new Vector3(GetFloat(pos_x.text), GetFloat(pos_y.text), GetFloat(pos_z.text));

                go.transform.localPosition = pos;
                go.transform.localEulerAngles = new Vector3(GetFloat(rot_x.text), GetFloat(rot_y.text), GetFloat(rot_z.text));
                go.transform.localScale = new Vector3(GetFloat(scale.text), GetFloat(scale.text), GetFloat(scale.text));
                
                GameObject oldGo;
                if (effects_go.TryGetValue(timelineClip.displayName, out oldGo))
                {
                    Destroy(oldGo);
                    oldGo = null;
                    effects_go.Remove(timelineClip.displayName);
                }
                effects_go.Add(timelineClip.displayName, go);
            }
#endif
        }
        private void SetEffectTempPos(Vector3 pos)
        {
            pos_x.text = pos.x.ToString();
            pos_y.text = pos.y.ToString();
            pos_z.text = pos.z.ToString();
        }
        private void SetEffectTempRot(Vector3 rot)
        {
            rot_x.text = rot.x.ToString();
            rot_y.text = rot.y.ToString();
            rot_z.text = rot.z.ToString();
        }
        private void SetEffectGoPos(Vector3 pos, Vector3 rot, float scale)
        {
            if (timelineClip == null)
            {
                return;
            }
            GameObject go;
            if (effects_go.TryGetValue(timelineClip.displayName, out go))
            {
                go.transform.localPosition = pos;
                go.transform.localEulerAngles = new Vector3(rot.x, rot.y, rot.z);
                go.transform.localScale = new Vector3(scale, scale, scale);

            }

        }

        public void SelectEffect()
        {
#if UNITY_EDITOR
            if (timelineClip == null)
            {
                return;
            }
            GameObject go;
            if (effects_go.TryGetValue(timelineClip.displayName, out go))
            {
                UnityEditor.EditorGUIUtility.PingObject(go); 
            }
            else
            {
                Debug.Log("未创建过特效，无法定位");
            }
#endif
        }





    }
}

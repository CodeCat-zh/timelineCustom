using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;

//相机围绕centerPoint滑动旋转
public class FreedomCameraEditor : MonoBehaviour
{

    private bool isDown = false;

    public float speed = 0.6f;
    public float distance = 10;
    //相机看向的位置
    public Vector3 centerPoint = Vector3.zero;

    public float fov = 60;

    public UnityAction<Vector3> unityAction;
    //相机的角度
    private Vector3 rotation = new Vector3(50,0,0);

    private Vector3 downPos = Vector3.zero;
    private Vector3 downRot = Vector3.zero;

    private float lastClickTime;
    private Camera currentCamera;

    private void Awake()
    {
        currentCamera = this.GetComponent<Camera>();
    }

    private void Update()
    {
        if (!EventSystem.current.IsPointerOverGameObject())
        {
            if (Input.GetMouseButtonDown(0))
            {
                isDown = true;
                downPos = Input.mousePosition;
                downRot = rotation;
            }

            if (Input.GetAxis("Mouse ScrollWheel") > 0)
            {
                distance = Mathf.Clamp(distance - 1f, 0, 500);
            }
            if (Input.GetAxis("Mouse ScrollWheel") < 0)
            {
                distance = Mathf.Clamp(distance + 1f, 0, 500);
            }
        }
        if (Input.GetMouseButtonUp(0))
        {
            isDown = false;
            if (!EventSystem.current.IsPointerOverGameObject())
            {
                if (currentCamera != null)
                {
                    float nowTime = Time.time;
                    if (nowTime - lastClickTime < 0.3)
                    {
                        int layer = LayerMask.GetMask("Terrain");
                        RaycastHit hitInfo;
                        if (Physics.Raycast(currentCamera.ScreenPointToRay(Input.mousePosition), out hitInfo, 1000, layer))
                        {
                            centerPoint = hitInfo.point;
                            if (unityAction != null)
                            {
                                unityAction.Invoke(centerPoint);
                            }
                        }
                    }
                    lastClickTime = nowTime;
                }
            }
        }

        if (isDown == true)
        {
            var dis = (Input.mousePosition - downPos) * speed;
            rotation = new Vector3(downRot.x - dis.y, downRot.y + dis.x, downRot.z + dis.z);
        }

        FollowTarget();
    }

    void FollowTarget()
    {
        var r = Quaternion.Euler(rotation);
        Vector3 fixPos = r * Vector3.forward * distance;
        transform.position = centerPoint - fixPos;
        transform.LookAt(centerPoint);
        currentCamera.fieldOfView = fov;
    }


}

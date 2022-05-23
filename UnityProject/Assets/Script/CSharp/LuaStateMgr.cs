using LuaInterface;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LuaStateMgr : MonoBehaviour
{
    private static LuaState state;
    // Start is called before the first frame update
    void Start()
    {
        CreateLuaState();
        state.DoFile("TestPlay");
    }

    public static LuaState GetLuaState()
    {
        if (state == null)
        {
          CreateLuaState();
        }
        return state;
    }

    public static void CreateLuaState()
    {
        state = new LuaState();
        state.Start();           // 启动2:虚拟机初始化。
        LuaBinder.Bind(state);  // 踩坑创建lua虚拟机后，即使不启动，不绑定，依旧可以将执行
    }


    public void OnDestroy()
    {
        state.Dispose();
    }
}

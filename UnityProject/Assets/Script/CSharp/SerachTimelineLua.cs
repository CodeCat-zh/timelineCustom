using LuaInterface;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SerachTimelineLua : MonoBehaviour
{
    private static string searchRootPath;
    private static LuaState state;
    private LuaFunction luaFunc;
    private LuaTable table;
    public LuaFunctionBinder GetBinderByType(string type)
    {
        searchRootPath = Application.dataPath + "/Script/lua/Clip";
        if (state == null)
        {
            state = new LuaState();
            state.AddSearchPath(searchRootPath);
            state.Start();           // 启动2:虚拟机初始化。
            LuaBinder.Bind(state);  // 踩坑创建lua虚拟机后，即使不启动，不绑定，依旧可以将执行
        }
        state.DoFile(type);
        var binder = new LuaFunctionBinder();
        var luaClip = state.GetTable(type);
        if (luaClip != null)
        {
            binder.BehaviourPlayCallBack = new LuaFunctionCallBack(luaClip.GetLuaFunction("OnBehaviourPlay"), luaClip);
            binder.BehaviourPauseCallBack = new LuaFunctionCallBack(luaClip.GetLuaFunction("OnBehaviourPause"), luaClip);
            binder.PrepareFrameCallBack = new LuaFunctionCallBack(luaClip.GetLuaFunction("PrepareFrame"), luaClip);
            binder.ProcessFrameCallBack = new LuaFunctionCallBack(luaClip.GetLuaFunction("ProcessFrame"), luaClip);
        }


      
        return binder;
    }
    
    public void OnDestroy()
    {
        state.Dispose();
    }

}

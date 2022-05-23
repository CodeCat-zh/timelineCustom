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
        state = LuaStateMgr.GetLuaState();
        searchRootPath = Application.dataPath + "/Script/lua/Clip";
        state.AddSearchPath(searchRootPath);
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
    



}

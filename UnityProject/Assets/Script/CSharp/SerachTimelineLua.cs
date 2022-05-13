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
        }
        state.LuaPop(state.LuaGetTop());
        state.Require(type);
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

    public void CloseLuaState()
    {
        state.Dispose();
    }

}

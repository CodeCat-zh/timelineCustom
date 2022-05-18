using Cutscene;
using LuaInterface;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class LuaFunctionCallBack
{
    private  LuaFunction luaFunction;
    private LuaTable luaTable;

    public LuaFunctionCallBack(LuaFunction luaFunction, LuaTable luaTable)
    {
        this.luaFunction = luaFunction;
        this.luaTable = luaTable;
    }

    public static void Invoke(LuaFunctionCallBack callBack, Playable playable, FrameData info)
    {
        LuaFunction luaFunction = callBack.luaFunction;
 
        if (luaFunction != null)
        {
            luaFunction.Call(callBack.luaTable, playable,info);
        }
     
    }

    public static void Invoke(LuaFunctionCallBack callBack, Playable playable, FrameData info,List<ClipParam> paramList)
    {
        LuaFunction luaFunction = callBack.luaFunction;

        if (luaFunction != null)
        {
            //直接传list在lua获取是无法确定其类型
            luaFunction.Call(callBack.luaTable,playable, info, paramList.ToArray());
        }
    }
}

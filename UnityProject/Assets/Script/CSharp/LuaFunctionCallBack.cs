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
    public static void Invoke(LuaFunctionCallBack callBack, Playable playable, FrameData info,List<string> paramList)
    {
        LuaFunction luaFunction = callBack.luaFunction;

        if (luaFunction != null)
        {
            //List自定义的类型无法获取，对应的键值，按照网上的教程都试了一遍，在导出文件中_GT(Typeof(List<ClipParam>)，
            //并且ClipParam类型也导出了，但是依旧无法获取自定义类型的属性，猜测需要某些特定的方法才行，目前暂时使用
            // string 传到lua层再做解析
            luaFunction.Call(callBack.luaTable,playable, info, paramList);
        }
    }

    public static void Invoke(LuaFunctionCallBack callBack, Playable playable, FrameData info, object o)
    {
        LuaFunction luaFunction = callBack.luaFunction;

        if (luaFunction != null)
        {
            //List自定义的类型无法获取，对应的键值，按照网上的教程都试了一遍，在导出文件中_GT(Typeof(List<ClipParam>)，
            //并且ClipParam类型也导出了，但是依旧无法获取自定义类型的属性，猜测需要某些特定的方法才行，目前暂时使用
            // string 传到lua层再做解析
            luaFunction.Call(callBack.luaTable, playable, info,o);
        }
    }
}


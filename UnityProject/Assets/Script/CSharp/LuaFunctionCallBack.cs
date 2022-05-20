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
            //List�Զ���������޷���ȡ����Ӧ�ļ�ֵ���������ϵĽ̶̳�����һ�飬�ڵ����ļ���_GT(Typeof(List<ClipParam>)��
            //����ClipParam����Ҳ�����ˣ����������޷���ȡ�Զ������͵����ԣ��²���ҪĳЩ�ض��ķ������У�Ŀǰ��ʱʹ��
            // string ����lua����������
            luaFunction.Call(callBack.luaTable,playable, info, paramList);
        }
    }

    public static void Invoke(LuaFunctionCallBack callBack, Playable playable, FrameData info, object o)
    {
        LuaFunction luaFunction = callBack.luaFunction;

        if (luaFunction != null)
        {
            //List�Զ���������޷���ȡ����Ӧ�ļ�ֵ���������ϵĽ̶̳�����һ�飬�ڵ����ļ���_GT(Typeof(List<ClipParam>)��
            //����ClipParam����Ҳ�����ˣ����������޷���ȡ�Զ������͵����ԣ��²���ҪĳЩ�ض��ķ������У�Ŀǰ��ʱʹ��
            // string ����lua����������
            luaFunction.Call(callBack.luaTable, playable, info,o);
        }
    }
}


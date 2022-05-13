using LuaInterface;
using UnityEngine;

public class LuaFunctionCallBack
{
    private  LuaFunction luaFunction;
    private LuaTable luaTable;


    public  LuaFunctionCallBack(LuaFunction luaFunction,LuaTable luaTable)
    {
        this.luaFunction = luaFunction;
        this.luaTable = luaTable;
    }

    public static void Invoke(LuaFunctionCallBack callBack,object[] args)
    {
        LuaFunction luaFunction = callBack.luaFunction;
 
        if (luaFunction != null)
        {
            luaFunction.Call(callBack.luaTable, args);
        }
     
    }
}

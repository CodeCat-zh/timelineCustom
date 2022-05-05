using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;

public class LuaScene : MonoBehaviour
{
    LuaState state;

    void Start()
    {
        state = new LuaState();
        state.Start();

        string sceneFile = Application.dataPath + "/Script/lua";
        state.AddSearchPath(sceneFile);
    }

    public void Require(string luaFileName)
    {
        state.DoFile(luaFileName);
        state.Require(luaFileName);
    }

    public void CloseLuaState()
    {
        state.Dispose();
    }

    private void OnDestroy()
    {
        if( null != state )
         state.Dispose();
    }
}

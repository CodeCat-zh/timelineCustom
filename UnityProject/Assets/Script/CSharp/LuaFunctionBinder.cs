using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LuaFunctionBinder
{
    private LuaFunctionCallBack behaviourPlayCallBack = null;
    private LuaFunctionCallBack behaviourPauseCallBack = null;
    private LuaFunctionCallBack prepareFrameCallBack = null;
    private LuaFunctionCallBack processFrameCallBack = null;
    public LuaFunctionCallBack BehaviourPlayCallBack { get => behaviourPlayCallBack; set => behaviourPlayCallBack = value; }
    public LuaFunctionCallBack BehaviourPauseCallBack { get => behaviourPauseCallBack; set => behaviourPauseCallBack = value; }
    public LuaFunctionCallBack PrepareFrameCallBack { get => prepareFrameCallBack; set => prepareFrameCallBack = value; }
    public LuaFunctionCallBack ProcessFrameCallBack { get => processFrameCallBack; set => processFrameCallBack = value; }
}

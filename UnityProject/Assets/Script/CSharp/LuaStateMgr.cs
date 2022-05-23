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
        state.Start();           // ����2:�������ʼ����
        LuaBinder.Bind(state);  // �ȿӴ���lua������󣬼�ʹ�����������󶨣����ɿ��Խ�ִ��
    }


    public void OnDestroy()
    {
        state.Dispose();
    }
}

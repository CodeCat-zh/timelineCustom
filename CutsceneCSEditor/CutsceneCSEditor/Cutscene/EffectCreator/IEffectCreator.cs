using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace PJBNEditor.Cutscene{
    public interface IEffectCreator
    {
        GameObject SpawnEffect(string effectName);

        void DespawnEffect(GameObject effectGO);
    }
}

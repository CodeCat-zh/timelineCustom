using PathologicalGames;
using UnityEngine;

namespace PJBNEditor.Cutscene{
    public class PoolEffectCreator:IEffectCreator
    {
        private string POOL_NAME = "Effect";
        
        public GameObject SpawnEffect(string effectName)
        {
            var pool = GetPool();
            if (pool != null && pool.prefabs.ContainsKey(effectName))
            {
                var effectTran = pool.Spawn(effectName);
                return effectTran.gameObject;
            }

            return null;
        }

        public void DespawnEffect(GameObject effectGO)
        {
            if (effectGO == null)
            {
                return;
            }
            var pool = GetPool();
            if (pool != null)
            {
                pool.Despawn(effectGO.transform);
            }
        }

        SpawnPool GetPool()
        {
            SpawnPool pool;
            var exist = PoolManager.Pools.TryGetValue(POOL_NAME, out pool);
            if (exist && pool != null)
            {
                return pool;
            }

            return null;
        }
    }
}
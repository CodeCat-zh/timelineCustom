using Polaris;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace PJBNEditor.Cutscene{
    public class CutsceneEffectCreatorManager
    {
        private static IEffectCreator creator;

        public static void SetCreator(IEffectCreator value)
        {
            creator = value;
        }

        public static IEffectCreator creatorInstance
        {
            get
            {
                if (creator != null)
                {
                    return creator;
                }

                bool isInCombatEditorScene = CutsceneEditorUtil.CheckIsInCombatEditor();

                if (isInCombatEditorScene)
                {
                    creator = new EditorEffectCreator();
                }
                else
                {
                    creator = new PoolEffectCreator();
                }
                return creator;
            }
            set { creator = value; }
        }

        public static GameObject SpawnEffect(string effectName)
        {
            return creatorInstance.SpawnEffect(effectName);
        }

        public static void DespawnEffect(GameObject effectGO)
        {
            creatorInstance.DespawnEffect(effectGO);
        }
    }
}
using UnityEngine.Playables;

namespace Cutscene
{
    public class PlayableUntil
    {
        public static float GetTime(Playable playable)
        {
            return (float)playable.GetTime();
        }


        public static float GetDuration(Playable playable)
        {
            return (float)playable.GetDuration();
        }
    }
}
  

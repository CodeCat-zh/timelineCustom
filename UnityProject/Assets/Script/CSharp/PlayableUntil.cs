using UnityEngine;
using Cutscene;
using UnityEngine.Playables;
public class PlayableUntil 
{
    private PlayableDirector playableDirector;

    public void SetDirector(PlayableDirector director)
    {
        playableDirector = director;
    }

    public PlayableDirector GetDirector()
    {
       return playableDirector ;
    }

    public void Play(CommonPlayableAsset commonPlayableAsset)
    {
        if (playableDirector != null)
        {
            playableDirector.Play(commonPlayableAsset);
        }
    }
}

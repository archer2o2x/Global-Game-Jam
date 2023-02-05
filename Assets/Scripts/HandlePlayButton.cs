using UnityEngine;
using Unity.Entities;

public class HandlePlayButton : MonoBehaviour
{
    public void ProcessPlayButton()
    {
        World.DefaultGameObjectInjectionWorld.Unmanaged.GetExistingSystemState<FightSystem>().Enabled = true;
        World.DefaultGameObjectInjectionWorld.Unmanaged.GetExistingSystemState<GrowSystem>().Enabled = true;
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.Entities;

public class HandlePlayButton : MonoBehaviour
{
    public void ProcessPlayButton()
    {
        //World.DefaultGameObjectInjectionWorld.CreateSystem<FightSystem>();
        //World.DefaultGameObjectInjectionWorld.CreateSystem<GrowSystem>();
        World.DefaultGameObjectInjectionWorld.Unmanaged.GetExistingSystemState<FightSystem>().Enabled = true;
        World.DefaultGameObjectInjectionWorld.Unmanaged.GetExistingSystemState<GrowSystem>().Enabled = true;
    }
}

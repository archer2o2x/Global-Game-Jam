using System.Collections;
using System.Collections.Generic;
using TMPro;
using Unity.Collections;
using Unity.Entities;
using UnityEngine;

public class UIDisplayData : MonoBehaviour
{
    public int MaxSeeds;
    public int MaxResources;

    public string SeedTemplate;
    public string ResourcesTemplate;

    public TMP_Text SeedTextComp;
    public TMP_Text ResourceTextComp;

    public EntityQuery UIDataQuerySeeds;
    public EntityQuery UIDataQueryResources;

    private int TillNextUITick;

    private void Start()
    {
        UIDataQuerySeeds = World.DefaultGameObjectInjectionWorld.EntityManager.CreateEntityQuery(typeof(PlayerPlantPrefabAmount));
        UIDataQueryResources = World.DefaultGameObjectInjectionWorld.EntityManager.CreateEntityQuery(typeof(Team), typeof(TeamResources));

        TillNextUITick = 15;
    }

    // Update is called once per frame
    void Update()
    {
        if (TillNextUITick-- > 0) return;

        TillNextUITick = 15;

        UpdateUI();
    }

    void UpdateUI()
    {
        DynamicBuffer<PlayerPlantPrefabAmount> PlantPrefabAmounts = UIDataQuerySeeds.GetSingletonBuffer<PlayerPlantPrefabAmount>();

        int total = 0;

        for (int i = 0; i < PlantPrefabAmounts.Length; i++)
        {
            total += PlantPrefabAmounts[i].Value;
        }

        SeedTextComp.text = SeedTemplate.Replace("[CURR]", total.ToString()).Replace("[MAX]", MaxSeeds.ToString());

        NativeArray<TeamResources> TeamResourcesData = UIDataQueryResources.ToComponentDataArray<TeamResources>(Allocator.Temp);
        NativeArray<Team> TeamData = UIDataQueryResources.ToComponentDataArray<Team>(Allocator.Temp);

        total = 0;

        for (int i = 0; i < TeamResourcesData.Length; i++)
        {
            if (TeamData[i].Value != 0) continue;

            total += Mathf.RoundToInt(TeamResourcesData[i].Value);
        }

        ResourceTextComp.text = ResourcesTemplate.Replace("[CURR]", Mathf.Clamp(total, 0, MaxResources).ToString()).Replace("[MAX]", MaxResources.ToString());
    }
}

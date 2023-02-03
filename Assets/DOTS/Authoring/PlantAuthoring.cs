using System.Collections;
using System.Collections.Generic;
using Unity.Entities;
using UnityEngine;

public class PlantAuthoring : MonoBehaviour
{
    public float PlantResourceWeight;

    public int PlantType;
    public int Team;

    public class PlantBaker : Baker<PlantAuthoring>
    {
        public override void Bake(PlantAuthoring authoring)
        {
            AddComponent(new PlantRadiusMultiplier { Value = 1 });
            AddComponent(new PlantResourceWeight { Value = authoring.PlantResourceWeight });
            AddComponent(new Team { Value = authoring.Team });
            AddComponent(new PlantType { Value = authoring.PlantType });

            AddBuffer<NearbyPlant>();
        }
    }
}

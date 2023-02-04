using System.Collections;
using System.Collections.Generic;
using Unity.Entities;
using UnityEngine;

public class PlantAuthoring : MonoBehaviour
{
    public float PlantRadiusMultiplier;
    public int PlantResourceWeight;

    public float PlantBaseRadius;
    public float GrowPerConsuption;
    public float ResourceStealPerRadius;

    public int Team;

    public GameObject Enemy;

    public class PlantBaker : Baker<PlantAuthoring>
    {
        public override void Bake(PlantAuthoring authoring)
        {
            AddComponent(new PlantRadiusMultiplier { Value = authoring.PlantRadiusMultiplier });
            AddComponent(new PlantResourceWeight { Value = authoring.PlantResourceWeight });
            AddComponent(new Team { Value = authoring.Team });

            AddComponent(new PlantBaseRadius { Value = authoring.PlantBaseRadius });
            AddComponent(new GrowPerConsumption { Value = authoring.GrowPerConsuption });
            AddComponent(new ResourceStealPerRadius { Value = authoring.ResourceStealPerRadius });

            AddBuffer<NearbyPlant>();
            //AddBuffer<NearbyPlant>().Add(new NearbyPlant { Value = GetEntity(authoring.Enemy) });
        }
    }
}

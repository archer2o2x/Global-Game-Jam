using System.Collections;
using System.Collections.Generic;
using Unity.Entities;
using UnityEngine;

public class PlantAuthoring : MonoBehaviour
{
    public float PlantRadiusMultiplier;
    public float PlantResourceWeight;

    public float PlantBaseRadius;
    public float GrowPerConsuption;
    public float ResourceStealPerRadius;

    public int Team;

    public class PlantBaker : Baker<PlantAuthoring>
    {
        public override void Bake(PlantAuthoring authoring)
        {
            AddComponent(new PlantRadiusMultiplier { Value = authoring.PlantRadiusMultiplier });
            AddComponent(new PlantResourceWeight { Value = authoring.PlantResourceWeight });
            AddComponent(new Team { Value = authoring.Team });

            AddSharedComponent(new PlantBaseRadius { Value = authoring.PlantBaseRadius });
            AddSharedComponent(new GrowPerConsumption { Value = authoring.GrowPerConsuption });
            AddSharedComponent(new ResourceStealPerRadius { Value = authoring.ResourceStealPerRadius });

            AddBuffer<NearbyPlant>();
        }
    }
}

using UnityEngine;
using Unity.Entities;

public class PlantConfigAuthoring : MonoBehaviour
{
    public int PlantType;

    public float PlantBaseRadius;
    public float GrowPerConsuption;
    public float ResourceStealPerRadius;

    public class PlantConfigBaker : Baker<PlantConfigAuthoring>
    {
        public override void Bake(PlantConfigAuthoring authoring)
        {
            AddComponent(new PlantType { Value = authoring.PlantType });
            AddSharedComponent(new PlantBaseRadius { Value = authoring.PlantBaseRadius });
            AddComponent(new GrowPerConsumption { Value = authoring.GrowPerConsuption });
            AddComponent(new ResourceStealPerRadius { Value = authoring.ResourceStealPerRadius });
        }
    }
}
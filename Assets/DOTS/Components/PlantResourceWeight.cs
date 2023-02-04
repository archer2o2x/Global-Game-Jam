using Unity.Entities;

// Specifies the amount of resources to give this plant of the global tick resources
public struct PlantResourceWeight: IComponentData
{
    public int Value;
}

using Unity.Entities;

// Specifies the how much the plant has grown from the base radius
public struct PlantRadiusMultiplier : IComponentData
{
    public float Value;
}

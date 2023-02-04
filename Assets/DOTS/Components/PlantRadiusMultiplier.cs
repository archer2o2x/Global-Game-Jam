using Unity.Entities;
using Unity.Mathematics;

// Specifies the how much the plant has grown from the base radius
public struct PlantRadiusMultiplier : IComponentData
{
    public float Value;
    public float MaxValue;

    public void AddValue(float amount)
    {
        Value += amount;
        Value = math.min(Value, MaxValue);
    }
}

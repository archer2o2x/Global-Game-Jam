using Unity.Entities;

[InternalBufferCapacity(10)]
public struct NearbyPlant : IBufferElementData
{
    public Entity Value;
}
using Unity.Entities;

[InternalBufferCapacity(10)]
public struct PlayerPlantPrefab : IBufferElementData
{
    public Entity Value;
}

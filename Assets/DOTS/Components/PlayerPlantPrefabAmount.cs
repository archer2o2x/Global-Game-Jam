using Unity.Entities;

[InternalBufferCapacity(10)]
public struct PlayerPlantPrefabAmount : IBufferElementData
{
    public int Value;
}
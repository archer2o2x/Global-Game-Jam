using Unity.Burst;
using Unity.Entities;
using Unity.Transforms;
using UnityEngine;

[BurstCompile]
[UpdateBefore(typeof(EndSimulationEntityCommandBufferSystem))]
public partial struct GraphicsSpawnerSystem : ISystem
{
    [BurstCompile] public void OnCreate(ref SystemState state){}

    public void OnUpdate(ref SystemState state)
    {
        var ecbSingleton = SystemAPI.GetSingleton<EndSimulationEntityCommandBufferSystem.Singleton>();
        var ecb = ecbSingleton.CreateCommandBuffer(state.WorldUnmanaged);
        foreach (var (transform, type, entity) in SystemAPI.Query<WorldTransform, PlantType>().WithNone<AnimatorReference>().WithEntityAccess())
        {
            var prefab = GraphicsPrefabs.Instance.GetPrefab(type.value);
            var graphic = Object.Instantiate(prefab, transform.Position, Quaternion.identity);
            ecb.AddComponent(entity, new AnimatorReference { value = graphic.GetComponent<Animator>() });
        }
    }

    [BurstCompile] public void OnDestroy(ref SystemState state) { }
}
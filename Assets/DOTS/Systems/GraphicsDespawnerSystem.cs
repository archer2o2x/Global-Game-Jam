using Unity.Burst;
using Unity.Entities;
using Unity.Transforms;
using UnityEngine;

[BurstCompile]
[UpdateBefore(typeof(EndSimulationEntityCommandBufferSystem))]
public partial struct GraphicsDespawnerSystem : ISystem
{
    [BurstCompile] public void OnCreate(ref SystemState state) { }

    public void OnUpdate(ref SystemState state)
    {
        var ecbSingleton = SystemAPI.GetSingleton<EndSimulationEntityCommandBufferSystem.Singleton>();
        var ecb = ecbSingleton.CreateCommandBuffer(state.WorldUnmanaged);

        foreach (var (animator, entity) in SystemAPI.Query<AnimatorReference>().WithNone<LocalTransform>().WithEntityAccess())
        {
            Object.Destroy(animator.value.gameObject);
            ecb.RemoveComponent<AnimatorReference>(entity);
        }
    }

    [BurstCompile] public void OnDestroy(ref SystemState state) { }
}

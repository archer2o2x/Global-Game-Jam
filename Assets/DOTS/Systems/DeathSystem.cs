using Unity.Burst;
using Unity.Entities;

[BurstCompile]
partial struct DeathSystem : ISystem
{
    [BurstCompile]
    public void OnCreate(ref SystemState state)
    {

    }

    [BurstCompile]
    public void OnDestroy(ref SystemState state)
    {

    }

    [BurstCompile]
    public void OnUpdate(ref SystemState state)
    {
        var ecbSingleton = SystemAPI.GetSingleton<EndSimulationEntityCommandBufferSystem.Singleton>();
        var ecb = ecbSingleton.CreateCommandBuffer(state.WorldUnmanaged);

        var deathJob = new DeathJob
        {
            ParallelECB = ecb.AsParallelWriter()
        };

        deathJob.ScheduleParallel();
    }
}

[BurstCompile]
partial struct DeathJob : IJobEntity
{
    public EntityCommandBuffer.ParallelWriter ParallelECB;

    void Execute([ChunkIndexInQuery] int index, in Entity self, in PlantRadiusMultiplier radiusMultiplier)
    {
        // Represents the minimum viable size of a plant.
        if (radiusMultiplier.Value < 0.05f)
        {
            ParallelECB.DestroyEntity(index, self);
        }
    }
}
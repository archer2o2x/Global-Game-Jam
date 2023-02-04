using Unity.Burst;
using Unity.Entities;

[BurstCompile]
public partial struct TeamResourcesSystem : ISystem
{
    [BurstCompile] public void OnCreate(ref SystemState state) { }

    [BurstCompile]
    public void OnUpdate(ref SystemState state)
    {
        var resourceRate = SystemAPI.GetSingleton<ResourceRatePerSource>().Value;
        new Job { resourceRatePersource = resourceRate, repeat = true }.ScheduleParallel();
    }

    [BurstCompile]
    public partial struct Job : IJobEntity
    {
        public float resourceRatePersource;
        public bool repeat;

        public void Execute(
            ref TeamResources resources,
            in TeamResourceSources resourceSources)
        {
            //TODO: Merge with TeamResourceSourceSystem
            resources.Value = resourceSources.Value * resourceRatePersource;
        }
    }

    [BurstCompile] public void OnDestroy(ref SystemState state) { }
}

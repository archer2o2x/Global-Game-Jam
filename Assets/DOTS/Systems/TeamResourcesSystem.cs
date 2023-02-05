using System.Threading;
using Unity.Burst;
using Unity.Collections;
using Unity.Collections.LowLevel.Unsafe;
using Unity.Entities;
using Unity.Mathematics;
using Unity.Transforms;

[BurstCompile]
public partial struct TeamResourcesSystem : ISystem
{
    private EntityQuery _resourcesQuery;
    private EntityQuery _teamsQuery;

    [BurstCompile] 
    public void OnCreate(ref SystemState state) 
    {
        _teamsQuery = SystemAPI.QueryBuilder().WithAll<TeamTag>().Build();
        _resourcesQuery = SystemAPI.QueryBuilder().WithAll<ResourceTag, WorldTransform>().Build();
    }

    //[BurstCompile]
    public void OnUpdate(ref SystemState state)
    { 
        var teamsAmount = _teamsQuery.CalculateEntityCount();
        var resourceTransforms = _resourcesQuery.ToComponentDataArray<WorldTransform>(Allocator.TempJob);
        var resourceRate = SystemAPI.GetSingleton<ResourceRatePerSource>().Value;

        var resourcesPerTeam = new NativeArray<int>(teamsAmount, Allocator.TempJob);
        var plantsPerTeam = new NativeArray<int>(teamsAmount, Allocator.TempJob);

        new ResourceCountJob
        { 
            resourceTransforms = resourceTransforms, 
            resourcesPerTeam = resourcesPerTeam, 
            plantsPerTeam = plantsPerTeam 
        }.ScheduleParallel();

        new ResourceSetJob
        {
            resourceRate = resourceRate,
            resourcesPerTeam = resourcesPerTeam,
            plantsPerTeam = plantsPerTeam
        }.ScheduleParallel();
    }

    [BurstCompile]
    [WithAll(typeof(PlantType))]
    public partial struct ResourceCountJob : IJobEntity
    {
        [DeallocateOnJobCompletion, ReadOnly] public NativeArray<WorldTransform> resourceTransforms;
        [NativeDisableParallelForRestriction] public NativeArray<int> resourcesPerTeam;
        [NativeDisableParallelForRestriction] public NativeArray<int> plantsPerTeam;

        public void Execute(in WorldTransform plantTransform, in Team team)
        {
            var resourcesNearby = 0;
            var plantPosition = plantTransform.Position;
            var plantRadius = plantTransform.Scale / 2;
            var plantRadiusSq = plantRadius * plantRadius;

            for (int i = 0; i < resourceTransforms.Length; i++)
            {
                var resourcePosition = resourceTransforms[i].Position;

                if (math.distancesq(plantPosition, resourcePosition) < plantRadiusSq)
                {
                    resourcesNearby++;
                }
            }

            unsafe
            {
                //TODO: Optimize?
                Interlocked.Add(ref ((int*)resourcesPerTeam.GetUnsafePtr())[team.Value], resourcesNearby);
                Interlocked.Increment(ref ((int*)plantsPerTeam.GetUnsafePtr())[team.Value]);
            }
        }
    }

    [BurstCompile]
    public partial struct ResourceSetJob : IJobEntity
    {
        public float resourceRate;
        [DeallocateOnJobCompletion, ReadOnly] public NativeArray<int> resourcesPerTeam;
        [DeallocateOnJobCompletion, ReadOnly] public NativeArray<int> plantsPerTeam;

        public void Execute(ref TeamResources resources, ref TeamPlantsCount plantsCount, in Team team)
        {
            resources.Value = resourcesPerTeam[team.Value] * resourceRate;
            plantsCount.Value = plantsPerTeam[team.Value];
        }
    }

    [BurstCompile] public void OnDestroy(ref SystemState state) { }
}

using System.Threading;
using Unity.Burst;
using Unity.Collections;
using Unity.Collections.LowLevel.Unsafe;
using Unity.Entities;
using Unity.Mathematics;
using Unity.Transforms;

[BurstCompile]
public partial struct TeamResourceSourcesSystem : ISystem
{
    private EntityQuery _resourcesQuery;
    private EntityQuery _teamsQuery;

    [BurstCompile] 
    public void OnCreate(ref SystemState state) 
    {
        _teamsQuery = SystemAPI.QueryBuilder().WithAll<TeamTag>().Build();
        _resourcesQuery = SystemAPI.QueryBuilder().WithAll<ResourceTag, WorldTransform>().Build();
    }

    public void OnUpdate(ref SystemState state)
    {
        var teamsAmount = _teamsQuery.CalculateEntityCount();
        var resourcesPerTeam = new NativeArray<int>(teamsAmount, Allocator.TempJob);
        var resourceTransforms = _resourcesQuery.ToComponentDataArray<WorldTransform>(Allocator.TempJob);

        new ResourceCountJob {
            resourceTransforms = resourceTransforms,
            resourcesPerTeam = resourcesPerTeam
        }.ScheduleParallel();

        new ResourceSetJob { resourcesPerTeam = resourcesPerTeam }.ScheduleParallel();
    }

    [BurstCompile, WithAll(typeof(PlantTag))]
    public partial struct ResourceCountJob : IJobEntity
    {
        [DeallocateOnJobCompletion, ReadOnly] public NativeArray<WorldTransform> resourceTransforms;
        [NativeDisableParallelForRestriction] public NativeArray<int> resourcesPerTeam;

        public void Execute(in WorldTransform plantTransform, in Team team)
        {
            var resourcesNearby = 0;
            var plantPosition = plantTransform.Position;
            var plantRadiusSq = (plantTransform.Scale * plantTransform.Scale) / 2;

            for (int i = 0; i < resourceTransforms.Length; i++)
            {
                var resourcePosition = resourceTransforms[i].Position;

                if(math.distancesq(plantPosition, resourcePosition) < plantRadiusSq)
                {
                    resourcesNearby++;
                }
            }

            unsafe
            {
                //TODO: Optimize?
                Interlocked.Add(ref ((int*)resourcesPerTeam.GetUnsafePtr())[team.Value], resourcesNearby);
            }
        }
    }

    [BurstCompile]
    public partial struct ResourceSetJob : IJobEntity
    {
        [DeallocateOnJobCompletion, ReadOnly] public NativeArray<int> resourcesPerTeam;

        public void Execute(ref TeamResourceSources teamResourceSources, in Team team)
        {
            teamResourceSources.Value = resourcesPerTeam[team.Value];
        }
    }

    [BurstCompile] public void OnDestroy(ref SystemState state) { }
}

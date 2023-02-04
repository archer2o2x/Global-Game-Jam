using System.Threading;
using Unity.Burst;
using Unity.Collections;
using Unity.Collections.LowLevel.Unsafe;
using Unity.Entities;

[BurstCompile]
public partial struct TeamWeightSystem : ISystem
{
    private EntityQuery _resourcesQuery;
    private EntityQuery _teamsQuery;

    [BurstCompile]
    public void OnCreate(ref SystemState state)
    {
        _teamsQuery = SystemAPI.QueryBuilder().WithAll<TeamTag>().Build();
    }

    [BurstCompile]
    public void OnUpdate(ref SystemState state)
    {
        var teamsAmount = _teamsQuery.CalculateEntityCount();
        var weightsPerTeam = new NativeArray<int>(teamsAmount, Allocator.TempJob);

        new WeightCountJob { weightsPerTeam = weightsPerTeam }.ScheduleParallel();
        new ResourceSetJob { weightsPerTeam = weightsPerTeam }.ScheduleParallel();
    }

    [BurstCompile, WithAll(typeof(PlantTag))]
    public partial struct WeightCountJob : IJobEntity
    {
        [NativeDisableParallelForRestriction] public NativeArray<int> weightsPerTeam;

        public void Execute(Entity entity, in PlantResourceWeight weight, in Team team)
        {
            unsafe
            {
                Interlocked.Add(ref ((int*)weightsPerTeam.GetUnsafePtr())[team.Value], weight.Value);
            }
        }
    }

    [BurstCompile]
    public partial struct ResourceSetJob : IJobEntity
    {
        [DeallocateOnJobCompletion, ReadOnly] public NativeArray<int> weightsPerTeam;

        public void Execute(ref TeamWeight teamWeight, in Team team)
        {
            teamWeight.Value = weightsPerTeam[team.Value];
        }
    }

    [BurstCompile] public void OnDestroy(ref SystemState state) { }
}

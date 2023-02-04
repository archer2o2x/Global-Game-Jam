using Unity.Burst;
using Unity.Collections;
using Unity.Entities;

[BurstCompile]
[UpdateAfter(typeof(TeamWeightSystem))]
[UpdateAfter(typeof(TeamResourcesSystem))]
public partial struct GrowSystem : ISystem
{
    private NativeHashMap<int, float> resourcesByTeam;
    private NativeHashMap<int, int> weightsByTeam;
    private EntityQuery _teamsQuery;

    [BurstCompile]
    public void OnCreate(ref SystemState state)
    {
        _teamsQuery = SystemAPI.QueryBuilder().WithAll<Team, TeamResources, TeamWeight>().Build();
        resourcesByTeam = new NativeHashMap<int, float>(100, Allocator.Persistent);
        weightsByTeam = new NativeHashMap<int, int>(100, Allocator.Persistent);
    }

    //[BurstCompile]
    public void OnUpdate(ref SystemState state)
    {
        var teams = _teamsQuery.ToComponentDataArray<Team>(Allocator.Temp);
        var teamResources = _teamsQuery.ToComponentDataArray<TeamResources>(Allocator.Temp);
        var teamWeights = _teamsQuery.ToComponentDataArray<TeamWeight>(Allocator.Temp);

        resourcesByTeam.Clear();
        weightsByTeam.Clear();
        for (int i = 0; i < teams.Length; i++)
        {
            var team = teams[i].Value;
            resourcesByTeam.Add(team, teamResources[i].Value);
            weightsByTeam.Add(team, teamWeights[i].Value);
        }

        new Job { resourcesByTeam = resourcesByTeam, weightsByTeam = weightsByTeam }.ScheduleParallel();
    }

    [BurstCompile]
    public partial struct Job : IJobEntity
    {
        [ReadOnly] public NativeHashMap<int, float> resourcesByTeam;
        [ReadOnly] public NativeHashMap<int, int> weightsByTeam;

        public void Execute(
            ref PlantRadiusMultiplier radiusMultiplier,
            in PlantResourceWeight weight,
            in GrowPerConsumption growPerConsumption,
            in Team team)
        {
            var teamResources = resourcesByTeam[team.Value];
            var teamWeight = weightsByTeam[team.Value];
            var plantResources = teamResources * ((float)weight.Value / teamWeight);
            radiusMultiplier.AddValue(plantResources * growPerConsumption.Value);
        }
    }

    [BurstCompile]
    public void OnDestroy(ref SystemState state)
    {
        resourcesByTeam.Dispose();
        weightsByTeam.Dispose();
    }
}

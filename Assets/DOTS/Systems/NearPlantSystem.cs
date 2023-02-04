using Unity.Collections;
using Unity.Entities;
using Unity.Transforms;
using Unity.Mathematics;
using Unity.Burst;

[BurstCompile]
partial struct NearPlantSystem : ISystem
{
    private EntityQuery TeamQuery;

    [BurstCompile]
    public void OnCreate(ref SystemState state)
    {
        TeamQuery = SystemAPI.QueryBuilder().WithAll<Team, PlantBaseRadius, PlantRadiusMultiplier, WorldTransform>().Build();
    }

    [BurstCompile]
    public void OnUpdate(ref SystemState state)
    {
        new NearPlantJob {
            PlantEntities = TeamQuery.ToEntityArray(Allocator.TempJob),
            PlantTeam = TeamQuery.ToComponentDataArray<Team>(Allocator.TempJob),
            PlantTransforms = TeamQuery.ToComponentDataArray<WorldTransform>(Allocator.TempJob),
            PlantBaseRadii = TeamQuery.ToComponentDataArray<PlantBaseRadius>(Allocator.TempJob),
            PlantRadiiMultiplier = TeamQuery.ToComponentDataArray<PlantRadiusMultiplier>(Allocator.TempJob),

        }.ScheduleParallel();
    }

    [BurstCompile]
    partial struct NearPlantJob : IJobEntity
    {
        [DeallocateOnJobCompletion, ReadOnly]
        public NativeArray<Entity> PlantEntities;
        [DeallocateOnJobCompletion, ReadOnly]
        public NativeArray<Team> PlantTeam;
        [DeallocateOnJobCompletion, ReadOnly]
        public NativeArray<WorldTransform> PlantTransforms;
        [DeallocateOnJobCompletion, ReadOnly]
        public NativeArray<PlantBaseRadius> PlantBaseRadii;
        [DeallocateOnJobCompletion, ReadOnly]
        public NativeArray<PlantRadiusMultiplier> PlantRadiiMultiplier;

        void Execute(ref DynamicBuffer<NearbyPlant> nearbyPlants, in Team team, PlantBaseRadius baseRadius, PlantRadiusMultiplier radiusMultiplier, WorldTransform transform)
        {
            nearbyPlants.Clear();

            for (int i = 0; i < PlantEntities.Length; i ++)
            {
                if (team.Value == PlantTeam[i].Value) continue;

                float TouchDistance = baseRadius.Value * radiusMultiplier.Value + PlantBaseRadii[i].Value * PlantRadiiMultiplier[i].Value;

                if (math.distance(transform.Position, PlantTransforms[i].Position) > TouchDistance) continue;

                nearbyPlants.Add(new NearbyPlant { Value = PlantEntities[i] });
            }
        }
    }

    [BurstCompile] public void OnDestroy(ref SystemState state) { }
}

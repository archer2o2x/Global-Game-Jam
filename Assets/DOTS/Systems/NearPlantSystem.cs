using Unity.Collections;
using Unity.Entities;
using Unity.Transforms;
using Unity.Mathematics;

public class NearPlantSystem : ISystem
{
    private EntityQuery TeamQuery;

    public void OnCreate(ref SystemState state)
    {
        TeamQuery = SystemAPI.QueryBuilder().WithAll<Team, PlantBaseRadius, PlantRadiusMultiplier, WorldTransform>().Build();
    }

    public void OnDestroy(ref SystemState state)
    {
        
    }

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

    partial struct NearPlantJob : IJobEntity
    {
        [DeallocateOnJobCompletion]
        public NativeArray<Entity> PlantEntities;
        [DeallocateOnJobCompletion]
        public NativeArray<Team> PlantTeam;
        [DeallocateOnJobCompletion]
        public NativeArray<WorldTransform> PlantTransforms;
        [DeallocateOnJobCompletion]
        public NativeArray<PlantBaseRadius> PlantBaseRadii;
        [DeallocateOnJobCompletion]
        public NativeArray<PlantRadiusMultiplier> PlantRadiiMultiplier;

        void Execute(ref DynamicBuffer<NearbyPlant> nearbyPlants, in Team team, PlantBaseRadius baseRadius, PlantRadiusMultiplier radiusMultiplier, WorldTransform transform)
        {
            for (int i = 0; i < PlantEntities.Length; i ++)
            {
                if (team.Value == PlantTeam[i].Value) continue;

                float TouchDistance = baseRadius.Value * radiusMultiplier.Value + PlantBaseRadii[i].Value * PlantRadiiMultiplier[i].Value;

                if (math.distance(transform.Position, PlantTransforms[i].Position) > TouchDistance) continue;

                nearbyPlants.Add(new NearbyPlant { Value = PlantEntities[i] });
            }
        }
    }
}
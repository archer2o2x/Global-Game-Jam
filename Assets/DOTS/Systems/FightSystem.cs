using Unity.Burst;
using Unity.Collections;
using Unity.Entities;
using Unity.Transforms;

[BurstCompile]
[UpdateAfter(typeof(GrowSystem))]
[UpdateAfter(typeof(PlantRadiusSystem))]
partial struct FightSystem : ISystem
{
    private ComponentLookup<LocalTransform> LocalLookup;

    [BurstCompile]
    public void OnCreate(ref SystemState state)
    {
        LocalLookup = state.GetComponentLookup<LocalTransform>();
        state.Enabled = false;
    }

    [BurstCompile]
    public void OnUpdate(ref SystemState state)
    {
        LocalLookup.Update(ref state);
        new FightJob { lookup = LocalLookup }.ScheduleParallel();
    }

    [BurstCompile]
    public partial struct FightJob : IJobEntity
    {
        [ReadOnly]
        public ComponentLookup<LocalTransform> lookup;

        public void Execute(ref PlantRadiusMultiplier radiusMultiplier, in DynamicBuffer<NearbyPlant> nearbyPlants, in ResourceStealPerRadius stealPerRadius)
        {
            for (int i = 0; i < nearbyPlants.Length; i++)
            {
                RefRO<LocalTransform> enemyPlant = lookup.GetRefRO(nearbyPlants[i].Value);
                radiusMultiplier.AddValue(-enemyPlant.ValueRO.Scale * stealPerRadius.Value);
            }
        }
    }

    [BurstCompile] public void OnDestroy(ref SystemState state) { }
}
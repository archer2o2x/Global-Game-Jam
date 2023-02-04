using Unity.Burst;
using Unity.Collections;
using Unity.Entities;
using Unity.Transforms;

[BurstCompile]
partial struct FightSystem : ISystem
{
    private ComponentLookup<LocalTransform> LocalLookup;

    [BurstCompile]
    public void OnCreate(ref SystemState state)
    {
        LocalLookup = state.GetComponentLookup<LocalTransform>();
    }

    [BurstCompile]
    public void OnDestroy(ref SystemState state)
    {

    }


    public void OnUpdate(ref SystemState state)
    {
        LocalLookup.Update(ref state);

        var fightJob = new FightJob { };

        fightJob.lookup = LocalLookup;

        fightJob.ScheduleParallel();
    }

    [BurstCompile]
#pragma warning disable CS0282 // There is no defined ordering between fields in multiple declarations of partial struct
    public partial struct FightJob : IJobEntity
#pragma warning restore CS0282 // There is no defined ordering between fields in multiple declarations of partial struct
    {
        [ReadOnly]
        public ComponentLookup<LocalTransform> lookup;

        void Execute(ref PlantRadiusMultiplier radiusMultiplier, in DynamicBuffer<NearbyPlant> nearbyPlants, in ResourceStealPerRadius stealPerRadius)
        {
            for (int i = 0; i < nearbyPlants.Length; i++)
            {
                if (!lookup.HasComponent(nearbyPlants[i].Value)) continue;

                RefRO<LocalTransform> enemyPlant = lookup.GetRefRO(nearbyPlants[i].Value);

                radiusMultiplier.Value -= enemyPlant.ValueRO.Scale * stealPerRadius.Value;

            }

            //radiusMultiplier.Value -= 0.0005f;
        }
    }

}

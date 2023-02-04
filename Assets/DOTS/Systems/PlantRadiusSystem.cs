using Unity.Burst;
using Unity.Entities;
using Unity.Transforms;

[BurstCompile]
public partial struct PlantRadiusSystem : ISystem
{
    [BurstCompile] public void OnCreate(ref SystemState state) { }

    [BurstCompile]
    public void OnUpdate(ref SystemState state)
    {
        new PlantRadiusJob().ScheduleParallel();
    }

    [BurstCompile]
    public partial struct PlantRadiusJob : IJobEntity
    {
        public void Execute(
            ref LocalTransform transform, 
            in PlantBaseRadius radius, 
            in PlantRadiusMultiplier radiusMultiplier)
        {
            transform.Scale = 2 * radius.Value * radiusMultiplier.Value;
        }
    }

    [BurstCompile] public void OnDestroy(ref SystemState state) { }
}

using System.Collections;
using System.Collections.Generic;
using Unity.Burst;
using Unity.Entities;
using UnityEngine;
using Unity.Collections;
using Unity.Transforms;

[BurstCompile]
public partial struct PlantRadiusSystem : ISystem
{
    [BurstCompile]
    public void OnCreate(ref SystemState state)
    {
        
    }

    [BurstCompile]
    public void OnDestroy(ref SystemState state)
    {
        
    }

    [BurstCompile]
    public void OnUpdate(ref SystemState state)
    {
        new PlantRadiusJob().ScheduleParallel();
    }

    public partial struct PlantRadiusJob : IJobEntity
    {
        public void Execute(ref LocalTransform transform, in PlantBaseRadius radius, in PlantRadiusMultiplier radiusMultiplier)
        {
            transform.Scale = radius.Value * radiusMultiplier.Value;
        }
    }
}

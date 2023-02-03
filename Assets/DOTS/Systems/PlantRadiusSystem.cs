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
    private EntityQuery query;

    [BurstCompile]
    public void OnCreate(ref SystemState state)
    {
        query = SystemAPI.QueryBuilder().WithAll<PlantType, PlantBaseRadius>().Build();

        state.RequireForUpdate(query);
    }

    [BurstCompile]
    public void OnDestroy(ref SystemState state)
    {
        
    }

    [BurstCompile]
    public void OnUpdate(ref SystemState state)
    {
        var PlantTypes = query.ToComponentDataArray<PlantType>(Unity.Collections.Allocator.TempJob);
        var PlantBaseRadiusArray = query.ToComponentDataArray<PlantBaseRadius>(Unity.Collections.Allocator.TempJob);

        var RadiusByType = new NativeParallelHashMap<int, float>();

        for (int i = 0; i < PlantTypes.Length; i++)
        {
            RadiusByType.Add(PlantTypes[i].Value, PlantBaseRadiusArray[i].Value);
        }



    }

    public partial struct PlantRadiusJob : IJobEntity
    {
        public void Execute(ref LocalTransform transform, in PlantType type, in PlantRadiusMultiplier radiusMultiplier)
        {
            
        }
    }
}

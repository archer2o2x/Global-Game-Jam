using Unity.Burst;
using Unity.Entities;
using Unity.Transforms;
using UnityEngine;

[BurstCompile]
public partial struct PlayerSpawnerSystem : ISystem
{
    [BurstCompile] public void OnCreate(ref SystemState state) { }

    public void OnUpdate(ref SystemState state)
    {
        var pressedKey = -1;

        if(Input.GetKeyDown(KeyCode.Q))
        {
            pressedKey = 0;
        }
        else if (Input.GetKeyDown(KeyCode.W))
        {
            pressedKey = 1;
        }
        else
        {
            return;
        }

        var ray = Camera.main.ScreenPointToRay(Input.mousePosition);

        if (Physics.Raycast(ray, out RaycastHit hit))
        {
            var prefabAmountBuffer = SystemAPI.GetSingletonBuffer<PlayerPlantPrefabAmount>();
            var prefabAmount = prefabAmountBuffer[pressedKey].Value;

            if(prefabAmount > 0)
            {
                var prefabBuffer = SystemAPI.GetSingletonBuffer<PlayerPlantPrefab>();
                var prefab = prefabBuffer[pressedKey].Value;
                var plant = state.EntityManager.Instantiate(prefab);
                state.EntityManager.SetComponentData(plant, LocalTransform.FromPosition(hit.point));
                prefabAmountBuffer[pressedKey] = new PlayerPlantPrefabAmount { Value = prefabAmount - 1 };
            }
        }
    }

    [BurstCompile] public void OnDestroy(ref SystemState state) { }
}

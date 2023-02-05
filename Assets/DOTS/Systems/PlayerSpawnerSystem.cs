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

        if(Input.GetKeyDown(KeyCode.Alpha1))
        {
            pressedKey = 0;
        }
        else if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            pressedKey = 1;
        }
        else
        {
            return;
        }

        var prefabAmountBuffer = SystemAPI.GetSingletonBuffer<PlayerPlantPrefabAmount>();

        if(pressedKey >= prefabAmountBuffer.Length)
        {
            return;
        }

        var ray = Camera.main.ScreenPointToRay(Input.mousePosition);

        if (Physics.Raycast(ray, out RaycastHit hit))
        {
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

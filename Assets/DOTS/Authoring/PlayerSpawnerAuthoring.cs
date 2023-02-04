using Unity.Entities;
using UnityEngine;

public class PlayerSpawnerAuthoring : MonoBehaviour
{
    [SerializeField] private GameObject[] _prefabs;
    [SerializeField] private int[] _amounts;

    public class Baker : Baker<PlayerSpawnerAuthoring>
    {
        public override void Bake(PlayerSpawnerAuthoring authoring)
        {
            var prefabBuffer = AddBuffer<PlayerPlantPrefab>();
            var amountBuffer = AddBuffer<PlayerPlantPrefabAmount>();

            for (int i = 0; i < authoring._prefabs.Length; i++)
            {
                var entityPrefab = GetEntity(authoring._prefabs[i]);
                prefabBuffer.Add(new PlayerPlantPrefab { Value = entityPrefab });
                amountBuffer.Add(new PlayerPlantPrefabAmount { Value = authoring._amounts[i] });
            }
        }
    }
}

using Unity.Entities;
using UnityEngine;

public class ResourceAuthoring : MonoBehaviour
{
    public class ResourceBaker : Baker<ResourceAuthoring>
    {
        public override void Bake(ResourceAuthoring authoring)
        {
            AddComponent<ResourceTag>();
        }
    }
}

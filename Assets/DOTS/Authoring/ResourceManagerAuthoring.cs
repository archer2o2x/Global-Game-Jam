using Unity.Entities;
using UnityEngine;

public class ResourceManagerAuthoring : MonoBehaviour
{
    public float ResourceRatePerSource;

    public class ResourceManagerBaker : Baker<ResourceManagerAuthoring>
    {
        public override void Bake(ResourceManagerAuthoring authoring)
        {
            AddComponent(new ResourceRatePerSource { Value = authoring.ResourceRatePerSource });
        }
    }
}

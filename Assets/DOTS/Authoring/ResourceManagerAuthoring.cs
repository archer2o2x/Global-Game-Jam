using Unity.Entities;
using UnityEngine;

public class ResourceManagerAuthoring : MonoBehaviour
{
    public int Team;

    public int GlobalResourceSources;
    public float ResourceRatePerSource;
    public float TotalTickWeight;
    public float GlobalTickResources;

    public class ResourceManagerBaker : Baker<ResourceManagerAuthoring>
    {
        public override void Bake(ResourceManagerAuthoring authoring)
        {
            AddComponent(new Team { Value = authoring.Team });

            AddComponent(new GlobalResourcesSources { Value = authoring.GlobalResourceSources });
            AddComponent(new ResourceRatePerSource { Value = authoring.ResourceRatePerSource });
            AddComponent(new TotalTickWeight { Value = authoring.TotalTickWeight });
            AddComponent(new GlobalTickResources { Value = authoring.GlobalTickResources });
        }
    }
}

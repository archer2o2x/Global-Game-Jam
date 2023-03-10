using Unity.Entities;
using UnityEngine;

public class TeamDataAuthoring : MonoBehaviour
{
    public int Team;

    public class ResourceManagerBaker : Baker<TeamDataAuthoring>
    {
        public override void Bake(TeamDataAuthoring authoring)
        {
            AddComponent<TeamTag>();
            AddComponent<TeamWeight>();
            AddComponent<TeamResources>();
            AddComponent(new TeamPlantsCount { Value = -1 });
            AddComponent(new Team { Value = authoring.Team });
        }
    }
}

using Unity.Collections;
using Unity.Entities;
using UnityEngine;
using UnityEngine.Events;

public class GameRules : MonoBehaviour
{
    private EntityQuery _teamsQuery;

    public UnityEvent GameWon;
    public UnityEvent GameLost;

    private void Awake()
    {
        var entityManager = World.DefaultGameObjectInjectionWorld.EntityManager;
        _teamsQuery = entityManager.CreateEntityQuery(ComponentType.ReadOnly<TeamPlantsCount>(), ComponentType.ReadOnly<Team>());
    }

    private void Update()
    {
        var teams = _teamsQuery.ToComponentDataArray<Team>(Allocator.Temp);
        var plantsCount = _teamsQuery.ToComponentDataArray<TeamPlantsCount>(Allocator.Temp);

        for (int i = 0; i < teams.Length; i++)
        {
            var team = teams[i].Value;
            var teamPlantsCount = plantsCount[i].Value;

            if(teamPlantsCount == 0)
            {
                //enabled = false;

                if (team == 0)
                {
                    print("lost");
                    GameLost.Invoke();
                    return;
                }

                if (team == 1)
                {
                    print("won");
                    GameWon.Invoke();
                    return;
                }
            }
        }
    }
}

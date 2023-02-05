using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.Entities;
using Unity.Transforms;
using Unity.Mathematics;
using Unity.Collections;
using UnityEngine.UI;
using UnityEngine.Events;

public class UIHandleClick : MonoBehaviour
{
    private EntityQuery Plants;

    public RectTransform PlantWeightingUI;

    public Slider PlantWeightingSlider;

    public float SelectRadius;

    private Entity PlantEntity;

    public Vector3 PlantPosition;

    // Start is called before the first frame update
    void Start()
    {
        Plants = World.DefaultGameObjectInjectionWorld.EntityManager.CreateEntityQuery(typeof(WorldTransform), typeof(Team), typeof(PlantType));

        PlantWeightingSlider.onValueChanged.AddListener(HandleSliderChange);

        PlantPosition = new Vector3(0, 0, -100);
    }

    // Update is called once per frame
    void Update()
    {
        PlantWeightingUI.position = CalculateScreenSpacePos(PlantPosition);

        if (PlantPosition.z == -100) PlantWeightingUI.position = Vector3.left * Screen.width* 8;

        if (!Input.GetMouseButtonDown(0)) return;

        PreprocessClick();
    }

    public void PreprocessClick()
    {
        //if (!(PlantPosition.z == -100)) { return; }

        Ray ClickPosRay = Camera.main.ScreenPointToRay(Input.mousePosition + Vector3.forward * 10);

        RaycastHit info;

        if (!Physics.Raycast(ClickPosRay, out info)) return;

        float3 ClickPosDOTS = new float3(info.point.x, info.point.y, info.point.z);

        var PlantsData = Plants.ToComponentDataArray<WorldTransform>(Unity.Collections.Allocator.Temp);
        var TeamData = Plants.ToComponentDataArray<Team>(Allocator.Temp);

        int IndexOfClosest = 0;
        bool DidFindPlant = false;

        for (int i = 0; i < PlantsData.Length; i++)
        {
            if (TeamData[i].Value != 0) continue;

            if (math.distance(PlantsData[i].Position, ClickPosDOTS) > SelectRadius) continue;

            DidFindPlant = true;

            if (math.distance(PlantsData[i].Position, ClickPosDOTS) < math.distance(PlantsData[IndexOfClosest].Position, ClickPosDOTS)) IndexOfClosest = i;
        }

        if (DidFindPlant)
        {
            HandleClick(new Vector3(PlantsData[IndexOfClosest].Position.x, PlantsData[IndexOfClosest].Position.y, PlantsData[IndexOfClosest].Position.z), Plants.ToEntityArray(Allocator.Temp)[IndexOfClosest]);
        } else
        {
            PlantPosition = new Vector3(0, 0, -100);
        }
    }

    public void HandleClick(Vector3 position, Entity entity)
    {
        PlantEntity = entity;

        PlantPosition = position;

        PlantWeightingSlider.value = World.DefaultGameObjectInjectionWorld.EntityManager.GetComponentData<PlantResourceWeight>(PlantEntity).Value;
    }

    public void HandleSliderChange(float amount)
    {
        int NewPlantWeight = (int)PlantWeightingSlider.value;

        if (!World.DefaultGameObjectInjectionWorld.EntityManager.Exists(PlantEntity)) return;

        World.DefaultGameObjectInjectionWorld.EntityManager.SetComponentData<PlantResourceWeight>(PlantEntity, new PlantResourceWeight { Value = NewPlantWeight });
    }

    public Vector3 CalculateScreenSpacePos(Vector3 position)
    {
        Vector3 result = Camera.main.WorldToScreenPoint(position);

        result.x = Mathf.Clamp(result.x, 20 + PlantWeightingUI.rect.width / 2, Screen.width - (20 + PlantWeightingUI.rect.width / 2));
        result.y = Mathf.Clamp(result.y, 20 + PlantWeightingUI.rect.height / 2, Screen.height - (20 + PlantWeightingUI.rect.height / 2));
        result.z = 0;

        return result;
    }
}

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

    // Start is called before the first frame update
    void Start()
    {
        Plants = World.DefaultGameObjectInjectionWorld.EntityManager.CreateEntityQuery(typeof(WorldTransform), typeof(PlantTag));

        PlantWeightingSlider.onValueChanged.AddListener(HandleSliderChange);
    }

    // Update is called once per frame
    void Update()
    {
        if (!Input.GetMouseButtonDown(0)) return;

        PlantWeightingUI.position = Vector3.left * Screen.width;

        Vector3 ClickPos = Camera.main.ScreenToWorldPoint(Input.mousePosition + Vector3.forward * 10);

        float3 ClickPosDOTS = new float3(ClickPos.x, ClickPos.y, ClickPos.z);

        var PlantsData = Plants.ToComponentDataArray<WorldTransform>(Unity.Collections.Allocator.Temp);

        int IndexOfClosest = 0;

        for (int i = 0; i < PlantsData.Length; i ++)
        {
            if (math.distance(PlantsData[i].Position, ClickPosDOTS) > SelectRadius) continue;

            if (math.distance(PlantsData[i].Position, ClickPosDOTS) < math.distance(PlantsData[IndexOfClosest].Position, ClickPosDOTS)) IndexOfClosest = i;
        }

        HandleClick(new Vector3(PlantsData[IndexOfClosest].Position.x, PlantsData[IndexOfClosest].Position.y, PlantsData[IndexOfClosest].Position.z), Plants.ToEntityArray(Allocator.Temp)[IndexOfClosest]);
    }

    public void HandleClick(Vector3 position, Entity entity)
    {
        Vector3 ScreenSpacePos = CalculateScreenSpacePos(position);

        PlantEntity = entity;

        PlantWeightingUI.position = ScreenSpacePos;

        PlantWeightingSlider.value = World.DefaultGameObjectInjectionWorld.EntityManager.GetComponentData<PlantResourceWeight>(PlantEntity).Value;
    }

    public void HandleSliderChange(float amount)
    {
        int NewPlantWeight = (int)PlantWeightingSlider.value;

        World.DefaultGameObjectInjectionWorld.EntityManager.SetComponentData<PlantResourceWeight>(PlantEntity, new PlantResourceWeight { Value = NewPlantWeight });
    }

    public Vector3 CalculateScreenSpacePos(Vector3 position)
    {
        Vector3 result = Camera.main.WorldToScreenPoint(position);

        result.x = Mathf.Clamp(result.x, 20 + PlantWeightingUI.rect.width / 2, Screen.width - (20 + PlantWeightingUI.rect.width / 2));
        result.y = Mathf.Clamp(result.y, 20 + PlantWeightingUI.rect.height / 2, Screen.height - (20 + PlantWeightingUI.rect.height / 2));

        return result;
    }

    private void OnDestroy()
    {
        Plants.Dispose();
    }
}

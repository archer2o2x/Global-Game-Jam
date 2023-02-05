using UnityEngine;

public class GraphicsPrefabs : MonoBehaviour
{
    public static GraphicsPrefabs Instance { get; private set; }

    [SerializeField] GameObject[] _prefabs;

    private void Awake()
    {
        Instance = this;
    }

    public GameObject GetPrefab(int plantType)
    {
        return _prefabs[plantType];
    }
}

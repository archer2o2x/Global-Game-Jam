using UnityEngine;

public class ArtReferences : MonoBehaviour
{
    public static ArtReferences Instance { get; private set; }

    private AudioSource _spawnSource;
    private AudioSource _despawnSource;

    [SerializeField] private GameObject[] _prefabs;
    [SerializeField] private AudioClip _spawnSound;
    [SerializeField] private AudioClip _despawnSound;

    private void Awake()
    {
        Instance = this;
        _spawnSource = gameObject.AddComponent<AudioSource>();
        _spawnSource.clip = _spawnSound;

        _despawnSource = gameObject.AddComponent<AudioSource>();
        _despawnSource.clip = _despawnSound;
    }

    public GameObject GetPlantGraphicPrefab(int plantType)
    {
        return _prefabs[plantType];
    }

    public void PlaySpawn()
    {
        _spawnSource.Play();
    }

    public void PlayDespawn()
    {
        _despawnSource.Play();
    }
}
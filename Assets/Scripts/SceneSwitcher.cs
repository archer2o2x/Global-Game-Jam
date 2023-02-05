using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneSwitcher : MonoBehaviour
{
    public void GotoScene(Scenes NewScene)
    {
        SceneManager.LoadScene(NewScene.ToString());
    }

    public void GotoScene(string NewScene)
    {
        SceneManager.LoadScene(NewScene);
    }

    public void ReloadScene()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }

    public enum Scenes
    {
        MainMenu,
        Credits,
        Controls,
        Level01,
        Level02,
        Level03,
        Level04
    }
}

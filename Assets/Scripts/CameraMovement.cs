using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMovement : MonoBehaviour
{
    public Transform Camera;
    public float CameraMoveSpeed;
    public float CameraScrollSpeed;

    // Update is called once per frame
    void LateUpdate()
    {

        var hori = Input.GetAxis("Horizontal");
        var vert = Input.GetAxis("Vertical");

        var scroll = Input.GetAxis("Mouse ScrollWheel");

        Camera.position += new Vector3(hori, 0, vert) * CameraMoveSpeed * Time.deltaTime;
        Camera.position += new Vector3(0, scroll, 0) * CameraScrollSpeed * Time.deltaTime;

    }
}

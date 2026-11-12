class Camera {
    PVector position = new PVector(0, 0);
    float speed = 10.0;
    float zoom = 100.0;   // How many pixels in a meter.
    float min_zoom = 1.0;
    float max_zoom = 10000.0;
}



void CameraKeyboardInput(Camera camera, KeyboardState state) {
    PVector direction = InputWASDAsVector(state);
    camera.position.add(direction.normalize().mult(camera.speed * 100 / camera.zoom));
}


void CameraMouseInput(Camera camera, float mouse_wheel_value) {
    if (mouse_wheel_value < 0) {
        camera.zoom *= 1.05;
    } else if (mouse_wheel_value > 0) {
        camera.zoom *= 0.95;
    }
    
    if (camera.zoom < camera.min_zoom) {
        camera.zoom = camera.min_zoom;
    } else if (camera.zoom > camera.max_zoom) {
        camera.zoom = camera.max_zoom;
    }
}

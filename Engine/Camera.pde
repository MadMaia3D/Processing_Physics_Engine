class Camera {
    PVector position = new PVector(0, 0);
    float speed = 5.0;
    float zoom = 100.0;   // 100.0 means a meter will be display as 100 pixels
    float min_zoom = 10.0;
    float max_zoom = 1000.0;
}


void CameraKeyboardInput(Camera camera, KeyboardState state) {
    PVector direction = new PVector(0, 0);
    if (state.a) {
        direction.x -= 1.0;
    }
    if (state.d) {
        direction.x += 1.0;
    }
    if (state.w) {
        direction.y += 1.0;
    }
    if (state.s) {
        direction.y -= 1.0;
    }
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

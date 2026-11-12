class MouseState {
    PVector position = new PVector(0, 0);
    PVector last = new PVector(0, 0);
}


void UpdateMousePosition (MouseState mouse) {
    mouse.last.set(mouse.position.x, mouse.position.y);
    mouse.position.set(mouseX, mouseY);
}


PVector GetMouseDeltaPosition (MouseState mouse) {
    return PVector.sub(mouse.position, mouse.last);
}

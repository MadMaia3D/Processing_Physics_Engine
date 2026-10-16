class KeyboardState {
    boolean w = false;
    boolean a = false;
    boolean s = false;
    boolean d = false;
    boolean left = false;
    boolean right = false;
    boolean up = false;
    boolean down = false;
}


void UpdateKeyboardKey(KeyboardState keyboard, int keyCode, boolean value) {
    switch(keyCode) {
    case 'A':
        keyboard.a = value;
        break;
    case 'D':
        keyboard.d = value;
        break;
    case 'W':
        keyboard.w = value;
        break;
    case 'S':
        keyboard.s = value;
        break;
    case LEFT:
        keyboard.left = value;
        break;
    case RIGHT:
        keyboard.right = value;
        break;
    case UP:
        keyboard.up = value;
        break;
    case DOWN:
        keyboard.down = value;
        break;
    }
}


PVector ArrowsInputAsVector(KeyboardState state) {
    PVector direction = new PVector(0, 0);
    if (state.left) {
        direction.x -= 1.0;
    }
    if (state.right) {
        direction.x += 1.0;
    }
    if (state.up) {
        direction.y += 1.0;
    }
    if (state.down) {
        direction.y -= 1.0;
    }
    return direction;
}

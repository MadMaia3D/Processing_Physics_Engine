class KeyboardState {
    boolean w = false;
    boolean a = false;
    boolean s = false;
    boolean d = false;
    boolean left = false;
    boolean right = false;
    boolean up = false;
    boolean down = false;
    boolean shift = false;
    boolean space = false;
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
    case SHIFT:
        keyboard.shift = value;
        break;
    case ' ':
        keyboard.space = value;
        break;
    }
}


PVector InputArrowsAsVector(KeyboardState state) {
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

PVector InputWASDAsVector(KeyboardState state) {
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
    return direction;
}

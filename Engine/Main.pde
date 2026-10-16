Camera camera = new Camera();
KeyboardState keyboard = new KeyboardState();
Body[] circles;


void mouseWheel(MouseEvent event) {
    float e = event.getCount();
    CameraMouseInput(camera, e);
}

void keyPressed() {
    UpdateKeyboardKey(keyboard, keyCode, true);
}

void keyReleased() {
    UpdateKeyboardKey(keyboard, keyCode, false);
}


void setup() {
    size(1280, 720);
    frameRate(60);

    circles = new Body[10];
    colorMode(HSB, 360, 100, 100);
    for (int i = 0; i < circles.length; i++) {
        float x = random(-5, 5);
        float y = random(-3, 3);
        float radius = random(0.2, 0.4);
        circles[i] = CreateCircleBody(new PVector(x, y), radius);
        circles[i].display_color = color(random(0, 360), 50, 100);
    }
    colorMode(RGB, 255, 255, 255);
}


void draw() {
    CameraKeyboardInput(camera, keyboard);

    PVector arrows_direction = ArrowsInputAsVector(keyboard);
    circles[0].position.add(arrows_direction.normalize().mult(0.03));

    background(16);

    translate(-camera.position.x, camera.position.y);
    translate(width/2, height/2);
    scale(camera.zoom * 100, -camera.zoom * 100);

    for (int i = 0; i < circles.length - 1; i++) {
        for (int j = i + 1; j < circles.length; j++) {
            SolveCircleCollision(circles[i], circles[j]);
        }
        DrawBody(circles[i]);
    }

    resetMatrix();
}

Camera camera = new Camera();
KeyboardState keyboard = new KeyboardState();
Body[] polygons;

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

    colorMode(HSB, 360, 100, 100);

    polygons = new Body[10];
    for (int i = 0; i < polygons.length; i++) {
        float x = random(-5, 5);
        float y = random(-3, 3);
        PVector[] poly_model = CreateRegularPolygonModel((int)random(3, 8), 0.5);
        polygons[i] = CreatePolyBody(new PVector(x, y), poly_model);
        polygons[i].display_color = color(random(0, 360), 50, 100);
        polygons[i].rotation = random(-PI, PI);
    }
    colorMode(RGB, 255, 255, 255);
}


void draw() {
    if (keyboard.space) {
        CameraKeyboardInput(camera, keyboard);
    } else {
        PVector arrows_direction = InputWASDAsVector(keyboard);
        float travel_speed = keyboard.shift ? 0.05 : 0.01;
        polygons[0].position.add(arrows_direction.normalize().mult(travel_speed));
    }


    if (keyPressed) {
        float angle = 0.0;
        if (key == 'q') {
            angle = 0.02;
        } else if (key == 'e') {
            angle = -0.02;
        }
        for (int i = 0; i < polygons.length; i++) {
            polygons[i].rotation += angle;
        }
    }

    // --------------------- Drawing ---------------------
    translate(width/2, height/2);
    scale(camera.zoom, -camera.zoom);
    translate(-camera.position.x / 100, -camera.position.y / 100);

    background(32);

    for (int i = 0; i < polygons.length - 1; i++) {
        for (int j = i + 1; j < polygons.length; j++) {
            SolveCollision(polygons[i], polygons[j]);
        }
    }

    for (int i = 0; i < polygons.length; i++) {
        fill(polygons[i].display_color);
        DrawBody(polygons[i]);
    }

    resetMatrix();
    stroke(255, 16);
    strokeWeight(1);

    line(0, height/2, width, height/2);
    line(width/2, 0, width/2, height);
}

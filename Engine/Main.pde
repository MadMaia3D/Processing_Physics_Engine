Camera camera = new Camera();
KeyboardState keyboard = new KeyboardState();
//Body[] circles;
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

    //circles = new Body[10];
    //for (int i = 0; i < circles.length; i++) {
    //    float x = random(-5, 5);
    //    float y = random(-3, 3);
    //    float radius = random(0.2, 0.4);
    //    circles[i] = CreateCircleBody(new PVector(x, y), radius);
    //    circles[i].display_color = color(random(0, 360), 50, 100);
    //}

    PVector[] poly_model = CreateRegularPolygonModel(5, 0.5, 1.0);
    polygons = new Body[15];
    for (int i = 0; i < polygons.length; i++) {
        float x = random(-5, 5);
        float y = random(-3, 3);
        polygons[i] = CreatePolyBody(new PVector(x, y), poly_model);
        polygons[i].display_color = color(random(0, 360), 50, 100);
        polygons[i].rotation = random(-PI, PI);
        polygons[i].scale = random(0.2, 0.5);
    }
    colorMode(RGB, 255, 255, 255);
}


void draw() {
    CameraKeyboardInput(camera, keyboard);

    PVector arrows_direction = ArrowsInputAsVector(keyboard);
    //circles[0].position.add(arrows_direction.normalize().mult(0.03));
    polygons[0].position.add(arrows_direction.normalize().mult(0.01));

    background(16);

    translate(width/2, height/2);
    scale(camera.zoom, -camera.zoom);
    translate(-camera.position.x / 100, -camera.position.y / 100);

    //for (int i = 0; i < circles.length - 1; i++) {
    //    for (int j = i + 1; j < circles.length; j++) {
    //        SolveCollision(circles[i], circles[j]);
    //    }
    //    DrawBody(circles[i]);
    //}

    if (keyPressed) {
        float angle = 0.0;
        if (key == 'q') {
            angle = 0.01;
        } else if (key == 'e') {
            angle = -0.01;
        }
        for (int i = 1; i < polygons.length; i++) {
            polygons[i].rotation += angle;
        }
    }

    for (int i = 0; i < polygons.length; i++) {
        fill(polygons[i].display_color);
        for (int j = 0; j < polygons.length; j++) {
            if ((i != j) && SolveCollision(polygons[i], polygons[j])) {
                fill(255, 0, 0);
            }
        }
        DrawBody(polygons[i]);
    }
    resetMatrix();
    stroke(255, 16);
    strokeWeight(1);
    line(0, height/2, width, height/2);
    line(width/2, 0, width/2, height);
}

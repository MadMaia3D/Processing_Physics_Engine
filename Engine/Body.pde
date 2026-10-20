enum BodyShapeType {
    CIRCLE, RECTANGLE, POLY
};

class Body {
    PVector position = new PVector(0, 0);
    PVector linear_velocity = new PVector(0, 0);
    float rotation = 0.0;
    float angular_velocity = 0.0;
    float scale = 1.0;

    BodyShapeType display_shape = BodyShapeType.CIRCLE;
    PVector[] vertices;
    float radius = 0.5;
    float width = 1.0;
    float height = 1.0;

    color display_color = color(255);

    //float density;
    //float mass;
    //float area;
    //float restitution; // how bouncy
    //boolean is_static;
}

// -------------------------------- Draw Functions --------------------------------
void DrawBody(Body body) {
    pushMatrix();
    translate(body.position.x, body.position.y);
    rotate(body.rotation);
    scale(body.scale);

    noStroke();
    //fill(body.display_color);

    switch(body.display_shape) {
    case CIRCLE:
        ellipseMode(RADIUS);
        ellipse(0, 0, body.radius, body.radius);
        break;
    case RECTANGLE:
        rectMode(CENTER);
        rect(0, 0, body.width, body.height);
        break;
    case POLY:
        beginShape();
        for (int i = 0; i < body.vertices.length; i++) {
            vertex(body.vertices[i].x, body.vertices[i].y);
        }
        endShape();
        break;
    }
    popMatrix();
}

// -------------------------------- Body Creation Functions --------------------------------
Body CreateCircleBody(PVector position, float radius) {
    Body circle = new Body();
    circle.position = position;
    circle.radius = radius;
    circle.display_shape = BodyShapeType.CIRCLE;
    return circle;
}


Body CreateRectBody(PVector position, float width, float height) {
    Body rectangle = new Body();
    rectangle.position = position;
    rectangle.width = width;
    rectangle.height = height;
    rectangle.display_shape = BodyShapeType.RECTANGLE;
    return rectangle;
}


Body CreatePolyBody(PVector position, PVector[] vertices) {
    Body poly_shape = new Body();
    poly_shape.position = position;
    poly_shape.vertices = vertices;
    poly_shape.display_shape = BodyShapeType.POLY;

    return poly_shape;
}

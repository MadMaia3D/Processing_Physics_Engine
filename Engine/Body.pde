enum BodyShapeType {
    CIRCLE, RECTANGLE, POLY
};

class Body {
    PVector position = new PVector(0, 0);
    PVector linear_velocity = new PVector(0, 0);
    float rotation = 0.0;
    float angular_velocity = 0.0;

    //float density;
    //float mass;
    //float area;
    //float restitution; // how bouncy
    //boolean is_static;

    BodyShapeType display_shape = BodyShapeType.CIRCLE;
    float radius = 0.5;
    float width = 1.0;
    float height = 1.0;

    color display_color = color(255);
}

// -------------------------------- Draw Functions -------------------------------- 
void DrawBody(Body body) {
    pushMatrix();
    translate(body.position.x, body.position.y);
    rotate(body.rotation);
    
    noStroke();
    fill(body.display_color);

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

// -------------------------------- Collision Functions -------------------------------- 
boolean CheckCircleCollision(Body body1, Body body2) {
    float distance_squared = PVector.sub(body1.position, body2.position).magSq();
    float radius_sum = body1.radius + body2.radius;
    return distance_squared < radius_sum * radius_sum;
}


boolean SolveCircleCollision(Body body1, Body body2) {
    float distance_squared = PVector.sub(body1.position, body2.position).magSq();
    float radius_sum = body1.radius + body2.radius;

    if (distance_squared > radius_sum * radius_sum) {
        return false;
    }
    
    PVector collision_normal = PVector.sub(body1.position, body2.position).normalize();
    float distance = sqrt(distance_squared);
    float overlap_width = radius_sum - distance;

    body1.position.add(PVector.mult(collision_normal, overlap_width/2));
    body2.position.sub(PVector.mult(collision_normal, overlap_width/2));
    
    return true;
}


boolean SolveCollision(Body body1, Body body2) {
    if (body1.display_shape == BodyShapeType.CIRCLE && body2.display_shape == BodyShapeType.CIRCLE) {
        return SolveCircleCollision(body1, body2);
    }
    return false;
}

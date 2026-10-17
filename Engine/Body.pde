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

// -------------------------------- Utility Functions --------------------------------
PVector[] GetTransformedModel(Body body) {
    PVector[] model_copy = new PVector[body.vertices.length];
    for (int i = 0; i < model_copy.length; i++) {
        model_copy[i] = body.vertices[i].copy();
        model_copy[i] = model_copy[i].mult(body.scale);
        model_copy[i] = model_copy[i].rotate(body.rotation);
        model_copy[i] = model_copy[i].add(body.position);
    }
    return model_copy;
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


// Uses SAT to solve polygons projection
boolean CheckPolyCollision(Body body_A, Body body_B) {
    PVector[] model_A = GetTransformedModel(body_A);
    PVector[] model_B = GetTransformedModel(body_B);    

    // Use the normals of the models as projection axis
    for (int model = 0; model < 2; model++) {
        PVector[] current_model = (model == 0) ? model_A : model_B;
        for (int edge = 0; edge < current_model.length; edge++) {
            int index_1 = edge;
            int index_2 = (edge + 1) % current_model.length;

            PVector v1 = current_model[index_1].copy();
            PVector v2 = current_model[index_2].copy();

            // Edge vetor to false normal (not normalized normal vector);
            PVector edge_vector = PVector.sub(v2, v1);
            PVector projection_axis = new PVector(-edge_vector.y, edge_vector.x);

            // After getting the projection axis
            // Loop through all models vertices
            // Recording for each model, its min and max values along the axis

            float a_min = model_A[0].dot(projection_axis);
            float a_max = a_min;

            for (int j = 1; j < model_A.length; j++) {
                float dot = model_A[j].dot(projection_axis);
                a_min = min(a_min, dot);
                a_max = max(a_max, dot);
            }

            float b_min = model_B[0].dot(projection_axis);
            float b_max = b_min;

            for (int j = 1; j < model_B.length; j++) {
                float dot = model_B[j].dot(projection_axis);
                b_min = min(b_min, dot);
                b_max = max(b_max, dot);
            }

            // Now when check if the one dimensional projection of model_A
            // collides with the one dimensional projection of model_B
            if (a_max < b_min || a_min > b_max) {
                return false;
            }
        }
    }
    // If there collision on all axis, this means that the two shapes are colliding
    return true;
}


boolean SolveCollision(Body body1, Body body2) {
    BodyShapeType shape_A = body1.display_shape;
    BodyShapeType shape_B = body2.display_shape;
    if (shape_A == BodyShapeType.CIRCLE && shape_B == BodyShapeType.CIRCLE) {
        return SolveCircleCollision(body1, body2);
    } else if (shape_A == BodyShapeType.POLY && shape_B == BodyShapeType.POLY) {
        return CheckPolyCollision(body1, body2);
    }
    return false;
}

// -------------------------------- Model Functions --------------------------------
PVector[] CreateRectModel(float width, float height) {
    float half_width = width/2;
    float half_height = height/2;
    PVector[] rect_model = new PVector[4];
    rect_model[0] = new PVector(-half_width, half_height);
    rect_model[1] = new PVector(half_width, half_height);
    rect_model[2] = new PVector(half_width, -half_height);
    rect_model[3] = new PVector(-half_width, -half_height);
    return rect_model;
}

PVector[] CreateSquareModel(float size) {
    return CreateRectModel(size, size);
}


PVector[] CreateRegularPolygonModel(int sides, float width, float height) {
    PVector[] output = new PVector[sides];
    float radians_step = TWO_PI / sides;

    for (int i = 0; i < output.length; i++) {
        output[i] = new PVector(0, 1).rotate(radians_step * i);
        output[i].x = output[i].x * width;
        output[i].y = output[i].y * height;
    }
    return output;
}


PVector[] CreateRegularPolygonModel(int sides, float radius) {
    return CreateRegularPolygonModel(sides, radius, radius);
}

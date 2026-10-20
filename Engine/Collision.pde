// -------------------------------- Shapes Overlap Checks --------------------------------
boolean CheckCircleOverlap(Body body1, Body body2) {
    float distance_squared = PVector.sub(body1.position, body2.position).magSq();
    float radius_sum = body1.radius + body2.radius;
    return distance_squared < radius_sum * radius_sum;
}


class CollisionInfo {
    PVector normal;
    float depth;
}

// Uses SAT to solve collision between polygon models
boolean CheckPolysOverlap(Body body_A, Body body_B, CollisionInfo out) {
    PVector[] model_A = GetTransformedModel(body_A);
    PVector[] model_B = GetTransformedModel(body_B);
    out.normal = new PVector(0, 0);
    out.depth = Float.MAX_VALUE;

    // Use the normals of the models as projection axis
    for (int model = 0; model < 2; model++) {
        PVector[] current_model = (model == 0) ? model_A : model_B;
        for (int current_vertex = 0; current_vertex < current_model.length; current_vertex++) {
            int index_1 = current_vertex;
            int index_2 = (current_vertex + 1) % current_model.length;

            PVector v1 = current_model[index_1].copy();
            PVector v2 = current_model[index_2].copy();

            // Edge vetor to normal;
            PVector edge_vector = PVector.sub(v2, v1);
            PVector projection_axis = new PVector(-edge_vector.y, edge_vector.x).normalize();

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
            // If not, this means that the two objects aren't colliding
            if (a_max < b_min || b_max < a_min) {
                return false;
            }

            // abs function called for account for the signal of the depth
            //float depth = min(a_max - b_min, b_max - a_min);
            float depth_1 = a_max - b_min;
            float depth_2 = a_min - b_max;
            float final_depth = depth_1;
            if (abs(depth_1) > abs(depth_2)) {
                final_depth = depth_2;
            }

            // If the depth is the smallest ever encountered, store it in the output CollisionInfo
            if (abs(final_depth) < abs(out.depth)) {
                out.depth = final_depth;
                out.normal = projection_axis;
            }
        }
    }
    // If there is collision on all axis, this means that the two shapes are colliding
    return true;
}


// Uses SAT to solve collision between a polygon and a circle
boolean CheckPolyCircleOverlap(Body poly_body, Body circle, CollisionInfo out) {
    PVector[] poly_model = GetTransformedModel(poly_body);
    out.normal = new PVector(0, 0);
    out.depth = Float.MAX_VALUE;

    // Use the normals of the model as projection axis
    for (int i = 0; i < poly_model.length; i++) {
        int index0 = i;
        int index1 = (i + 1) % poly_model.length;

        PVector vertex0 = poly_model[index0];
        PVector vertex1 = poly_model[index1];

        // Edge vetor to normal;
        PVector edge_vector = PVector.sub(vertex0, vertex1);
        PVector projection_axis = new PVector(-edge_vector.y, edge_vector.x).normalize();

        // After getting the projection axis
        // Loop through all models vertices
        // Recording for each model, its min and max values along the axis
        float a_min = poly_model[0].dot(projection_axis);
        float a_max = a_min;

        for (int j = 1; j < poly_model.length; j++) {
            float dot = poly_model[j].dot(projection_axis);
            a_min = min(a_min, dot);
            a_max = max(a_max, dot);
        }

        // Project the circle center then add/subtract the radius to find the circle max and min projections
        float projected_center = circle.position.dot(projection_axis);
        float b_max = projected_center + circle.radius;
        float b_min = projected_center - circle.radius;

        // Now when check if the one dimensional projection of model_A
        // collides with the one dimensional projection of model_B
        // If not, this means that the two objects aren't colliding
        if (a_max < b_min || b_max < a_min) {
            return false;
        }

        // abs function called for account for the signal of the depth
        //float depth = min(a_max - b_min, b_max - a_min);
        float depth_1 = a_max - b_min;
        float depth_2 = a_min - b_max;
        float final_depth = depth_1;
        if (abs(depth_1) > abs(depth_2)) {
            final_depth = depth_2;
        }

        // If the depth is the smallest ever encountered, store it in the output CollisionInfo
        if (abs(final_depth) < abs(out.depth)) {
            out.depth = final_depth;
            out.normal = projection_axis;
        }
    }

    // Find the poly nearest vertex to circle
    int nearest_vertex_index = 0;
    float nearest_distance_squared = PVector.sub(circle.position, poly_model[0]).magSq();
    for (int i = 1; i < poly_model.length; i++) {
        float current_distance_squared = PVector.sub(circle.position, poly_model[i]).magSq();
        if (current_distance_squared < nearest_distance_squared) {
            nearest_distance_squared = current_distance_squared;
            nearest_vertex_index = i;
        }
    }
    PVector nearest_vertex = poly_model[nearest_vertex_index];
    PVector to_nearest_vector = PVector.sub(nearest_vertex, circle.position);
    PVector projection_axis = new PVector(-to_nearest_vector.y, to_nearest_vector.x).normalize();
    // Use the vertor of the circle as projection axis
    // After getting the projection axis
    // Loop through all models vertices
    // Recording for each model, its min and max values along the axis
    float a_min = poly_model[0].dot(projection_axis);
    float a_max = a_min;

    for (int j = 1; j < poly_model.length; j++) {
        float dot = poly_model[j].dot(projection_axis);
        a_min = min(a_min, dot);
        a_max = max(a_max, dot);
    }

    // Project the circle center then add/subtract the radius to find the circle max and min projections
    float projected_center = circle.position.dot(projection_axis);
    float b_max = projected_center + circle.radius;
    float b_min = projected_center - circle.radius;

    // Now when check if the one dimensional projection of model_A
    // collides with the one dimensional projection of model_B
    // If not, this means that the two objects aren't colliding
    if (a_max < b_min || b_max < a_min) {
        return false;
    }

    // abs function called for account for the signal of the depth
    //float depth = min(a_max - b_min, b_max - a_min);
    float depth_1 = a_max - b_min;
    float depth_2 = a_min - b_max;
    float final_depth = depth_1;
    if (abs(depth_1) > abs(depth_2)) {
        final_depth = depth_2;
    }

    // If the depth is the smallest ever encountered, store it in the output CollisionInfo
    if (abs(final_depth) < abs(out.depth)) {
        out.depth = final_depth;
        out.normal = projection_axis;
    }


    // If there is collision on all axis, this means that the two shapes are colliding
    return true;
}


// -------------------------------- Collision --------------------------------

boolean CollideCircles(Body body1, Body body2) {
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


boolean CollidePolys(Body body1, Body body2) {
    CollisionInfo collision = new CollisionInfo();
    boolean collided = CheckPolysOverlap(body1, body2, collision);
    if (collided) {
        body1.position.add(PVector.mult(collision.normal, -collision.depth/2));
        body2.position.add(PVector.mult(collision.normal, collision.depth/2));
    }
    return collided;
}


boolean CollidePolyWithCircle(Body poly_body, Body circle_body) {
    CollisionInfo collision = new CollisionInfo();
    boolean collided = CheckPolyCircleOverlap(poly_body, circle_body, collision);
    if (collided) {
        poly_body.position.add(PVector.mult(collision.normal, -collision.depth/2));
        circle_body.position.add(PVector.mult(collision.normal, collision.depth/2));
    }
    return false;
}


boolean SolveCollision(Body body1, Body body2) {
    BodyShapeType shape1 = body1.display_shape;
    BodyShapeType shape2 = body2.display_shape;
    if (shape1 == BodyShapeType.CIRCLE && shape2 == BodyShapeType.CIRCLE) {
        return CollideCircles(body1, body2);
    } else if (shape1 == BodyShapeType.POLY && shape2 == BodyShapeType.POLY) {
        return CollidePolys(body1, body2);
    } else if (shape1 == BodyShapeType.CIRCLE && shape2 == BodyShapeType.POLY) {
        return CollidePolyWithCircle(body2, body1);
    } else if (shape1 == BodyShapeType.POLY && shape2 == BodyShapeType.CIRCLE) {
        return CollidePolyWithCircle(body1, body2);
    }
    return false;
}

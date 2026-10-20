// -------------------------------- SAT Utility --------------------------------
class ProjectionMinMax {
    float min;
    float max;
}


ProjectionMinMax SATGetPolyProjectionMinMax(PVector[] model_to_project, PVector projection_axis) {
    ProjectionMinMax out = new ProjectionMinMax();
    out.min = model_to_project[0].dot(projection_axis);
    out.max = out.min;

    for (int j = 1; j < model_to_project.length; j++) {
        float dot = model_to_project[j].dot(projection_axis);
        out.min = min(out.min, dot);
        out.max = max(out.max, dot);
    }
    return out;
}


ProjectionMinMax SATGetCircleProjectionMinMax(PVector circle_center, float radius, PVector projection_axis) {
    // Project the circle center then add/subtract the radius to find the circle max and min projections
    ProjectionMinMax out = new ProjectionMinMax();
    float projected_center = circle_center.dot(projection_axis);
    out.max = projected_center + radius;
    out.min = projected_center - radius;
    return out;
}

boolean SATCheckProjectionsCollision(ProjectionMinMax proj1, ProjectionMinMax proj2) {
    return !(proj1.max < proj2.min || proj1.min > proj2.max);
}


float SATGetProjectionsCollisionDepth(ProjectionMinMax proj1, ProjectionMinMax proj2) {
    float depth_1 = proj1.max - proj2.min;
    float depth_2 = proj1.min - proj2.max;
    float final_depth = depth_1;
    if (abs(depth_1) > abs(depth_2)) {
        final_depth = depth_2;
    }
    return final_depth;
}


PVector SATFindNearestVertexToCircle(PVector circle_center, PVector[] vertices) {
    // Find the poly nearest vertex to circle
    int nearest_vertex_index = 0;
    float nearest_distance_squared = PVector.sub(circle_center, vertices[0]).magSq();
    for (int i = 1; i < vertices.length; i++) {
        float current_distance_squared = PVector.sub(circle_center, vertices[i]).magSq();
        if (current_distance_squared < nearest_distance_squared) {
            nearest_distance_squared = current_distance_squared;
            nearest_vertex_index = i;
        }
    }
    return vertices[nearest_vertex_index];
}

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

            // Get the maximum and minimum values for projections
            ProjectionMinMax proj_A = SATGetPolyProjectionMinMax(model_A, projection_axis);
            ProjectionMinMax proj_B = SATGetPolyProjectionMinMax(model_B, projection_axis);

            // Check collision between projections
            boolean colliding = SATCheckProjectionsCollision(proj_A, proj_B);
            if (!colliding) {
                return false;
            }

            // If the collision depth is the smallest ever encountered, store it in the output CollisionInfo
            float final_depth = SATGetProjectionsCollisionDepth(proj_A, proj_B);
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

        // Get the maximum and minimum values for the projections of each shape
        ProjectionMinMax poly_proj = SATGetPolyProjectionMinMax(poly_model, projection_axis);
        ProjectionMinMax circle_proj = SATGetCircleProjectionMinMax(circle.position, circle.radius, projection_axis);

        // Check for collision between the two projections
        // If neither projection collides, the two objects aren't colliding
        boolean colliding = SATCheckProjectionsCollision(poly_proj, circle_proj);
        if (!colliding) {
            return false;
        }

        // If the depth is the smallest ever encountered, store it in the output CollisionInfo
        float final_depth = SATGetProjectionsCollisionDepth(poly_proj, circle_proj);
        if (abs(final_depth) < abs(out.depth)) {
            out.depth = final_depth;
            out.normal = projection_axis;
        }
    }

    // Do a extra projection but using the axis between the circle and nearest vertex as the projection vector
    PVector nearest_vertex = SATFindNearestVertexToCircle(circle.position, poly_model);
    PVector to_nearest_vector = PVector.sub(nearest_vertex, circle.position);

    PVector projection_axis = new PVector(-to_nearest_vector.y, to_nearest_vector.x).normalize();

    ProjectionMinMax poly_proj = SATGetPolyProjectionMinMax(poly_model, projection_axis);
    ProjectionMinMax circle_proj = SATGetCircleProjectionMinMax(circle.position, circle.radius, projection_axis);

    boolean colliding = SATCheckProjectionsCollision(poly_proj, circle_proj);
    if (!colliding) {
        return false;
    }

    float final_depth = SATGetProjectionsCollisionDepth(poly_proj, circle_proj);
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

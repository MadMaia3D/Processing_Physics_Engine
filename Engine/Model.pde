// A model is just an array of PVectors to represent the vertices of a arbitrary shape

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
        output[i].x = output[i].x * (width/2);
        output[i].y = output[i].y * (height/2);
    }
    return output;
}


PVector[] CreateRegularPolygonModel(int sides, float radius) {
    return CreateRegularPolygonModel(sides, radius * 2, radius * 2);
}

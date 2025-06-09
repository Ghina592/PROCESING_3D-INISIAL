PFont font;
PShape glyphG, glyphD, glyphA;
float depth = 30;

// Rotation
float rotX = 0, rotY = 0, rotZ = 0;
float autoRotateSpeedX = 0.01;
float autoRotateSpeedY = 0.01;
float autoRotateSpeedZ = 0.0;
boolean autoRotateEnabled = true;

// Camera position
float zoom = 400;
float camX = 0, camY = 0;

// Light source
float lightX = 0, lightY = 0, lightZ = 200;
boolean pointLightMode = true;

// Texture toggle
boolean textureEnabled = true;

void setup() {
  size(800, 600, P3D);
  font = createFont("Arial", 200, true);
  glyphG = createExtrudedGlyph('G', font, depth);
  glyphD = createExtrudedGlyph('D', font, depth);
  glyphA = createExtrudedGlyph('A', font, depth);
}

void draw() {
  background(50);

  // Lighting
  if (pointLightMode) {
    pointLight(255, 255, 255, width/2 + lightX, height/2 + lightY, lightZ);
  } else {
    directionalLight(255, 255, 255, 0, -1, -1);
  }

  // Auto rotate update
  if (autoRotateEnabled) {
    rotX += autoRotateSpeedX;
    rotY += autoRotateSpeedY;
    rotZ += autoRotateSpeedZ;
  }

  // Apply transform
  translate(width/2 + camX, height/2 + camY, -zoom);
  rotateX(rotX);
  rotateY(rotY);
  rotateZ(rotZ);

  // Apply texture or default lights
  if (textureEnabled) {
    ambientLight(60, 60, 60);
    specular(255, 255, 255);
    shininess(10.0);
  } else {
    lights();
  }

  // Draw letters
  float spacing = 160;

  pushMatrix();
  translate(-spacing, 0, 0);
  shape(glyphG);
  popMatrix();

  pushMatrix();
  translate(0, 0, 0);
  shape(glyphD);
  popMatrix();

  pushMatrix();
  translate(spacing, 0, 0);
  shape(glyphA);
  popMatrix();

  // Show controls HUD
  showHUD();
}

void keyPressed() {
  // Rotation manual
  if (key == 'w') rotX -= 0.05;
  if (key == 's') rotX += 0.05;
  if (key == 'a') rotY -= 0.05;
  if (key == 'd') rotY += 0.05;
  if (key == 'q') rotZ -= 0.05;
  if (key == 'e') rotZ += 0.05;

  // Camera move
  if (key == 'j') camX -= 10;
  if (key == 'l') camX += 10;
  if (key == 'i') camY -= 10;
  if (key == 'k') camY += 10;

  // Zoom
  if (key == '+') zoom -= 20;
  if (key == '-') zoom += 20;

  // Texture toggle
  if (key == 't' || key == 'T') textureEnabled = !textureEnabled;

  // Light move
  if (key == 'u') lightX -= 10;
  if (key == 'o') lightX += 10;
  if (key == 'm') lightY -= 10;
  if (key == '.') lightY += 10;
  if (key == 'z') lightZ -= 10;
  if (key == 'x') lightZ += 10;

  // Light mode toggle
  if (key == 'l' || key == 'L') pointLightMode = !pointLightMode;

  // Auto rotate toggle
  if (key == 'r' || key == 'R') autoRotateEnabled = !autoRotateEnabled;
}

PShape createExtrudedGlyph(char c, PFont font, float depth) {
  PShape glyph2D = font.getShape(c);
  glyph2D.disableStyle();

  ArrayList<PVector> frontVertices = new ArrayList<PVector>();
  int vertexCount = glyph2D.getVertexCount();
  for (int i = 0; i < vertexCount; i++) {
    PVector v = glyph2D.getVertex(i);
    frontVertices.add(v.copy());
  }

  PShape extruded = createShape(GROUP);

  // Front face
  PShape front = createShape();
  front.beginShape();
  front.fill(100, 150, 255);
  front.noStroke();
  for (PVector v : frontVertices) {
    front.vertex(v.x, v.y, 0);
  }
  front.endShape(CLOSE);
  extruded.addChild(front);

  // Back face
  PShape back = createShape();
  back.beginShape();
  back.fill(100, 150, 255);
  back.noStroke();
  for (int i = frontVertices.size() - 1; i >= 0; i--) {
    PVector v = frontVertices.get(i);
    back.vertex(v.x, v.y, depth);
  }
  back.endShape(CLOSE);
  extruded.addChild(back);

  // Sides
  for (int i = 0; i < frontVertices.size(); i++) {
    int next = (i + 1) % frontVertices.size();
    PVector v1 = frontVertices.get(i);
    PVector v2 = frontVertices.get(next);

    PShape side = createShape();
    side.beginShape(QUADS);
    side.fill(100, 150, 255);
    side.noStroke();
    side.vertex(v1.x, v1.y, 0);
    side.vertex(v2.x, v2.y, 0);
    side.vertex(v2.x, v2.y, depth);
    side.vertex(v1.x, v1.y, depth);
    side.endShape();
    extruded.addChild(side);
  }

  return extruded;
}

void showHUD() {
  camera(); // Reset transform untuk HUD
  hint(DISABLE_DEPTH_TEST);
  fill(255);
  textSize(12);
  textAlign(LEFT);
  text(
    "Controls:\n" +
    "Pitch: W/S  |  Yaw: A/D  |  Roll: Q/E\n" +
    "Crab: J/L   |  Ped: I/K  |  Zoom: +/-\n" +
    "Texture Toggle: T\n" +
    "Light move: U/O (X), M/. (Y), Z/X (Z)\n" +
    "Light mode Point/Directional: L\n" +
    "Auto-Rotate On/Off: R",
    10, 20
  );
  hint(ENABLE_DEPTH_TEST);
}

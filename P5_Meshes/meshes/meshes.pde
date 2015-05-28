// Daniel Dias
// CS 3451
// 25 April 2014 
// Project 5
// Triangle Meshes

import processing.opengl.*;

float time = 0;  // keep track of passing of time (for automatic rotation)
boolean rotate_flag = true;       // automatic rotation of model?
int colorMode = TriangleMesh.WHITE;
int shadingMode = TriangleMesh.FLAT_SHADING;

TriangleMesh mesh = null;

// initialize stuff
void setup()
{
  size(400, 400, OPENGL);  // must use OPENGL here !!!
  noStroke();     // do not draw the edges of polygons
}

// Draw the scene
void draw()
{
  resetMatrix();  // set the transformation matrix to the identity (important!)

  background(0);  // clear the screen to black
  
  // set up for perspective projection
  perspective (PI * 0.333, 1.0, 0.01, 1000.0);
  
  // place the camera in the scene (just like gluLookAt())
  camera (0.0, 0.0, 5.0, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0);
  
  scale (1.0, -1.0, 1.0);  // change to right-handed coordinate system
  
  // create an ambient light source
  ambientLight(102, 102, 102);
  
  // create two directional light sources
  lightSpecular(204, 204, 204);
  directionalLight(102, 102, 102, -0.7, -0.7, -1);
  directionalLight(152, 152, 152, 0, 0, -1);
  
  pushMatrix();

  fill(255, 255, 255);            // set polygon color to blue
  ambient (200, 200, 200);
  specular(0, 0, 0);
  shininess(1.0);
  
  rotate (time, 1.0, 0.0, 0.0);
  
  if (mesh != null)
    mesh.Render();
  else
  {
    beginShape();
    normal(0.0, 0.0, 1.0);
    vertex (-1.0, -1.0, 0.0);
    vertex ( 1.0, -1.0, 0.0);
    vertex ( 1.0,  1.0, 0.0);
    vertex (-1.0,  1.0, 0.0);
    endShape(CLOSE);
  }
  
  popMatrix();
 
  // maybe step forward in time (for object rotation)
  if (rotate_flag)
    time += 0.02f;
    
  if (time > 2 * PI)
    time -= 2 * PI;
}

// handle keyboard input
void keyPressed() {
  if (key == '1') {
    read_mesh ("tetra.ply");
  }
  else if (key == '2') {
    read_mesh ("octa.ply");
  }
  else if (key == '3') {
    read_mesh ("icos.ply");
  }
  else if (key == '4') {
    read_mesh ("star.ply");
  }
  else if (key == '5') {
    read_mesh ("torus.ply");
  }
  else if (key == '6') {
    create_sphere();                     // create a sphere
  }
  else if (key == 'd') {
    if (null != mesh)
      mesh = mesh.CreateDual();
  }
  else if (key == 'n') {
    if (null != mesh)
    {
      mesh.ToggleShading();
      if (TriangleMesh.FLAT_SHADING == shadingMode)
        shadingMode = TriangleMesh.SMOOTH_SHADING;
      else
        shadingMode = TriangleMesh.FLAT_SHADING;
    }
  }
  else if (key == 'w') {
    if (null != mesh)
    {
      colorMode = TriangleMesh.WHITE;
      mesh.SetColorWhite();
    }
  }
  else if (key == 'r') {
    if (null != mesh)
    {
      colorMode = TriangleMesh.RANDOM_COLORS;
      mesh.SetColorRandom();
    }
  }
  else if (key == ' ') {
    rotate_flag = !rotate_flag;          // rotate the model?
  }
  else if (key == 'q' || key == 'Q') {
    exit();                               // quit the program
  }
}

// Read polygon mesh from .ply file
//
// You should modify this routine to store all of the mesh data
// into a mesh data structure instead of printing it to the screen.
void read_mesh (String filename)
{
  int i;
  String[] tokens;
  
  String lines[] = loadStrings(filename);
  
  tokens = split (lines[0], " ");
  int num_vertices = int(tokens[1]);
  println ("number of vertices = " + num_vertices);
  
  tokens = split (lines[1], " ");
  int num_faces = int(tokens[1]);
  println ("number of faces = " + num_faces);
  
  mesh = new TriangleMesh(num_vertices, num_faces, colorMode, shadingMode);
  
  // read in the vertices
  for (i = 0; i < num_vertices; i++)
  {
    tokens = split (lines[i+2], " ");
    float x = float(tokens[0]);
    float y = float(tokens[1]);
    float z = float(tokens[2]);
//    println ("vertex = " + x + " " + y + " " + z);
    mesh.AddVertex(x, y, z);
  }
  
  // read in the faces
  for (i = 0; i < num_faces; i++)
  {
    int j = i + num_vertices + 2;
    tokens = split (lines[j], " ");
    
    int nverts = int(tokens[0]);
    if (nverts != 3) {
      println ("error: this face is not a triangle.");
      exit();
    }
    
    int index1 = int(tokens[1]);
    int index2 = int(tokens[2]);
    int index3 = int(tokens[3]);
//    println ("face = " + index1 + " " + index2 + " " + index3);
    mesh.AddFace(index1, index2, index3);
  }
  
  mesh.CalculateOppositesAndVertexNormals();
  
  //mesh.PrintGeometryTable();
  //mesh.PrintCornerTable();
}

void create_sphere() {}


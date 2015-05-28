/* Daniel Dias
 * Project 2
 * 21 February 2014
 * 3D Scene
 * Car drives down a highway as it drives by Buildings
 *
 *  Controls:
 *    Enter: Accelerate
 *    Space: Decelerate
 *    Left:  Move the camera Left
 *    Right: Move the camera Right
 *    Up:    Zoom out the camera
 *    Down:  Zoom in the camera
 *  
 *  Animation:
 *    Cars drive forward and speed is user controlled
 *    Also, tires turn
 *
 *  Object Instancing:
 *    Street Lamps, Buildings, Skyscrapers, Cars, Wheels for each car, Road
 *
 *  Duration:
 *    Loops infinitely
 *
 *  Object Contact:
 *    The cars exactly rest on the road which is raised 5 units along the +y.
 */

import processing.opengl.*;

float deltaTime = 0.03222222;//0.0166666; // in essentially milliseconds

SuperCar superCar;
SuperCar[] otherCars;
OBJModel road;
OBJModel[] building;
OBJModel[] skyscraper;
OBJModel streetLamp;
OBJModel highwayLamp;

Vector3 cameraLocation;

Building[][] buildingGrid;

void setup()
{
  size(400, 400, OPENGL);
  noStroke();
  
  superCar = new SuperCar();
  road = new OBJModel("RoadGarage");
  building = new OBJModel[3];
  building[0] = new OBJModel("Building0");
  building[1] = new OBJModel("Building1");
  building[2] = new OBJModel("Building2");
  skyscraper = new OBJModel[4];
  skyscraper[0] = new OBJModel("SkyScraper0");
  skyscraper[1] = new OBJModel("SkyScraper1");
  skyscraper[2] = new OBJModel("SkyScraper2");
  skyscraper[3] = new OBJModel("SkyScraper3");
  highwayLamp = new OBJModel("LampLarge");
  
  cameraLocation = new Vector3(-150, -7, 0);
  
  buildingGrid = new Building[4][32];
  
  for (int i = 0; i < buildingGrid.length; ++i)
  {
      // All buildings to the left of car's point of view
      // in 1 of the 4 building slots
    for (int j = 0; j < buildingGrid[i].length/2; ++j)
    {
      float x = random(-300, -260);
      float z = random(-i * 500 + 500, -i * 500 + 1000); //1000,500,0,-500,-1000
      
      if (j % 4 == 0)
      {
        float rotation = random(2 * PI);
        buildingGrid[i][j] = new Building(skyscraper[floor(random(4))], rotation, x, 0, z);
      }
      else
      {
        float rotation = random(-PI * 0.6, -PI * 0.4);
        buildingGrid[i][j] = new Building(building[floor(random(3))], rotation, x, 0, z);
      }
    }
    
      // All buildings to the right of car's point of view
      // in 1 of the 4 building slots
    for (int j = buildingGrid[i].length/2; j < buildingGrid[i].length; ++j)
    {
      float x = random(-150, -100);
      float z = random(-i * 500 + 500, -i * 500 + 1000);
      
      if (j % 4 == 0)
      {
        float rotation = random(2 * PI);
        buildingGrid[i][j] = new Building(skyscraper[floor(random(4))], rotation, x, 0, z);
      }
      else
      {
        float rotation = random(PI * 0.4, PI * 0.6);
        buildingGrid[i][j] = new Building(building[floor(random(3))], rotation, x, 0, z);
      }
    } 
  }
  
  superCar.origin.x = -191.5;
  superCar.origin.y = 5.38;
  superCar.origin.z = 500;
  
  superCar.direction.x = 0;
  superCar.direction.y = 0;
  superCar.direction.z = 0;
  
  otherCars = new SuperCar[2];  // from 0 to 4
  for (int n = 0; n < otherCars.length; ++n)
  {
    otherCars[n] = new SuperCar();
    otherCars[n].origin.x = -191.5 - ((n+2) * 5);
    otherCars[n].origin.y = 5.38;
    otherCars[n].origin.z = 1000 - (n * 100);
    float carSpeedGraphX = random(3.0, 3.6);
    otherCars[n].carSpeed = -5 * (carSpeedGraphX - 5) * (carSpeedGraphX - 5) + 125; // y = -5(x - 5)^2 + 125, speed goes from 0 to 125 as x goes from 0 to 5
  }
  
  Material tempMaterial = road.getMaterial("RoadExterior");
  tempMaterial.fillR = 200;
  tempMaterial.fillG = 200;
  tempMaterial.fillB = 155;
}

void draw()
{
  CalculateAnimation();
  
  resetMatrix();
  
  background(0, 51, 102);     //midnight blue
  //background(135, 206, 235);  //sky blue
  
  perspective(PI * 0.3333, 1.0, 0.01, 1000.0);
  
  camera(cameraLocation.x, cameraLocation.y, cameraLocation.z,
         superCar.origin.x, -superCar.origin.y, superCar.origin.z,
         0.0, 1.0, 0.0);
         
    // turn to right hand scale with +y being up
  scale(1.0, -1.0, 1.0);
  
  ambientLight(102, 102, 102);
  
  lightSpecular(204, 204, 204);
  
  //directionalLight(80, 80, 80, 0.25, -1, 0.25); // day sky light
  directionalLight(10, 10, 10, 0.25, -1, 0.25);   // night sky light
  
  superCar.Render();
  
  for (int n = 0; n < otherCars.length; ++n)
    otherCars[n].Render();
  
    // Render 3 road models in a line to help with looping
  pushMatrix();
    road.Render();
    translate(0, 0, -1000);
    road.Render();
    translate(0, 0, 2000);
    road.Render();
  popMatrix();
  
  for (int i = 0; i < buildingGrid.length; ++i)
    for (int j = 0; j < buildingGrid[i].length; ++j)
      buildingGrid[i][j].Render();
  
  for (int n = 0; n < 16; ++n)
  {
      // right street lamps
    pushMatrix();
      translate(-189.85, 5.2, (100 * n) - 800);
      rotate(-PI * 0.5, 0, 1, 0);
      if (n != 6)
        highwayLamp.Render();
    popMatrix();
  }
  
  for (int n = 0; n < 16; ++n)
  {
      // left street lamps
    pushMatrix();
      translate(-219.85, 5.2, (100 * n) - 800);
      rotate(PI * 0.5, 0, 1, 0);
      highwayLamp.Render();
    popMatrix();
  }
  
    // Render the green floor/ground
  pushMatrix();
    fill(0, 120, 0);
    translate(0, -0.1, 0);
    scale(500, 1, 3000);
    plane();
  popMatrix();
}

  // Only change values when a key is Up
boolean spaceUp = true;
boolean enterUp = true;
boolean upUp = true;
boolean downUp = true;
boolean leftUp = true;
boolean rightUp = true;
void keyPressed()
{
  if (key == ' ' && spaceUp)
    spaceUp = false;
  if (key == '\n' && enterUp)
    enterUp = false;
  if (keyCode == UP && upUp)
    upUp = false;
  if (keyCode == DOWN && downUp)
    downUp = false;
  if (keyCode == LEFT && leftUp)
    leftUp = false;
  if (keyCode == RIGHT && rightUp)
    rightUp = false;
}
void keyReleased()
{
  if (key == ' ')
    spaceUp = true;
  if (key == '\n')
    enterUp = true;
  if (keyCode == UP)
    upUp = true;
  if (keyCode == DOWN)
    downUp = true;
  if (keyCode == LEFT)
    leftUp = true;
  if (keyCode == RIGHT)
    rightUp = true;
}

  // Runs every frame
float carSpeedGraphX = 0;
float cameraAngle = PI * 0.5;
float cameraDistance = 6;
float spinTimeOut = 0;
boolean spin = true;
void CalculateAnimation()
{
    // Accelerate to 125 in a negative parabola
  if (!enterUp)
  {
    carSpeedGraphX += 0.01;
    if (carSpeedGraphX > 5)
      carSpeedGraphX = 5;
  }
  
    // Decelerate to 0
  if (!spaceUp)
  {
    carSpeedGraphX -= 0.03;
    if (carSpeedGraphX < 0)
      carSpeedGraphX = 0;
  }
  
    // zoom out camera
  if (!upUp)
  {
    cameraLocation.y -= 0.02;
    cameraDistance += 0.04;
    if (cameraDistance > 18)
      cameraDistance = 18;
    if (cameraLocation.y < -13)
      cameraLocation.y = -13;
  }
  
    // zoom in camera
  if (!downUp)
  {
    cameraLocation.y += 0.02;
    cameraDistance -= 0.04;
    if (cameraDistance < 6)
      cameraDistance = 6;
    if (cameraLocation.y > -7)
      cameraLocation.y = -7;
  }
  
    // rotate left and start timeout timer
  if (!leftUp)
  {
    spin = false;
    spinTimeOut = 0;
    cameraAngle += 0.02;
  }
  
    // rotate right and start timeout timer
  if (!rightUp)
  {
    spin = false;
    spinTimeOut = 0;
    cameraAngle -= 0.02;
  }
  
    // run timer to rotate the camera automatically
  if (!spin)
  {
    spinTimeOut += deltaTime;
    if (spinTimeOut > 4)
    {
      spin = true;
    }
  }
  
    // update car and other cars' speed, position, and tire rotation.
  superCar.carSpeed = -5 * (carSpeedGraphX - 5) * (carSpeedGraphX - 5) + 125; // y = -5(x - 5)^2 + 125
  
  superCar.origin.z -= (superCar.carSpeed * deltaTime);
  superCar.wheelRotation += superCar.carSpeed * PI * 0.52 * deltaTime;
  
  for (int n = 0; n < otherCars.length; ++n)
  {
    otherCars[n].origin.z -= (otherCars[n].carSpeed * deltaTime);
    otherCars[n].wheelRotation += otherCars[n].carSpeed * PI * 0.52 * deltaTime;
  }
  
    // keep values close to zero
  if (superCar.wheelRotation > 100)
    superCar.wheelRotation -= PI * 0.52 * 50;
  if (superCar.wheelRotation < -100)
    superCar.wheelRotation += PI * 0.52 * 50;
  
    // only spin when auto spin is enabled
    // and keep values near zero
  if (spin)
    cameraAngle += 0.005;
  if (cameraAngle > (4 * PI))
    cameraAngle -= 4 * PI;
  
    // keep other cars near main car by keeping them within
    // 1000 units from main car
  for (int n = 0; n < otherCars.length; ++n)
  {
    if (superCar.origin.z - otherCars[n].origin.z < -1000)
    {
      //println("Super.z - other.z < -2000");
      otherCars[n].origin.z -= 2000;
    }
    else if (superCar.origin.z - otherCars[n].origin.z > 1000)
    {
      //println("Super.z - other.z > 2000");
      otherCars[n].origin.z += 2000;
    }
  }
  
    // keep car in the [500, -500] range and if relocation necessary, move everything
  if (superCar.origin.z < -500)
  {
    //println("Relocating everything");
    superCar.origin.z += 1000;
    
    for (int n = 0; n < otherCars.length; ++n)
      otherCars[n].origin.z += 1000;
    
      // shift last n-1 items forward and shift them all the same amount as the car
    for (int i = 1; i < buildingGrid.length; ++i)
    {
      for (int j = 0; j < buildingGrid[i].length; ++j)
      {
        buildingGrid[i-1][j] = buildingGrid[i][j];
        buildingGrid[i-1][j].origin.z += 1000;
      }
    }
    
      // recalculate random buildings for the last buildingGrid[i] array    
    int i = buildingGrid.length-1;  
    
    for (int j = 0; j < buildingGrid[i].length/2; ++j)
    {
      float x = random(-300, -260);
      float z = random(-i * 500 + 500, -i * 500 + 1000); //1000,500,0,-500,-1000
      
      if (j % 4 == 0)
      {
        float rotation = random(2 * PI);
        buildingGrid[i][j] = new Building(skyscraper[floor(random(4))], rotation, x, 0, z);
      }
      else
      {
        float rotation = random(-PI * 0.6, -PI * 0.4);
        buildingGrid[i][j] = new Building(building[floor(random(3))], rotation, x, 0, z);
      }
    }
    
    for (int j = buildingGrid[i].length/2; j < buildingGrid[i].length; ++j)
    {
      float x = random(-150, -100);
      float z = random(-i * 500 + 500, -i * 500 + 1000);
      
      if (j % 4 == 0)
      {
        float rotation = random(2 * PI);
        buildingGrid[i][j] = new Building(skyscraper[floor(random(4))], rotation, x, 0, z);
      }
      else
      {
        float rotation = random(PI * 0.4, PI * 0.6);
        buildingGrid[i][j] = new Building(building[floor(random(3))], rotation, x, 0, z);
      }
    } 
  }
  
    // calculate camera position with sin and cos of cameraAngle and main car's position
  cameraLocation.x = superCar.origin.x - cameraDistance * cos(cameraAngle);
  cameraLocation.z = superCar.origin.z - cameraDistance * sin(cameraAngle);
}

public class Vector3
{
  public float x;
  public float y;
  public float z;
  
  public Vector3()
  {
    x = y = z = 0;
  }
  
  public Vector3(float xx, float yy, float zz)
  {
    x = xx;
    y = yy;
    z = zz;
  }
}

  // Wasn't used
/*public class Quaternion
{
  public float w;
  public float x;
  public float y;
  public float z;
  
  public Quaternion()
  {
    w = 1;
    x = y = z = 0;
  }
  
  public Quaternion(float angle, float ux, float uy, float uz)
  {
    w = cos(angle/2);
    x = ux * sin(angle/2);
    y = ux * sin(angle/2);
    z = ux * sin(angle/2);
    float magnitude = sqrt(w*w + x*x + y*y + z*z);
    w /= magnitude;
    x /= magnitude;
    y /= magnitude;
    z /= magnitude;
  }
}*/

void plane()
{
    beginShape(TRIANGLES);
    vertex(-1.0, 0.0, 1.0);
    vertex(-1.0, 0.0, -1.0);
    vertex(1.0, 0.0, -1.0);
    endShape();
    
    beginShape(TRIANGLES);
    vertex(1.0, 0.0, -1.0);
    vertex(1.0, 0.0, 1.0);
    vertex(-1.0, 0.0, 1.0);
    endShape();
}

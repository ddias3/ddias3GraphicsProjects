// CS 3451, Graphics
// Daniel Dias
// Project 2
// SuperCar and Building classes

public class Building
{
  public OBJModel model;
  public Vertex3 origin;
  public float rotation;

    // buildings can only rotate around the y axis.  
  public Building(OBJModel mdl, float rot, float x, float y, float z)
  {
    model = mdl;
    rotation = rot;
    origin = new Vertex3(x, y, z);
  }
  
  public void Render()
  {
    pushMatrix();
      translate(origin.x, origin.y, origin.z);
      rotate(rotation, 0, 1, 0);
      model.Render();
    popMatrix();
  }
}

public class SuperCar
{
  public Vector3 origin;
  public Vector3 direction;
  
  public Vector3 wheelFL;
  public Vector3 wheelFR;
  public Vector3 wheelBL;
  public Vector3 wheelBR;
  
  public float wheelRotation = 0;
  public float carSpeed = 0;
  
  public OBJModel mainBody;
  public OBJModel wheel;
  
    // how much to turn the front wheels.
  public float turn = 0;
  
  public SuperCar()
  {
    mainBody = new OBJModel("SuperCar");
    wheel = new OBJModel("Wheel");
    
      // Values are effectively local space coordinates
    origin = new Vector3(0.0, 0.0, 0.0);
    direction = new Vector3(0, 0, 0);
    wheelBL = new Vector3(-0.95, -0.12, 1.012);
    wheelBR = new Vector3(0.95, -0.12, 1.012);
    wheelFL = new Vector3(-0.885, -0.12, -1.658);
    wheelFR = new Vector3(0.885, -0.12, -1.658);
    
    Material tempMaterial = wheel.getMaterial(0);
    tempMaterial.fillR = tempMaterial.fillG = tempMaterial.fillB = 255;
    
    tempMaterial = wheel.getMaterial(1);
    tempMaterial.fillR = tempMaterial.fillG = tempMaterial.fillB = 0;
    
      // randomly choose color of the car.
    tempMaterial = mainBody.getMaterial("Paint");
                     //red       green     yellow    blue      black     white     grey      dark blue orange
    int[] carColors = {0xFF0000, 0x00FF00, 0xFFFF00, 0x0000FF, 0x000000, 0xFFFFFF, 0x070707, 0x191970, 0xFFA500};
    int colorIndex = floor(random(9));
    tempMaterial.fillR = (carColors[colorIndex] & 0x00FF0000) >> 16;
    tempMaterial.fillG = (carColors[colorIndex] & 0x0000FF00) >> 8;
    tempMaterial.fillB = (carColors[colorIndex] & 0x000000FF) >> 0;
    
      // Set a bunch of material colors    
    tempMaterial = mainBody.getMaterial("RedLight");
    tempMaterial.fillR = 200;
    tempMaterial.fillG = tempMaterial.fillB = 0;
    
    tempMaterial = mainBody.getMaterial("TurnLight");
    tempMaterial.fillR = 255;
    tempMaterial.fillG = 165;
    tempMaterial.fillB = 0;
    
    tempMaterial = mainBody.getMaterial("WhiteLight");
    tempMaterial.fillR = tempMaterial.fillG = tempMaterial.fillB = 255;
    
    tempMaterial = mainBody.getMaterial("HiddenSection");
    tempMaterial.fillR = tempMaterial.fillG = tempMaterial.fillB = 10;
    
    tempMaterial = mainBody.getMaterial("Grill");
    tempMaterial.fillR = tempMaterial.fillG = tempMaterial.fillB = 0;
    
    tempMaterial = mainBody.getMaterial("GlassEdge");
    tempMaterial.fillR = tempMaterial.fillG = tempMaterial.fillB = 0;
  }
  
  public void Render()
  {
    pushMatrix();
    
      translate(origin.x, origin.y, origin.z);
        // very imprecise way to rotate car, is essentially not used
      rotate(direction.x, 1.0, 0, 0);
      rotate(direction.y, 0, 1.0, 0);
      rotate(direction.z, 0, 0, 1.0);
    
      mainBody.Render();
      
      pushMatrix();
        translate(wheelBL.x, wheelBL.y, wheelBL.z);
        rotate(-wheelRotation, 1, 0, 0);
        wheel.Render();
      popMatrix();
      
      pushMatrix();
        translate(wheelFL.x, wheelFL.y, wheelFL.z);
        rotate(turn * PI * 0.0055555, 0, 1, 0);
        rotate(-wheelRotation, 1, 0, 0);
        wheel.Render();
      popMatrix();
      
      pushMatrix();
        translate(wheelBR.x, wheelBR.y, wheelBR.z);
        rotate(PI, 0, 1, 0);
        rotate(wheelRotation, 1, 0, 0);
        wheel.Render();    
      popMatrix();
      
      pushMatrix();
        translate(wheelFR.x, wheelFR.y, wheelFR.z);
        rotate(PI, 0, 1, 0);
        rotate(turn * PI * 0.0055555, 0, 1, 0);
        rotate(wheelRotation, 1, 0, 0);
        wheel.Render();
      popMatrix();
      
    popMatrix();
  }
}

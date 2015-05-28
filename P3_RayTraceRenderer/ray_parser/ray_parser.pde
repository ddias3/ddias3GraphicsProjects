/**********************************************************************
 * CS 3451 Project 3, Ray Trace Rendering
 * Daniel Dias
 * 2014 March 11
 * Interpreter and Controller
 *   Click anywhere in Screen to print a ray trace from (0, 0, 0) to
 *     that pixel.
 *   Number Keys to select scene
 *   p - Toggle scene content printing; prints everything that is in
 *     the scene when the scene is rendered. Starts disabled. 
 *   k - Increase the maximum number of recursions allowed;
 *     starts at 20, which is the maximum.
 *   l - Decrease the minimum number of recursions allowed;
 *     minimum is 0.
 **********************************************************************/
 
///////////////////////////////////////////////////////////////////////
//
// Command Line Interface (CLI) Parser  
//
///////////////////////////////////////////////////////////////////////
String gCurrentFile = new String("rect_test.cli"); // A global variable for holding current active file name.

final float RT_EPSILON = 0.000001f;

/* Debug Variables */
int     DEBUG_recursionsMax = 20;
boolean DEBUG_printSceneItems = false;
Scene currentScene;
boolean DEBUG_printRayTrace = false;
/* End Debug Variables */

///////////////////////////////////////////////////////////////////////
//
// Press key 1 to 9 and 0 to run different test cases.
//
///////////////////////////////////////////////////////////////////////
void keyPressed() 
{
  DEBUG_printRayTrace = false;
  switch(key)
  {
    case '1':  gCurrentFile = new String("t0.cli"); interpreter(); break;
    case '2':  gCurrentFile = new String("t1.cli"); interpreter(); break;
    case '3':  gCurrentFile = new String("t2.cli"); interpreter(); break;
    case '4':  gCurrentFile = new String("t3.cli"); interpreter(); break;
    case '5':  gCurrentFile = new String("c0.cli"); interpreter(); break;
    case '6':  gCurrentFile = new String("c1.cli"); interpreter(); break;
    case '7':  gCurrentFile = new String("c2.cli"); interpreter(); break;
    case '8':  gCurrentFile = new String("c3.cli"); interpreter(); break;
    case '9':  gCurrentFile = new String("c4.cli"); interpreter(); break;
    case '0':  gCurrentFile = new String("c5.cli"); interpreter(); break;
    
    case 'k':
      ++DEBUG_recursionsMax;
      if (DEBUG_recursionsMax > 20)
        DEBUG_recursionsMax = 20;
      currentScene.Render();
      break;
      
    case 'l':
      --DEBUG_recursionsMax;
      if (DEBUG_recursionsMax < 0)
        DEBUG_recursionsMax = 0;
      currentScene.Render();
      break;
      
    case 'p':
      if (DEBUG_printSceneItems)
        DEBUG_printSceneItems = false;
      else
        DEBUG_printSceneItems = true;
      break;
  }
}

void mousePressed()
{
  DEBUG_printRayTrace = true;
  currentScene.RenderSinglePixel(mouseX, mouseY);
}

///////////////////////////////////////////////////////////////////////
//
//  Parser core. It parses the CLI file and processes it based on each 
//  token. Only "color", "rect", and "write" tokens are implemented. 
//  You should start from here and add more functionalities for your
//  ray tracer.
//
//  Note: Function "splitToken()" is only available in processing 1.25 
//       or higher.
//
///////////////////////////////////////////////////////////////////////
void interpreter()
{  
  String str[] = loadStrings(gCurrentFile);
  if (str == null)
    println("Error! Failed to read the file.");
  
  //Scene currentScene = new Scene();
  currentScene = new Scene();
  
  float[] currentSurfaceInfo = {0,0,0,  0,0,0,  0,0,0,  0,  0};
  int currentMaterialIndex = -1;
  Triangle currentTri = null;
  int triangleVertexIndex = 0;
  
  for (int i = 0; i < str.length; ++i)
  {    
    String[] token = splitTokens(str[i], " "); // Get a line and parse tokens.
    
    if (token.length == 0)
    {
      continue; // Skip blank line.
    }
    else if (token[0].equals("fov"))
    {
      currentScene.fov = Float.parseFloat(token[1]);
      currentScene.viewPlaneSide = tan(currentScene.fov / 2.0f * PI / 180.0f);
    }
    else if (token[0].equals("background"))
    {
      currentScene.background.r = Float.parseFloat(token[1]);
      currentScene.background.g = Float.parseFloat(token[2]);
      currentScene.background.b = Float.parseFloat(token[3]);
    }
    else if (token[0].equals("light"))
    {
      if (currentScene.pointLights.size() >= 10)
      {
        println("Already 10 lights in current Scene");
        continue;
      }
      
      float x = Float.parseFloat(token[1]);
      float y = Float.parseFloat(token[2]);
      float z = Float.parseFloat(token[3]);
      float r = Float.parseFloat(token[4]);
      float g = Float.parseFloat(token[5]);
      float b = Float.parseFloat(token[6]);
      
      currentScene.pointLights.add(new PointLight(x, y, z, r, g, b));
    }
    else if (token[0].equals("surface"))
    {
      for (int n = 0; n < currentSurfaceInfo.length; ++n)
        currentSurfaceInfo[n] = Float.parseFloat(token[n + 1]);
      
      Material newMaterial = new Material(currentSurfaceInfo[0], currentSurfaceInfo[1], currentSurfaceInfo[2],
                                          currentSurfaceInfo[3], currentSurfaceInfo[4], currentSurfaceInfo[5],
                                          currentSurfaceInfo[6], currentSurfaceInfo[7], currentSurfaceInfo[8],
                                          currentSurfaceInfo[9], currentSurfaceInfo[10]);
      
      currentScene.materials.add(newMaterial);
      
      ++currentMaterialIndex;
    }    
    else if (token[0].equals("sphere"))
    {
      float radius = Float.parseFloat(token[1]);
      float x = Float.parseFloat(token[2]);
      float y = Float.parseFloat(token[3]);
      float z = Float.parseFloat(token[4]);
      
      Sphere newSphere = new Sphere(radius, x, y, z, currentMaterialIndex);
      newSphere.materialRef = currentScene.materials.get(currentMaterialIndex);
      
      currentScene.spheres.add(newSphere);
    }
    else if (token[0].equals("begin"))
    {
      currentTri = new Triangle(0, 0, 0,
                                0, 0, 0,
                                0, 0, 0, currentMaterialIndex);
      
      currentTri.materialRef = currentScene.materials.get(currentMaterialIndex);
      
      triangleVertexIndex = 0;      
    }
    else if (token[0].equals("vertex"))
    {
      float x = Float.parseFloat(token[1]);
      float y = Float.parseFloat(token[2]);
      float z = Float.parseFloat(token[3]);
      
      if (triangleVertexIndex == 0)
      {
        currentTri.pointA.x = x;
        currentTri.pointA.y = y;
        currentTri.pointA.z = z;
      }
      else if (triangleVertexIndex == 1)
      {
        currentTri.pointB.x = x;
        currentTri.pointB.y = y;
        currentTri.pointB.z = z;
      }
      else if (triangleVertexIndex == 2)
      {
        currentTri.pointC.x = x;
        currentTri.pointC.y = y;
        currentTri.pointC.z = z;
      }
      
      ++triangleVertexIndex;
    }
    else if (token[0].equals("end"))
    {
      currentScene.triangles.add(currentTri);
      
      triangleVertexIndex = 0;
      currentTri = null;
    }
    else if (token[0].equals("color"))
    {
      float r = float(token[1]);
      float g = float(token[2]);
      float b = float(token[3]);
      fill(r, g, b);
    }
    else if (token[0].equals("rect"))
    {
      float x0 = float(token[1]);
      float y0 = float(token[2]);
      float x1 = float(token[3]);
      float y1 = float(token[4]);
      rect(x0, height-y1, x1-x0, y1-y0);
    }
    else if (token[0].equals("write"))
    {
      currentScene.Render();
      save(token[1]);  
    }
  }
}

///////////////////////////////////////////////////////////////////////
//
// Some initializations for the scene.
//
///////////////////////////////////////////////////////////////////////
void setup()
{
  size(300, 300);  
  noStroke();
  colorMode(RGB, 1.0);
  background(0, 0, 0);
  interpreter();
}

///////////////////////////////////////////////////////////////////////
//
// Draw frames.  Should leave this empty.
//
///////////////////////////////////////////////////////////////////////
void draw()
{
  // do nothing
}


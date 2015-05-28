/**********************************************************************
 * CS 3451 Project 3, Ray Trace Rendering
 * Daniel Dias
 * 2014 March 11
 * Scene that holds everything and that renders via Ray Tracing
 **********************************************************************/

public class Scene
{
  public ArrayList<PointLight> pointLights;
  
  public ArrayList<Sphere> spheres;
  public ArrayList<Triangle> triangles;
  
  public ArrayList<Material> materials;
  
  public float fov = 60;
  public float viewPlaneSide = tan(60.0f/2.0f * PI/2.0f);
  
  public Color background = new Color(0, 0, 0);
  
  public Scene()
  {
    pointLights = new ArrayList<PointLight>();
    spheres = new ArrayList<Sphere>();
    materials = new ArrayList<Material>();
    triangles = new ArrayList<Triangle>();
  }
  
  public int RenderSinglePixel(int x, int y)
  {
    Vector3 cameraOrigin = new Vector3(0, 0, 0);
    Vector3 rayDirection = new Vector3(0, 0, -1);
    
    rayDirection.x = (x - width / 2.0f) * 2.0f * viewPlaneSide / width;
    rayDirection.y = -(y - height / 2.0f) * 2.0f * viewPlaneSide / height;
    
    if (DEBUG_printRayTrace) println("\nBegin RayTrace");
          
    Color rayColor = RayTraceColor(cameraOrigin, rayDirection, 0.0f, Float.POSITIVE_INFINITY, 0);
    
    loadPixels();
    pixels[y * width + x] = color(min(rayColor.r, 1), min(rayColor.g, 1), min(rayColor.b, 1));
    updatePixels();
    
    if (DEBUG_printRayTrace) println("End RayTrace");
    
    return 0;
  }
  
    /**
     * Sends out a ray from the origin to every pixel
     *@returns An error code, but there is only success, so doesn't return anything.
     */
  public int Render()
  {
    if (DEBUG_printSceneItems)
    {
      println("\nCurrentFile: " + gCurrentFile); 
      println("FOV: " + fov + " degrees");
      for (int n = 0; n < pointLights.size(); ++n)
        println(pointLights.get(n));
      for (int n = 0; n < spheres.size(); ++n)
        println(spheres.get(n));
      for (int n = 0; n < triangles.size(); ++n)
        println(triangles.get(n));
      for (int n = 0; n < materials.size(); ++n)
        println("Mat " + n + ", " + materials.get(n));
    }
      
    Vector3 cameraOrigin = new Vector3(0, 0, 0);
    Vector3 rayDirection = new Vector3(0, 0, -1);
    
    if (spheres.size() > 0 || triangles.size() > 0)
    {
      loadPixels();
      for (int x = 0; x < width; ++x)
      {
        for (int y = 0; y < height; ++y)
        {
          rayDirection.x = (x - width / 2.0f) * 2.0f * viewPlaneSide / width;
          rayDirection.y = -(y - height / 2.0f) * 2.0f * viewPlaneSide / height;
          
          Color rayColor = RayTraceColor(cameraOrigin, rayDirection, 0.0f, Float.POSITIVE_INFINITY, 0);
          
          pixels[y * width + x] = color(min(rayColor.r, 1), min(rayColor.g, 1), min(rayColor.b, 1));
        }
      }
      updatePixels();
    }
    
    return 0;
  }
  
    /**
     * Determines if a given ray hits a given sphere by plugging in a parametric line equation with an implicit sphere equation. 
     *@param sphere The sphere being tested against.
     *@param origin The point the ray starts from
     *@param direction The direction the ray travels in
     *@param minT The minimum t that counts as a hit
     *@param maxT The maximum t that counts as a hit
     *@return If there is no hit at all, returns null, otherwise returns an instance of RayTraceIntersection which
     *  carries the point, the value of t, and the surface hit.
     */
  RayTraceIntersection CalculateRayTrace(final Sphere sphere, final Vector3 origin, final Vector3 direction, final float minT, final float maxT)
  {
    float a = direction.DotProduct(direction);
    float b = 2 * (direction.DotProduct(origin.x - sphere.center.x, origin.y - sphere.center.y, origin.z - sphere.center.z));
    float c = (new Vector3(origin.x - sphere.center.x, origin.y - sphere.center.y, origin.z - sphere.center.z)).DotProduct(origin.x - sphere.center.x, origin.y - sphere.center.y, origin.z - sphere.center.z) - sphere.r * sphere.r;
     
    float discriminant = (b * b - 4 * a * c);
    if (discriminant < 0)
    {
      return null;
    }
    else
    {
      float Tp = (-b + sqrt(discriminant)) / (2 * a);
      float Tm = (-b - sqrt(discriminant)) / (2 * a);
      
      float returnT;
      boolean validTm;
      boolean validTp;
      
      if (Tm < minT || Tm > maxT)
        validTm = false;
      else
        validTm = true;
      
      if (Tp < minT || Tp > maxT)
        validTp = false;
      else
        validTp = true;
        
      if (validTm && validTp)
        if (Tm < Tp)
          returnT = Tm;
        else
          returnT = Tp;
      else if (validTm && !validTp)
        returnT = Tm;
      else if (!validTm && validTp)
        returnT = Tp;
      else
        return null;
        
      RayTraceIntersection rayIntersect = new RayTraceIntersection();
      rayIntersect.t = returnT;  
      rayIntersect.surface = sphere;
      rayIntersect.point = new Vector3(origin.x + rayIntersect.t * direction.x,
                                       origin.y + rayIntersect.t * direction.y,
                                       origin.z + rayIntersect.t * direction.z);
                                     
      return rayIntersect;
    }
  }
  
    /**
     * Determines if a given ray hits a given triangle and uses barycentric coordinates to determine if 
     *  the ray collides with the plane, then the triangle itself.
     *@param triangle The triangle being tested against.
     *@param origin The point the ray starts from
     *@param direction The direction the ray travels in
     *@param minT The minimum t that counts as a hit
     *@param maxT The maximum t that counts as a hit
     *@return If there is no hit at all, returns null, otherwise returns an instance of RayTraceIntersection which
     *  carries the point, the value of t, and the surface hit.
     */
  RayTraceIntersection CalculateRayTrace(final Triangle triangle, final Vector3 origin, final Vector3 direction, final float minT, final float maxT)
  {
    // Check to make sure not perpendicular
    Vector3 triNormal = triangle.CalculateNormal(v3ZERO);  //parameter is not used, but there is a parameter because of abstract parent class's function
    
    if (triNormal.DotProduct(direction) == 0)
      return null;
    
      // Solve for t using this linear algebra equation.
    // v3_origin + t * v3_direction = v3_pointA + beta*(v3_pointB - v3_pointA) + gamma*(v3_pointC - v3_pointA)
    // [(v3_pointA - v3_pointB), (v3_pointA - v3_pointC), v3_direction] * [beta, gamma, t] = [(v3_pointA - v3_origin)]
    //                             A                                    *        x         =             b
    
    Vector3 v3AminusB      = new Vector3(triangle.pointA.x - triangle.pointB.x,
                                         triangle.pointA.y - triangle.pointB.y,
                                         triangle.pointA.z - triangle.pointB.z);
    Vector3 v3AminusC      = new Vector3(triangle.pointA.x - triangle.pointC.x,
                                         triangle.pointA.y - triangle.pointC.y,
                                         triangle.pointA.z - triangle.pointC.z);
    Vector3 v3AminusOrigin = new Vector3(triangle.pointA.x - origin.x,
                                         triangle.pointA.y - origin.y,
                                         triangle.pointA.z - origin.z);
                                         
      // solve for t using Cramer's Rule
    float detA = TriangleRayTraceDeterminantHelper(v3AminusB, v3AminusC, direction);
    float t = TriangleRayTraceDeterminantHelper(v3AminusB, v3AminusC, v3AminusOrigin) / detA;
               
    if (t < minT || t > maxT)
      return null;
      
      // solve for gamma using Cramer's Rule
    float gamma = TriangleRayTraceDeterminantHelper(v3AminusB, v3AminusOrigin, direction) / detA;
    
    if (gamma < 0 || gamma > 1)
      return null;
      
      //solve for beta using Cramer's Rule
    float beta = TriangleRayTraceDeterminantHelper(v3AminusOrigin, v3AminusC, direction) / detA;
    
    if (beta < 0 || beta > (1 - gamma + RT_EPSILON))
      return null;
      
    RayTraceIntersection rayIntersect = new RayTraceIntersection();
    rayIntersect.t = t;
    rayIntersect.surface = triangle;
    rayIntersect.point = new Vector3(origin.x + rayIntersect.t * direction.x,
                                     origin.y + rayIntersect.t * direction.y,
                                     origin.z + rayIntersect.t * direction.z);
    return rayIntersect;
  }
  
    /**
     * Determines if a given ray hits a surface by checking against every surface, spheres/triangles, in the
     *  scene, and then returns the closest intersection that is still within the bound (minT, maxT).
     *@param origin The point the ray starts from
     *@param rayDirection The direction the ray travels in
     *@param minT The minimum t that counts as a hit
     *@param maxT The maximum t that counts as a hit
     *@return If there is no hit at all, returns null, otherwise returns an instance of RayTraceIntersection which
     *  carries the point, the value of t, and the surface hit.
     */
  public RayTraceIntersection RayTraceHit(Vector3 origin, Vector3 rayDirection, float minT, float maxT)
  {
    float t = Float.POSITIVE_INFINITY;
    RayTraceIntersection currentIntersection = null;
          
    for (int n = 0; n < spheres.size(); ++n)
    {
      RayTraceIntersection rayIntersect = CalculateRayTrace(spheres.get(n), origin, rayDirection, minT, maxT);
            
      if (rayIntersect != null && rayIntersect.t < (t - RT_EPSILON))
      {
        if (DEBUG_printRayTrace) println("    hit | " + rayIntersect);
        t = rayIntersect.t;
        currentIntersection = rayIntersect;
      }
    }
          
    for (int n = 0; n < triangles.size(); ++n)
    {
      RayTraceIntersection rayIntersect = CalculateRayTrace(triangles.get(n), origin, rayDirection, minT, maxT);
            
      if (rayIntersect != null && rayIntersect.t < (t - RT_EPSILON))
      {
        if (DEBUG_printRayTrace) println("    hit | " + rayIntersect);
        t = rayIntersect.t;
        currentIntersection = rayIntersect;
      }
    }
    
    return currentIntersection;
  }
  
    /**
     * Shoots out a single ray from the point origin in the direction rayDirection and returns
     *  a color, the background color if it doesn't collide with anything.
     *@param origin The point the ray starts from
     *@param rayDirection The direction the ray travels in
     *@param minT The minimum t that counts as a hit
     *@param maxT The maximum t that counts as a hit
     *@param numberRecurision The index of recursion that this ray is, with 0 meaning that it was not recursively shot from a reflection.
     *@return Returns the color that this ray has, where each ray corresponds to a pixel, in the range [0, 1] for the colors r,g,b. 
     */
  public Color RayTraceColor(Vector3 origin, Vector3 rayDirection, float minT, float maxT, int numberRecursion)
  {
    if (DEBUG_printRayTrace) println("+ Light Ray:" + numberRecursion + " p=" + origin + " + t" + rayDirection);
    
      // Look for any intersection
    RayTraceIntersection currentIntersection = RayTraceHit(origin, rayDirection, minT, maxT);
    Color rayColor = null;
    
      // Calculate Lighting for this intersection
    if (currentIntersection != null)
    {
      if (DEBUG_printRayTrace) println("    FINAL hit | " + currentIntersection);
      
      Material currentMaterial = currentIntersection.surface.materialRef;
              
        // vector p
      //currentIntersection.point

        // start with the ambient color and add from there
      rayColor = new Color(currentMaterial.ambient.r,
                           currentMaterial.ambient.g,
                           currentMaterial.ambient.b);
      
        // vector n
      Vector3 normal = currentIntersection.surface.CalculateNormal(currentIntersection.point);
      
        // d . n
      float directionDotNormal = rayDirection.DotProduct(normal);

        // vector r = d - 2(d . n)n
      Vector3 reflectionVector = new Vector3(rayDirection.x - 2 * directionDotNormal * normal.x,
                                             rayDirection.y - 2 * directionDotNormal * normal.y,
                                             rayDirection.z - 2 * directionDotNormal * normal.z);
      
        // Determines if a reflected ray needs to be sent out.
      if (currentMaterial.K_refl > 0 && numberRecursion < DEBUG_recursionsMax)//20)
      {
        Color reflectionColor = RayTraceColor(currentIntersection.point, reflectionVector, 70 * RT_EPSILON, Float.POSITIVE_INFINITY, numberRecursion + 1);
        
        //println("\t" + reflectionColor + "N=" + normal + "d=" + rayDirection + "r=" + reflectionVector);
        rayColor.r += currentMaterial.K_refl * reflectionColor.r;
        rayColor.g += currentMaterial.K_refl * reflectionColor.g;
        rayColor.b += currentMaterial.K_refl * reflectionColor.b;
      }
      
        // Shoot a shadow ray from each collision to every single light source.
      for (int n = 0; n < pointLights.size(); ++n)
      {
        PointLight light = pointLights.get(n);
                
          // vector l
        Vector3 pointToLight = new Vector3(light.location.x - currentIntersection.point.x,
                                           light.location.y - currentIntersection.point.y,
                                           light.location.z - currentIntersection.point.z);
        //pointToLight.Normalize();
        
        if (DEBUG_printRayTrace) println("- Shadow Ray:" + numberRecursion + " p=" + currentIntersection.point + " + t" + pointToLight + " to light " + light);
        
          //pt + t*s = loc
          //t*s = loc - pt
          //t = (loc - pt)/s
        //float maxTtoLight = ((light.location.x - currentIntersection.point.x) / pointToLight.x + (light.location.y - currentIntersection.point.y) / pointToLight.y + (light.location.z - currentIntersection.point.z) / pointToLight.z) / 3;
        
          // since the ray tracer works without a normalized direction, subtracting the light's location from
          // the point the shadow ray was shot from means that the only acceptable parameters of t are in the range (0, 1).
        if (RayTraceHit(currentIntersection.point, pointToLight, /*0 +*/ 10 * RT_EPSILON, 1 - RT_EPSILON) == null)
        {
            // these calculates require it to be normalized though
          pointToLight.Normalize();
          
          /*  // n . l
          float normalDotLight = normal.DotProduct(pointToLight);
            // r = 2n(n . l) - l
          Vector3 reflectionVector = new Vector3(2 * normal.x * normalDotLight - pointToLight.x,
                                                 2 * normal.y * normalDotLight - pointToLight.y,
                                                 2 * normal.z * normalDotLight - pointToLight.z);*/
          
            // vector v
          Vector3 viewAngle = new Vector3(-rayDirection.x,
                                          -rayDirection.y,
                                          -rayDirection.z);
          viewAngle.Normalize();
                  
            // vector h
          Vector3 viewLightHalfAngle = new Vector3(pointToLight.x + viewAngle.x,
                                                   pointToLight.y + viewAngle.y,
                                                   pointToLight.z + viewAngle.z);
          viewLightHalfAngle.Normalize();
          
            // currently uses Phong specular lighting model, but the Blinn-Phong half angle model is ready to go since everything is already calculated for it.
          rayColor.r += light.lightColor.r * (currentMaterial.diffuse.r * max(0, normal.DotProduct(pointToLight))
                                            + currentMaterial.specular.r * pow(max(0, reflectionVector.DotProduct(pointToLight)/*normal.DotProduct(viewLightHalfAngle)*/), currentMaterial.P));
                                            
          rayColor.g += light.lightColor.g * (currentMaterial.diffuse.g * max(0, normal.DotProduct(pointToLight))
                                            + currentMaterial.specular.g * pow(max(0, reflectionVector.DotProduct(pointToLight)/*normal.DotProduct(viewLightHalfAngle)*/), currentMaterial.P));
                                            
          rayColor.b += light.lightColor.b * (currentMaterial.diffuse.b * max(0, normal.DotProduct(pointToLight))
                                            + currentMaterial.specular.b * pow(max(0, reflectionVector.DotProduct(pointToLight)/*normal.DotProduct(viewLightHalfAngle)*/), currentMaterial.P));
        }
      }
    }
    else // no hit, so return the background color
    {
      if (DEBUG_printRayTrace) println("no hit |");
      rayColor = new Color(background.r, background.g, background.b);
    }
          
    return rayColor;
  }
  
    /**
     * Helper function that calculates the determinant of a 3x3 matrix used by the RayTrace function 
     *  that determines if it hits a triangle. Takes in 3 column vectors which are used as the 3 columns
     *  of the matrix. Columns vectors are used as input because it makes it easier to calculate new
     *  determinates using Cramer's rule to solve Ax=b.
     *@param column1 The 1st column of the 3x3
     *@param column2 The 2nd column of the 3x3
     *@param column3 The 3rd column of the 3x3
     *@return The determinant of the 3x3 matrix.
     */
  private float TriangleRayTraceDeterminantHelper(Vector3 column1, Vector3 column2, Vector3 column3)
  {
    return column1.x * (column2.y * column3.z - column2.z * column3.y) -
           column1.y * (column2.x * column3.z - column2.z * column3.x) +
           column1.z * (column2.x * column3.y - column2.y * column3.x);
  }
}

public class RayTraceIntersection
{
  public Vector3 point;
  public float t;
  public SceneSurface surface;
  
  public String toString()
  {
    return "p(t=" + t + ") = " + point + ", surface{" + surface + "}";
  }
}

public class Material
{
  public Color diffuse;
  public Color ambient;
  public Color specular;
  public float P = 0;
  public float K_refl = 0;
  
  public Material(float Cd_rr, float Cd_gg, float Cd_bb, 
                  float Ca_rr, float Ca_gg, float Ca_bb,
                  float Cs_rr, float Cs_gg, float Cs_bb,
                  float PP, float KK_refl)
  {
    diffuse  = new Color(Cd_rr, Cd_gg, Cd_bb);
    ambient  = new Color(Ca_rr, Ca_gg, Ca_bb);
    specular = new Color(Cs_rr, Cs_gg, Cs_bb);
    
    P = PP;
    K_refl = KK_refl;
  }
  
  public String toString()
  {
    return "Mat | Cd" + diffuse + ", Ca" + ambient + ", Cs" + specular + ", P:" + P + ", K:" + K_refl;
  }
}

public class Sphere extends SceneSurface
{
  public Vector3 center;
  public float r = 1;

  public Sphere(float rr, float xx, float yy, float zz)
  {
    super.materialIndex = 0;
    center = new Vector3(xx, yy, zz);
    r = rr;
  }
  
  public Sphere(float rr, float xx, float yy, float zz, int materialIndex)
  {
    super.materialIndex = materialIndex;
    center = new Vector3(xx, yy, zz);
    r = rr;
  }
  
  public Vector3 CalculateNormal(Vector3 point)
  {
    Vector3 normal = new Vector3((point.x - center.x) / r,
                                 (point.y - center.y) / r,
                                 (point.z - center.z) / r);
    //normal.Normalize();
    return normal;
  }
  
  public String toString()
  {
    return "Sph - r=" + r + ", Location" + center + ", MaterialIndex[" + materialIndex + "]";
  }
}

public class Triangle extends SceneSurface
{
  public Vector3 pointA;
  public Vector3 pointB;
  public Vector3 pointC;
  
  public Triangle(Vector3 a, Vector3 b, Vector3 c)
  {
    super.materialIndex = 0;
    pointA = a;
    pointB = b;
    pointC = c;
  }
  
  public Triangle(float Ax, float Ay, float Az,
                  float Bx, float By, float Bz,
                  float Cx, float Cy, float Cz)
  {
    super.materialIndex = 0;
    pointA = new Vector3(Ax, Ay, Az);
    pointB = new Vector3(Bx, By, Bz);
    pointC = new Vector3(Cx, Cy, Cz);
  }
  
  public Triangle(Vector3 a, Vector3 b, Vector3 c, int materialIndex)
  {
    super.materialIndex = materialIndex;
    pointA = a;
    pointB = b;
    pointC = c;
  }
  
  public Triangle(float Ax, float Ay, float Az,
                  float Bx, float By, float Bz,
                  float Cx, float Cy, float Cz, int materialIndex)
  {
    super.materialIndex = materialIndex;
    pointA = new Vector3(Ax, Ay, Az);
    pointB = new Vector3(Bx, By, Bz);
    pointC = new Vector3(Cx, Cy, Cz);
  }
  
  public Vector3 CalculateNormal(Vector3 point)
  {
    Vector3 a_v3BminusA = new Vector3(pointB.x - pointA.x, pointB.y - pointA.y, pointB.z - pointA.z);
    Vector3 b_v3CminusA = new Vector3(pointC.x - pointA.x, pointC.y - pointA.y, pointC.z - pointA.z);
       
    //Vector3 normal = a_v3BminusA.CrossProduct(b_v3CminusA);
    Vector3 normal = b_v3CminusA.CrossProduct(a_v3BminusA);                                     
    normal.Normalize();
    return normal;
  }
  
  public String toString()
  {
    return "Tri - <A" + pointA + " B" + pointB + " C" + pointC + ">, MaterialIndex[" + materialIndex + "]";
  }
}

  /**
   * SceneSurface is an abstract class that a Ray Trace may hit.
   */
public abstract class SceneSurface
{
  public Material materialRef = null;
  public int materialIndex;
  
  public abstract Vector3 CalculateNormal(Vector3 point);
}

public class PointLight
{
  public Vector3 location;
  public Color lightColor;
  
  public PointLight(float x, float y, float z, float r, float g, float b)
  {
    location = new Vector3(x, y, z);
    lightColor = new Color(r, g, b);
  }
  
  public String toString()
  {
    return "PLt + Location" + location + ", Color" + lightColor;
  }
}

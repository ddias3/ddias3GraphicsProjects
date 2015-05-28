/**********************************************************************
 * CS 3451 Project 3, Ray Trace Rendering
 * Daniel Dias
 * 2014 March 11
 * Color and Vector3
 **********************************************************************/

public class Color
{
  public float r;
  public float g;
  public float b;
  
  public Color(float rr, float gg, float bb)
  {
    r = rr;
    g = gg;
    b = bb;
  }
  
  public String toString()
  {
    return "[" + r + "," + g + "," + b + "]";
  }
}

Vector3 v3ZERO = new Vector3(0, 0, 0); 

public class Vector3
{
  public float x;
  public float y;
  public float z;
  
  public float DotProduct(Vector3 rhVector3)
  {
    return x * rhVector3.x + y * rhVector3.y + z * rhVector3.z;
  }
  
  public float DotProduct(float rhX, float rhY, float rhZ)
  {
    return x * rhX + y * rhY + z * rhZ;
  }
  
  public Vector3 CrossProduct(Vector3 rhVector3)
  {
    return new Vector3(y * rhVector3.z - z * rhVector3.y,
                       z * rhVector3.x - x * rhVector3.z,
                       x * rhVector3.y - y * rhVector3.x);
  }
  
  public void Normalize()
  {
    float magnitude = sqrt(x*x + y*y + z*z);
    x /= magnitude;
    y /= magnitude;
    z /= magnitude;
  }
  
  public Vector3(float xx, float yy, float zz)
  {
    x = xx;
    y = yy;
    z = zz;
  }
  
  public String toString()
  {
    return "(" + x + "," + y + "," + z + ")";
  }
}

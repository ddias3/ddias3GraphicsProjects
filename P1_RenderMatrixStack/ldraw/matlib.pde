// CS 3451 Spring 2013 Homework 1 

private gtMatrix4x4 matrixStack[];
private int matrixStackIndex = 0;

private gtMatrix4x4 matrixViewPort;
private gtMatrix4x4 matrixOrthographic;
private gtMatrix4x4 matrixPerspectiveProjection;
private boolean perspective;

private float near;
private float far;

void gtInitialize()
{
  matrixStack = new gtMatrix4x4[10];
  for (int n = 0; n < matrixStack.length; ++n)
    matrixStack[n] = new gtMatrix4x4();
}

void gtPushMatrix()
{
  if (matrixStackIndex + 1 >= matrixStack.length)
  {
    println("Doubling Matrix Stack");
    gtMatrix4x4 temp[] = new gtMatrix4x4[matrixStack.length + 10];
    for (int n = 0; n < matrixStack.length; ++n)
      temp[n] = matrixStack[n];
    for (int n = matrixStack.length; n < temp.length; ++n)
      temp[n] = new gtMatrix4x4();
    matrixStack = temp;
  }
  
  matrixStack[matrixStackIndex + 1].CopyMatrix(matrixStack[matrixStackIndex]);
    
  ++matrixStackIndex;
}

void gtPopMatrix()
{
  if (matrixStackIndex == 0)
    print("ERROR: Cannot pop last item in stack\n");
  else
    --matrixStackIndex;
}

void gtTranslate(float tx, float ty, float tz)
{
  gtMatrix4x4 translateMatrixTranspose = new gtMatrix4x4();
  translateMatrixTranspose.matrix[12] = tx;
  translateMatrixTranspose.matrix[13] = ty;
  translateMatrixTranspose.matrix[14] = tz;
  
  gtMatrix4x4 tempCTM = new gtMatrix4x4(matrixStack[matrixStackIndex]);
  
  matrixStack[matrixStackIndex] = tempCTM.MatrixMatrixMultiplyTransposed(translateMatrixTranspose);
}

void gtScale(float sx, float sy, float sz)
{
  gtMatrix4x4 scaleMatrixTranspose = new gtMatrix4x4();
  scaleMatrixTranspose.matrix[0] = sx;
  scaleMatrixTranspose.matrix[5] = sy;
  scaleMatrixTranspose.matrix[10] = sz;
  
  gtMatrix4x4 tempCTM = new gtMatrix4x4(matrixStack[matrixStackIndex]);
  
  matrixStack[matrixStackIndex] = tempCTM.MatrixMatrixMultiplyTransposed(scaleMatrixTranspose);
}

void gtRotate(float angle, float ax, float ay, float az)
{
  gtVector3 vectorW = new gtVector3(ax, ay, az);
  vectorW.Normalize();
  
  gtVector3 vectorN = new gtVector3(vectorW);
  {
    float minimum = (float)(0x7FFFFFFF);
    int index = 2;
    for (int n = 2; n >= 0; --n)
      if (Math.abs(vectorN.vector[n]) < minimum)
      {
        minimum = Math.abs(vectorN.vector[n]);
        index = n;
      }
    vectorN.vector[index] = 1;  
  }
  
  gtVector3 vectorU = vectorN.CrossProduct(vectorW);
  vectorU.Normalize();
  
  gtVector3 vectorV = vectorW.CrossProduct(vectorU);
  
  gtMatrix4x4 matrixR1 = new gtMatrix4x4();
  matrixR1.matrix[0] = vectorU.vector[0];
  matrixR1.matrix[1] = vectorU.vector[1];
  matrixR1.matrix[2] = vectorU.vector[2];
  matrixR1.matrix[4] = vectorV.vector[0];
  matrixR1.matrix[5] = vectorV.vector[1];
  matrixR1.matrix[6] = vectorV.vector[2];
  matrixR1.matrix[8] = vectorW.vector[0];
  matrixR1.matrix[9] = vectorW.vector[1];
  matrixR1.matrix[10] = vectorW.vector[2];
  
  gtMatrix4x4 matrixR1Transpose = matrixR1.Transpose();
  
  gtMatrix4x4 matrixRotation = new gtMatrix4x4();
  float radians = angle * PI / 180.0f;
  matrixRotation.matrix[0] = matrixRotation.matrix[5] = (float)Math.cos(radians);
  matrixRotation.matrix[4] = (float)Math.sin(radians);
  matrixRotation.matrix[1] = -matrixRotation.matrix[4];
  
  gtMatrix4x4 tempCTM = new gtMatrix4x4(matrixStack[matrixStackIndex]);
  
  matrixStack[matrixStackIndex] = tempCTM.MatrixMatrixMultiply(matrixR1Transpose.MatrixMatrixMultiply(matrixRotation).MatrixMatrixMultiply(matrixR1));
}

void gtPerspective(float fov, float nnear, float ffar)
{
  perspective = true;
  near = -nnear;
  far = -ffar;
 
  float right = nnear * (float)Math.tan(0.5f * fov * PI / 180);
  float top = right;
  
  CalculateViewPort();
  CalculateOrthographic(-right, right, -top, top, near, far);
  
  gtMatrix4x4 matrixPerspective = new gtMatrix4x4();
  matrixPerspective.matrix[0] = near;
  matrixPerspective.matrix[5] = near;
  matrixPerspective.matrix[10] = near + far;
  matrixPerspective.matrix[11] = -(far * near);
  matrixPerspective.matrix[14] = 1;
  matrixPerspective.matrix[15] = 0;
  
  matrixPerspectiveProjection = matrixOrthographic.MatrixMatrixMultiply(matrixPerspective);
}

void gtOrtho(float left, float right, float bottom, float top, float nnear, float ffar)
{
  perspective = false;
  near = -nnear;
  far = -ffar;
  
  CalculateViewPort();
  CalculateOrthographic(left, right, bottom, top, near, far);
}

void CalculateOrthographic(float left, float right, float bottom, float top, float near, float far)
{
  matrixOrthographic = new gtMatrix4x4();
  matrixOrthographic.matrix[0] = 2.0f / (right - left);
  matrixOrthographic.matrix[3] = -((right + left) / (right - left));
  matrixOrthographic.matrix[5] = 2.0f / (top - bottom);
  matrixOrthographic.matrix[7] = -((top + bottom) / (top - bottom));
  matrixOrthographic.matrix[10] = 2.0f / (near - far);
  matrixOrthographic.matrix[11] = -((near + far) / (near - far));
}

void CalculateViewPort()
{
  matrixViewPort = new gtMatrix4x4();
  matrixViewPort.matrix[0] = width / 2.0f;
  matrixViewPort.matrix[3] = (width - 1) / 2.0f;
  matrixViewPort.matrix[5] = height / 2.0f;
  matrixViewPort.matrix[7] = (height - 1) / 2.0f;
}

private int gtType = GT_NONE;
void gtBeginShape(int type)
{
  step = 0;
  gtType = type;
}

void gtEndShape()
{
  step = 0;
  gtType = GT_NONE;
}

private int step = 0;
private float x_1, y_1, z_1, x_2, y_2, z_2;
void gtVertex(float x, float y, float z)
{
  switch (gtType)
  {
  case GT_NONE:
    break;
  case GT_POLYGON:
    break;
  case GT_LINES:
    if (step == 0)
    {
      x_1 = x;
      y_1 = y;
      z_1 = z;
      ++step;
    }
    else if (step == 1)
    {
      x_2 = x;
      y_2 = y;
      z_2 = z;
      
      gtVector4 startPoint = new gtVector4(x_1, y_1, z_1);
      gtVector4 endPoint = new gtVector4(x_2, y_2, z_2);
      
        // Apply Current Transformation Matrix
      startPoint = matrixStack[matrixStackIndex].MatrixVectorMultiply(startPoint);
      endPoint = matrixStack[matrixStackIndex].MatrixVectorMultiply(endPoint);
      
      xyz xyzStart = new xyz(startPoint.vector[0], startPoint.vector[1], startPoint.vector[2]);
      xyz xyzEnd = new xyz(endPoint.vector[0], endPoint.vector[1], endPoint.vector[2]);
      
        // Clip lines and only draw if line is at least
        // somewhat inside near and far clipping planes
      if (near_far_clip(near, far, xyzStart, xyzEnd) == 1)
      {
        startPoint.vector[0] = xyzStart.x;
        startPoint.vector[1] = xyzStart.y;
        startPoint.vector[2] = xyzStart.z;
        endPoint.vector[0] = xyzEnd.x;
        endPoint.vector[1] = xyzEnd.y;
        endPoint.vector[2] = xyzEnd.z;
        
          // Project points to 2D
        gtMatrix4x4 matrixCanonicalToScreen;
        
        if (perspective)
          matrixCanonicalToScreen = matrixViewPort.MatrixMatrixMultiply(matrixPerspectiveProjection);
        else
          matrixCanonicalToScreen = matrixViewPort.MatrixMatrixMultiply(matrixOrthographic);
        
        startPoint = matrixCanonicalToScreen.MatrixVectorMultiply(startPoint);
        endPoint = matrixCanonicalToScreen.MatrixVectorMultiply(endPoint);
        
          // Draw lines
        if (perspective)
          draw_line(startPoint.vector[0] / startPoint.vector[3], // x / w
                    startPoint.vector[1] / startPoint.vector[3], // y / w
                    endPoint.vector[0] / endPoint.vector[3],  // x / w
                    endPoint.vector[1] / endPoint.vector[3]); // y / w
        else
          draw_line(startPoint.vector[0], // x / w, w = 1
                    startPoint.vector[1], // y
                    endPoint.vector[0],   // x
                    endPoint.vector[1]);  // y
      }
      
      step = 0;
    }
    break;
  }
}

class gtMatrix4x4
{
  public float matrix[] = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
  
  public gtMatrix4x4()
  {
    // do nothing
  }
  
  public gtMatrix4x4(gtMatrix4x4 otherMatrix)
  {
    this.CopyMatrix(otherMatrix);
  }
  
  public void CopyMatrix(gtMatrix4x4 otherMatrix)
  {
    for (int n = 15; n >= 0; --n)
      matrix[n] = otherMatrix.matrix[n];
  }
  
  public void printMatrix()
  {
    print("[" + matrix[0] + ",\t" + matrix[1] + ",\t" + matrix[2] + ",\t" + matrix[3] + "]\n" +
          "[" + matrix[4] + ",\t" + matrix[5] + ",\t" + matrix[6] + ",\t" + matrix[7] + "]\n" +
          "[" + matrix[8] + ",\t" + matrix[9] + ",\t" + matrix[10] + ",\t" + matrix[11] + "]\n" +
          "[" + matrix[12] + ",\t" + matrix[13] + ",\t" + matrix[14] + ",\t" + matrix[15] + "]\n");
  }
  
  public gtMatrix4x4 Transpose()
  {
    gtMatrix4x4 matrixTranspose = new gtMatrix4x4();
    for (int y = 0; y < 4; ++y)
      for (int x = 0; x < 4; ++x)
        matrixTranspose.matrix[x * 4 + y] = matrix[y * 4 + x];
    return matrixTranspose;
  }
  
    // This function multiplies 2 matrices like a normal multiplication
    // except that the RHS matrix of the multiplication has been transposed
    // for cleaner looping in the third loop.
    // Returns C = AB, input is B^t, where A is this matrix
  public gtMatrix4x4 MatrixMatrixMultiplyTransposed(gtMatrix4x4 matrixRHSTransposed)
  {
    gtMatrix4x4 tempMatrix = new gtMatrix4x4();
    for (int y_a = 0; y_a < 4; ++y_a)
    {
      for (int y_b = 0; y_b < 4; ++y_b)
      {
        float sum = 0f;
        for (int n = 0; n < 4; ++n)
        {
          sum += matrix[y_a * 4 + n] * matrixRHSTransposed.matrix[y_b * 4 + n];
        }
        tempMatrix.matrix[y_a * 4 + y_b] = sum;
      }
    }
    return tempMatrix;
  }
  
  public gtMatrix4x4 MatrixMatrixMultiply(gtMatrix4x4 matrixRHS)
  {
    gtMatrix4x4 tempMatrix = new gtMatrix4x4();
    for (int y = 0; y < 4; ++y)
    {
      for (int x = 0; x < 4; ++x)
      {
        float sum = 0f;
        for (int n = 0; n < 4; ++n)
        {
          sum += matrix[y * 4 + n] * matrixRHS.matrix[n * 4 + x];
        }
        tempMatrix.matrix[y * 4 + x] = sum;
      }
    }
    return tempMatrix;    
  }
  
  public gtVector4 MatrixVectorMultiply(gtVector4 vector4)
  {
    gtVector4 tempVector = new gtVector4();
    for (int y = 0; y < 4; ++y)
    {
      float sum = 0f;
      for (int x = 0; x < 4; ++x)
      {
        sum += matrix[y * 4 + x] * vector4.vector[x];
      }
      tempVector.vector[y] = sum;
    }
    return tempVector;
  }
}

class gtVector4
{
  public float vector[] = {0, 0, 0, 1};
  public float length = 1;
  
  public gtVector4()
  {
    // do nothing;
  }
  
  public gtVector4(float x, float y, float z)
  {
    vector[0] = x;
    vector[1] = y;
    vector[2] = z;
  }
  
  public gtVector4(float x, float y, float z, float w)
  {
    vector[0] = x;
    vector[1] = y;
    vector[2] = z;
    vector[3] = w;
  }
  
  public gtVector4(gtVector3 vector3)
  {
    vector[0] = vector3.vector[0];
    vector[1] = vector3.vector[1];
    vector[2] = vector3.vector[2];
  }
  
  public gtVector4(gtVector4 vector4)
  {
    vector[0] = vector4.vector[0];
    vector[1] = vector4.vector[1];
    vector[2] = vector4.vector[2];
    vector[3] = vector4.vector[3];
    length = vector4.length; 
  }
  
  public void printVector()
  {
    println("[" + vector[0] + ", " + vector[1] + ", " + vector[2] + ", " + vector[3] + "]");
  }
}

class gtVector3
{
  public float vector[] = {0, 0, 0};
  public float length = 0;
  public gtVector3()
  {
    // do nothing
  }
  
  public gtVector3(float ax, float ay, float az)
  {
    vector[0] = ax;
    vector[1] = ay;
    vector[2] = az;
        
    length = (float)Math.sqrt(ax * ax + ay * ay + az * az);
  }
  
  public gtVector3(gtVector3 vector3)
  {
    vector[0] = vector3.vector[0];
    vector[1] = vector3.vector[1];
    vector[2] = vector3.vector[2];
    
    length = vector3.length;
  }
  
  public void Normalize()
  {
    vector[0] /= length;
    vector[1] /= length;
    vector[2] /= length;
    length = 1;
  }
  
  public gtVector3 CrossProduct(gtVector3 vectorOther)
  {
    return new gtVector3(vector[1] * vectorOther.vector[2] - vector[2] * vectorOther.vector[1],
                         vector[2] * vectorOther.vector[0] - vector[0] * vectorOther.vector[2],
                         vector[0] * vectorOther.vector[1] - vector[1] * vectorOther.vector[0]);
  }
  
  public void printVector()
  {
    println("[" + vector[0] + ", " + vector[1] + ", " + vector[2] + "]");
  }
}

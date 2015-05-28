// CS 3451 Spring 2013 Homework 1 

gtMatrix4x4 matrixStack[];
int matrixStackIndex = 0;

void gtInitialize()
{
  matrixStack = new gtMatrix4x4[10];
  for (int n = 0; n < matrixStack.length; ++n)
    matrixStack[n] = new gtMatrix4x4();
    
  /*// Matrixs are stored in row-order form.
    // - one row after another; after 4 rows, begin next matrix
  matrixStack[0] = matrixStack[5] = matrixStack[10] = matrixStack[15] = 1;*/
  
  //matrixStack[0].printMatrix();
}

void gtPushMatrix()
{
  if (matrixStackIndex + 1 >= matrixStack.length)
  {
    /*println("Doubling Matrix Stack");
    float temp[] = new float[matrixStack.length + 10 * 16];
    for (int n = 0; n < matrixStack.length; ++n)
      temp[n] = matrixStack[n];
    for (int n = matrixStack.length; n < temp.length; ++n)
      temp[n] = 0;
    matrixStack = temp;*/
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
  
  //MatrixMatrixTransposedLoop(tempCTM, translateMatrixTranspose);
  matrixStack[matrixStackIndex] = tempCTM.MatrixMatrixMultiplyTransposed(translateMatrixTranspose);
}

void gtScale(float sx, float sy, float sz)
{
  gtMatrix4x4 scaleMatrixTranspose = new gtMatrix4x4();
  scaleMatrixTranspose.matrix[0] = sx;
  scaleMatrixTranspose.matrix[5] = sy;
  scaleMatrixTranspose.matrix[10] = sz;
  
  gtMatrix4x4 tempCTM = new gtMatrix4x4(matrixStack[matrixStackIndex]);
  
  //MatrixMatrixTransposedLoop(tempCTM, scaleMatrixTranspose);
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
  
  /*vectorW.printVector();
  vectorU.printVector();
  vectorV.printVector();*/
  
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
  matrixRotation.matrix[0] = matrixRotation.matrix[5] = (float)Math.cos(angle);
  matrixRotation.matrix[4] = (float)Math.sin(angle);
  matrixRotation.matrix[1] = -matrixRotation.matrix[4];
  
  matrixR1.printMatrix();
  println();
  matrixRotation.printMatrix();
  
  gtMatrix4x4 tempCTM = new gtMatrix4x4(matrixStack[matrixStackIndex]);
  
  matrixStack[matrixStackIndex] = tempCTM.MatrixMatrixMultiply(matrixR1Transpose.MatrixMatrixMultiply(matrixRotation).MatrixMatrixMultiply(matrixR1));
}

void gtPerspective(float fovy, float nnear, float ffar)
{
}

void gtOrtho(float left, float right, float bottom, float top, float nnear, float ffar)
{
}

void gtBeginShape(int type) { }

void gtEndShape() { }

void gtVertex(float x, float y, float z) { }

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
        //matrixStack[(matrixStackIndex * 16) + y_a * 4 + y_b] = sum;
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

void setup()
{
  gtInitialize();
  //println(matrixStack.length);
  
  gtPushMatrix();
  
  /*gtScale(2, 2, 2);
  matrixStack[matrixStackIndex].printMatrix();
  println();
  gtTranslate(1, 1, 1);
  matrixStack[matrixStackIndex].printMatrix();*/
  
  /*gtTranslate(1, 1, 1);
  matrixStack[matrixStackIndex].printMatrix();
  println();
  gtScale(2, 2, 2);
  matrixStack[matrixStackIndex].printMatrix();*/
  
  /*gtTranslate(1, 9, 3);
  matrixStack[matrixStackIndex].printMatrix();
  println();
  gtScale(2, 3, 4);
  matrixStack[matrixStackIndex].printMatrix();*/
  
  /*gtScale(2, 3, 4);
  matrixStack[matrixStackIndex].printMatrix();
  println();
  gtTranslate(1, 9, 3);
  matrixStack[matrixStackIndex].printMatrix();*/
  
  /*gtScale(9, 5, 1);
  matrixStack[matrixStackIndex].printMatrix();
  println();
  gtTranslate(100, 5, 1);
  matrixStack[matrixStackIndex].printMatrix();*/
  
  gtRotate(30, 0, 0, 1);
}

/*void MatrixMatrixTransposedLoop(float[] tempCTM, float[] matrixRHSTransposed)
{
  for (int y_a = 0; y_a < 4; ++y_a)
  {
    print("[");
    for (int y_b = 0; y_b < 4; ++y_b)
    {
      float sum = 0f;
      for (int n = 0; n < 4; ++n)
      {
        sum += tempCTM[y_a * 4 + n] * matrixRHSTransposed[y_b * 4 + n];
      }
      matrixStack[(matrixStackIndex * 16) + y_a * 4 + y_b] = sum;
      print(sum + "\t");
    }
    print("]\n");
  }
}*/


/* Project 0
 * Daniel Dias
 * 2014.01.07
 * Linear Fractals
 */

final int screenWidth = 400;

double[]  arrayDotsX;
double[]  arrayDotsY;
double    v_real;
double    v_imag;

void setup()
{
  size(screenWidth, screenWidth);
  ellipseMode(CENTER);
  noStroke();
  colorMode(HSB, 255);
  
  arrayDotsX = new double[2048];
  arrayDotsY = new double[2048];
}

void draw()
{
  background(0, 0, 255);
  //println(mouseX + ", " + mouseY + " -> " + mouseToNewMouseX(mouseX) + ", " + mouseToNewMouseY(mouseY));
  
  arrayDotsX[0] = arrayDotsY[0] = 0;
  v_real = mouseToNewMouseX(mouseX);
  v_imag = mouseToNewMouseY(mouseY);
  
  double v_realCurrent = 1;
  double v_imagCurrent = 0;
  
  ellipse(realScreenToPixelScreenX(arrayDotsX[0]), realScreenToPixelScreenY(arrayDotsY[0]), 4, 4);
  
  for (int n = 0, power = 1; n < 11; ++n, power *= 2)
  {
    for (int m = power-1; m >= 0; --m)
    {
      double tempX = arrayDotsX[m];
      double tempY = arrayDotsY[m];
      
      arrayDotsX[m*2] = tempX + v_realCurrent;
      arrayDotsY[m*2] = tempY + v_imagCurrent;
      
      arrayDotsX[m*2+1] = tempX - v_realCurrent;
      arrayDotsY[m*2+1] = tempY - v_imagCurrent;
      
      fill(color(n*15, 255, 255));
      
      ellipse(realScreenToPixelScreenX(arrayDotsX[m*2]), realScreenToPixelScreenY(arrayDotsY[m*2]), 4, 4);
      ellipse(realScreenToPixelScreenX(arrayDotsX[m*2+1]), realScreenToPixelScreenY(arrayDotsY[m*2+1]), 4, 4);
    }
    
    double temp = v_realCurrent;
    v_realCurrent = v_realCurrent * v_real - v_imagCurrent * v_imag;
    v_imagCurrent = v_real * v_imagCurrent + v_imag * temp;
    
    //println("n = " + (n+1) + ", v^n = (" + v_realCurrent + " + " + v_imagCurrent + "i)");
  }
}

    // new screen -> screen
  // [-3, 3] -> [0, 400]
  // x' = (x / 3 * 200) + 200
int realScreenToPixelScreenX(double var)
{
  return (int)(var / 3.0 * (screenWidth/2)) + screenWidth/2;
}
  // [-3, 3] -> [400, 0]
  // y' = -(y / 3 * 200) + 200 
int realScreenToPixelScreenY(double var)
{
  return (int)(-(var / 3.0 * (screenWidth/2))) + screenWidth/2;
}

  // [0, 400] -> [-2, 2]
  // x' = (x-200) / 100.0
double mouseToNewMouseX(int var)
{
  return (var - 200) / 100.0;
}
  // [400, 0] -> [-2, 2]
  // y' = -(y-200) / 100.0
double mouseToNewMouseY(int var)
{
  return (-(var - 200)) / 100.0;
}

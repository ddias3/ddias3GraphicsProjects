import java.util.LinkedList;
import java.util.Iterator;

public class Face
{
  private LinkedList<PVector> vertices;
  private LinkedList<Integer> verticesID;
  private int numberVertices;
  
  private PVector midPoint = null;
  
  public static final int TRIANGULATED_WITH_MIDPOINT = 1;
  public static final int SINGLE_FACE = 2;
  
  public Face()
  {
    vertices = new LinkedList<PVector>();
    verticesID = new LinkedList<Integer>();
    
    numberVertices = 0;
  }
  
  public void AddVertex(PVector vertex, int vertexID)
  {
    vertices.add(vertex);
    verticesID.add(vertexID);
    ++numberVertices;
  }
  
  public void AddVertexInPosition(PVector vertex, int vertexID, int positionInList)
  {
    vertices.add(positionInList, vertex);
    verticesID.add(positionInList, vertexID);
    ++numberVertices;
  }
  
  public PVector GetMidPoint()
  {
    if (null == midPoint)
    {
      if (numberVertices == 0)
        return null;
      else if (numberVertices == 1)
        return midPoint = new PVector(vertices.peek().x, vertices.peek().y, vertices.peek().z);
      else if (numberVertices == 2)
        return midPoint = new PVector((vertices.peekFirst().x + vertices.peekLast().x) / 2f,
                                      (vertices.peekFirst().y + vertices.peekLast().y) / 2f,
                                      (vertices.peekFirst().z + vertices.peekLast().z) / 2f);
      else
      {
        PVector tempMidPoint = new PVector(0, 0, 0);
        for (Iterator iterator = vertices.iterator(); iterator.hasNext(); )
        {
          tempMidPoint.add((PVector)iterator.next());
        }
        tempMidPoint.mult(1f / numberVertices);
        return midPoint = tempMidPoint;
      }
    }
    else
      return midPoint;   
  }
  
    // Create an array of strings that are the same as the .ply files
    // by using the indices that the Face has saved. For the midpoint,
    // use the character ? because the Face was never told which vertex
    // that is in the mesh; the mesh will have to index that seperately.
  public String[] ConvertToParseFaces(int parseMode)
  {
    if (TRIANGULATED_WITH_MIDPOINT == parseMode)
    {
      if (null == midPoint)
        GetMidPoint();
        
      String[] vertexIDString = new String[GetNumberEdges()];
      
      Integer[] verticesIDTemp = new Integer[1];
      verticesIDTemp = verticesID.toArray(verticesIDTemp);
      for (int n = 0; n < verticesIDTemp.length; ++n)
      {
        vertexIDString[n] = "3 " + verticesIDTemp[n] + " " + verticesIDTemp[(n + 1) % verticesIDTemp.length] + " ?";
      }
      
      return vertexIDString;
    }
    else if (SINGLE_FACE == parseMode)
    {
      String[] vertexIDString = new String[1];
      vertexIDString[0] = "" + numberVertices;
      for (Iterator iterator = verticesID.iterator(); iterator.hasNext(); )
      {
        vertexIDString[0] += " " + (Integer)iterator.next();
      }
      
      return vertexIDString;
    }
    
    return null;
  }
  
  public void PrintVerticesAndIDs()
  {
    println("Face: " + this);
    println(vertices);
    println(verticesID);
  }
  
  public int GetNumberVertices()
  {
    return numberVertices;
  }
  
  public int GetNumberEdges()
  {
    return numberVertices;
  }
}

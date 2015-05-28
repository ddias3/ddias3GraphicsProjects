public class TriangleMesh
{
  private PVector[] geometryTable;
  private Corner[]  cornerTable;
  
  private PVector[] normalFaceTable;
  private PVector[] normalVertexTable;
  
  public static final int SMOOTH_SHADING = 1;
  public static final int FLAT_SHADING = 0;
  
  public static final int WHITE = 0;
  public static final int RANDOM_COLORS = 1;
  
  private int shadingMode = FLAT_SHADING;
  private int colorMode = WHITE;
  
  private int geometryTableNextEntry = 0;
  private int cornerTableNextEntry = 0;
  
  private Color[] faceColorTable;
  
  public TriangleMesh(int numberVertices, int numberFaces, int colorMode, int shadingMode)
  {
    geometryTable = new PVector[numberVertices];

    cornerTable = new Corner[numberFaces * 3];
    for (int n = 0; n < cornerTable.length; ++n)
      cornerTable[n] = new Corner();

    normalFaceTable = new PVector[numberFaces];
    normalVertexTable = new PVector[numberVertices];

    faceColorTable = new Color[numberFaces];

    this.colorMode = colorMode;
    this.shadingMode = shadingMode;
  }
  
  public void AddVertex(float x, float y, float z)
  {
    geometryTable[geometryTableNextEntry] = new PVector(x, y, z);
    ++geometryTableNextEntry;
  }
  
  public void AddFace(int vertex0, int vertex1, int vertex2)
  {
    cornerTable[cornerTableNextEntry].vertexID = vertex0;
    cornerTable[cornerTableNextEntry + 1].vertexID = vertex1;
    cornerTable[cornerTableNextEntry + 2].vertexID = vertex2;
    
      // Plug in -1 until adjacency information is calculated when the entire mesh is complete
    cornerTable[cornerTableNextEntry].oppositeID = -1;
    cornerTable[cornerTableNextEntry + 1].oppositeID = -1;
    cornerTable[cornerTableNextEntry + 2].oppositeID = -1;
    
    PVector vectorA = PVector.sub(geometryTable[vertex1], geometryTable[vertex0]);
    PVector vectorB = PVector.sub(geometryTable[vertex2], geometryTable[vertex0]);

    vectorA.normalize();
    vectorB.normalize();
    
    normalFaceTable[Triangle(cornerTableNextEntry)] = vectorA.cross(vectorB);
    
    if (WHITE == colorMode)
      faceColorTable[Triangle(cornerTableNextEntry)] = new Color(255, 255, 255);
    else if (RANDOM_COLORS == colorMode)
      faceColorTable[Triangle(cornerTableNextEntry)] = new Color((int)random(256), (int)random(256), (int)random(256));
    
    cornerTableNextEntry += 3;
  }
  
  public void PrintCornerTable()
  {
    println("Corner Table");
    for (int n = 0; n < cornerTable.length; ++n)
      println(" C:" + n + "\tV:" + cornerTable[n].vertexID + "\tO:" + cornerTable[n].oppositeID); 
  }
  
  public void PrintGeometryTable()
  {
    println("Geometry Table");
    for (int n = 0; n < geometryTable.length; ++n)
      println(" V#:" + n + "\tV:" + geometryTable[n]);
  }
  
  public void Render()
  {
    PVector currentVertex;
    PVector normal;
    Color faceColor;
    
    if (FLAT_SHADING == shadingMode)
    {
      beginShape(TRIANGLES);
      
      for (int n = 0; n < cornerTable.length; n += 3)
      {
        faceColor = faceColorTable[Triangle(n)];
        fill(faceColor.r, faceColor.g, faceColor.b);
          
        normal = normalFaceTable[Triangle(n)];
        
        normal(normal.x, normal.y, normal.z);
        
        currentVertex = Vertex(n);
        vertex(currentVertex.x, currentVertex.y, currentVertex.z);
        
        currentVertex = Vertex(n+1);
        vertex(currentVertex.x, currentVertex.y, currentVertex.z);
        
        currentVertex = Vertex(n+2);
        vertex(currentVertex.x, currentVertex.y, currentVertex.z);
      }
      endShape();
    }
    else if (SMOOTH_SHADING == shadingMode)
    {
      beginShape(TRIANGLES);
      
      for (int cornerID = 0; cornerID < cornerTable.length; cornerID += 3)
      {
        faceColor = faceColorTable[Triangle(cornerID)];
        fill(faceColor.r, faceColor.g, faceColor.b);
        
        normal = normalVertexTable[VertexID(cornerID)];
        currentVertex = Vertex(cornerID);
        normal(normal.x, normal.y, normal.z);
        vertex(currentVertex.x, currentVertex.y, currentVertex.z);
        
        normal = normalVertexTable[VertexID(cornerID+1)];
        currentVertex = Vertex(cornerID+1);
        normal(normal.x, normal.y, normal.z);
        vertex(currentVertex.x, currentVertex.y, currentVertex.z);
        
        normal = normalVertexTable[VertexID(cornerID+2)];
        currentVertex = Vertex(cornerID+2);
        normal(normal.x, normal.y, normal.z);
        vertex(currentVertex.x, currentVertex.y, currentVertex.z);
      }
      endShape();
    }
  }
  
  private int Triangle(int cornerID)
  {
    return cornerID / 3;
  }
  
  private int NextCorner(int cornerID)
  {
    return 3 * Triangle(cornerID) + (cornerID + 1) % 3;
  }
  
  private int PreviousCorner(int cornerID)
  {
    return NextCorner(NextCorner(cornerID));
  }
  
  private int LeftCorner(int cornerID)
  {
    return OppositeCorner(PreviousCorner(cornerID));
  }
  
  private int RightCorner(int cornerID)
  {
    return OppositeCorner(NextCorner(cornerID));
  }
  
  private int LeftCornerSameVertex(int cornerID)
  {
    return PreviousCorner(LeftCorner(cornerID));
  }
  
  private int RightCornerSameVertex(int cornerID)
  {
    return NextCorner(RightCorner(cornerID));
  }
  
  private int VertexID(int cornerID)
  {
    return cornerTable[cornerID].vertexID;
  }
  
  private PVector Vertex(int cornerID)
  {
    return geometryTable[VertexID(cornerID)];
  }
  
  private int OppositeCorner(int cornerID)
  {
    return cornerTable[cornerID].oppositeID;
  }
  
  public void CalculateOppositesAndVertexNormals()
  {
    for (int a = 0; a < cornerTable.length; ++a)
    {
      for (int b = 0; b < cornerTable.length; ++b)
      {
        if (VertexID(NextCorner(a)) == VertexID(PreviousCorner(b)) &&
            VertexID(NextCorner(b)) == VertexID(PreviousCorner(a)))
        {
          cornerTable[a].oppositeID = b;
          cornerTable[b].oppositeID = a;
        }
      }
    }
    
    for (int vertexID = 0; vertexID < geometryTable.length; ++vertexID)
    {
      int startingCornerID = GetCornerIDFromVertexID(vertexID);
      
      int numberOfAdjacentNormals = 1;
      PVector vertexNormal = new PVector(normalFaceTable[Triangle(startingCornerID)].x, normalFaceTable[Triangle(startingCornerID)].y, normalFaceTable[Triangle(startingCornerID)].z);
      for (int traversingCornerID = RightCornerSameVertex(startingCornerID); Triangle(traversingCornerID) != Triangle(startingCornerID); traversingCornerID = RightCornerSameVertex(traversingCornerID))
      {
        vertexNormal.add(normalFaceTable[Triangle(traversingCornerID)]);
        ++numberOfAdjacentNormals;
      }
      vertexNormal.mult(1f / numberOfAdjacentNormals);
      vertexNormal.normalize();
      
      normalVertexTable[vertexID] = vertexNormal;
    }
  }
  
  private int GetCornerIDFromVertexID(int vertexID)
  {
    int startingCornerID;
    for (startingCornerID = 0; startingCornerID < cornerTable.length; ++startingCornerID)
      if (vertexID == VertexID(startingCornerID))
        break;
    return startingCornerID;
  }
  
  public void ToggleShading()
  {
    if (SMOOTH_SHADING == shadingMode)
      shadingMode = FLAT_SHADING;
    else if (FLAT_SHADING == shadingMode)
      shadingMode = SMOOTH_SHADING;
  }
  
  public void SetColorWhite()
  {
    colorMode = WHITE;
    for (int n = 0; n < faceColorTable.length; ++n)
    {
      faceColorTable[n].r = faceColorTable[n].g = faceColorTable[n].b = 255;
    }
  }
  
  public void SetColorRandom()
  {
    colorMode = RANDOM_COLORS;
    for (int n = 0; n < faceColorTable.length; ++n)
    {
      faceColorTable[n].r = (int)random(256);
      faceColorTable[n].g = (int)random(256);
      faceColorTable[n].b = (int)random(256);
    }
  }
  
  public int GetShading()
  {
    return shadingMode;
  }
  
    // Since only triangles are allowed, the dual's faces are then triangulated
    // by creating triangles out of each edge of the new face and the midpoint.
    // This creates this triangulated dual with several passes.
    //   1. Iterates through all triangles and adds the midpoint to the list of
    //        of vertices of the dual mesh.
    //   2. Iterates through all the vertices and assigns which of the new vertices
    //        are part of which new face.
    //   3. Iterates through all of the new faces and adds the midpoints to the dual mesh
    //   4. Adds all of the new vertices to the new mesh.
    //   5. Iterates through all of the dual's faces, triangulates
    //        them with the midpoint and adds them to the new mesh.
    //   6. Calculate the new opposites and vertex normals
  public TriangleMesh CreateDual()
  {
    int dualNumberFaces = geometryTable.length;
    int dualNumberVertices = cornerTable.length / 3;
    
    PVector[] dualGeometryTable = new PVector[dualNumberVertices + dualNumberFaces];
    Face[] dualFaces = new Face[dualNumberFaces];
    
    for (int cornerID = 0; cornerID < cornerTable.length; cornerID += 3)
    {
      PVector vert0 = Vertex(cornerID);
      PVector vert1 = Vertex(NextCorner(cornerID));
      PVector vert2 = Vertex(PreviousCorner(cornerID));
      
      dualGeometryTable[Triangle(cornerID)] = new PVector((vert0.x + vert1.x + vert2.x) / 3f,
                                                          (vert0.y + vert1.y + vert2.y) / 3f,
                                                          (vert0.z + vert1.z + vert2.z) / 3f);
    }
    
    for (int vertexID = 0; vertexID < geometryTable.length; ++vertexID)
    {
      dualFaces[vertexID] = new Face();
      
      int startingCornerID = GetCornerIDFromVertexID(vertexID);
      int traversingCornerID = startingCornerID;
      do
      {
        dualFaces[vertexID].AddVertex(dualGeometryTable[Triangle(traversingCornerID)], Triangle(traversingCornerID));
        traversingCornerID = RightCornerSameVertex(traversingCornerID);
      } while (Triangle(traversingCornerID) != Triangle(startingCornerID));
    }
    
    for (int dualFaceID = 0; dualFaceID < dualFaces.length; ++dualFaceID)
    {
      dualGeometryTable[dualNumberVertices + dualFaceID] = dualFaces[dualFaceID].GetMidPoint();
    }
    
    int dualNumberTriangles = 0;
    for (int n = 0; n < dualFaces.length; ++n)
      dualNumberTriangles += dualFaces[n].GetNumberEdges();
      
    TriangleMesh dualMesh = new TriangleMesh(dualGeometryTable.length, dualNumberTriangles, colorMode, shadingMode);
    
    for (int n = 0; n < dualGeometryTable.length; ++n)
    {
      PVector vertex = dualGeometryTable[n];
      dualMesh.AddVertex(vertex.x, vertex.y, vertex.z);
    }
    
    for (int dualFaceID = 0; dualFaceID < dualFaces.length; ++dualFaceID)
    {
      String[] parseFaces = dualFaces[dualFaceID].ConvertToParseFaces(Face.TRIANGULATED_WITH_MIDPOINT);
      
      for (int n = 0; n < parseFaces.length; ++n)
      {
        String[] tokens = split(parseFaces[n], " ");
        int vertexID0 = int(tokens[1]);
        int vertexID1 = int(tokens[2]);
        int vertexID2;
        if (tokens[3].equals("?"))
          vertexID2 = dualNumberVertices + dualFaceID;
        else
          vertexID2 = int(tokens[3]);
          
        dualMesh.AddFace(vertexID0, vertexID1, vertexID2);
      }
    }
    
    dualMesh.CalculateOppositesAndVertexNormals();
    
    return dualMesh;
  }
  
  private class Corner
  {
    public int vertexID;
    public int oppositeID;
    
    public Corner()
    {
    }
  }
  
  private class Color
  {
    public int r;
    public int g;
    public int b;
    public Color(int rr, int gg, int bb)
    {
      r = rr;
      g = gg;
      b = bb;
    }
  }
}

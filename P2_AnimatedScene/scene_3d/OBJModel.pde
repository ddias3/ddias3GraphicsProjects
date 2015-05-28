// CS 3451, Graphics
// Daniel Dias
// Project 2
// OBJModel class and required classes

import java.util.Map;

public class OBJModel
{
  public ArrayList<Vertex3> verts;
  private HashMap<String, Integer> texturesMap;
  private ArrayList<Material> textures;
  public ArrayList<Face3> triangles;
  
    // Materials are held in 2 different objects: HashMap and the ArrayList
    // The HashMap holds the name as the key and the value is where in the array list
    // the material is.  
  public Material getMaterial(int index)
  {
    return textures.get(index);
  }
  public Material getMaterial(String name)
  {
    return textures.get(texturesMap.get(name));
  }
  
  private OBJModel()
  {
    // not allowed;
  }
  
    // Parses 2 files for each model: <filename>.obj and <filename>.mtl
  public OBJModel(String fileName)
  {    
    verts = new ArrayList<Vertex3>(16);
    texturesMap = new HashMap<String, Integer>();
    textures = new ArrayList<Material>();
    triangles = new ArrayList<Face3>(16);
    
    BufferedReader reader;
    String line;        
    String[] tokens;
    
      // Blender's .obj exporter always exports at least one material
    int currentMaterial = -1;
    int numberOfMaterials = -1;
    
    reader = createReader(fileName + ".mtl");
    
    try
    {
      line = reader.readLine();
    }
    catch (IOException exception)
    {
      println("Couldn't read file at all");
      exception.printStackTrace();
      line = null;
    }    
    while(line != null)
    {
      tokens = splitTokens(line, " ");
      if (tokens.length == 0)
      {
        // do nothing
      }
      else if (tokens[0].equals("newmtl"))
      {
        Integer materialIndex = texturesMap.get(tokens[1]);
        if (materialIndex == null)
        {
          ++numberOfMaterials;
          currentMaterial = numberOfMaterials;
          
          texturesMap.put(tokens[1], new Integer(currentMaterial));
          
          textures.add(new Material(tokens[1]));
        }
        else
        {
          currentMaterial = texturesMap.get(tokens[1]);
        }
      }
        // diffuse colors for the current material
      else if (tokens[0].equals("Kd"))
      {
          // file goes from [0, 1] while colors go from [0, 255]
        float diffuseR = floor(Float.parseFloat(tokens[1]) * 256);
        float diffuseG = floor(Float.parseFloat(tokens[2]) * 256);
        float diffuseB = floor(Float.parseFloat(tokens[3]) * 256);
        
        Material currentMat = textures.get(currentMaterial);
        currentMat.fillR = diffuseR;
        currentMat.fillG = diffuseG;
        currentMat.fillB = diffuseB;
        
        //println("Material: " + textures.get(currentMaterial).name + " (" + textures.get(currentMaterial).fillR + ", " + textures.get(currentMaterial).fillG + ", " + textures.get(currentMaterial).fillB + ")"); 
      }
      
      try
      {
        line = reader.readLine();
      }
      catch (IOException exception)
      {
        line = null;
      }
    }
  
    currentMaterial = -1;
    numberOfMaterials = -1;
    
    reader = createReader(fileName + ".obj");

    try
    {
      line = reader.readLine();
    }
    catch (IOException exception)
    {
      println("Couldn't read file at all");
      exception.printStackTrace();
      line = null;
    }
    while(line != null)
    {
      tokens = splitTokens(line, " ");
      if (tokens.length == 0)
      {
        // do nothing
      }
      else if (tokens[0].equals("v"))
      {
        float x = Float.parseFloat(tokens[1]);
        float y = Float.parseFloat(tokens[2]);
        float z = Float.parseFloat(tokens[3]);
        verts.add(new Vertex3(x, y, z));
      }
      else if (tokens[0].equals("f"))
      {
          // face values can come in 3 formats: "#", "#/#", or "#//#"
          // always just use the left most number and ignore vertexTextures
        String[] face0 = splitTokens(tokens[1], "/");
        String[] face1 = splitTokens(tokens[2], "/");
        String[] face2 = splitTokens(tokens[3], "/");
        
          // .obj indexing starts at 1 while my arraylist starts at 0
        int indexVert0 = Integer.parseInt(face0[0]) - 1; //(tokens[1]) - 1;
        int indexVert1 = Integer.parseInt(face1[0]) - 1; //(tokens[2]) - 1;
        int indexVert2 = Integer.parseInt(face2[0]) - 1; //(tokens[3]) - 1;
        Vertex3 vert0 = verts.get(indexVert0);
        Vertex3 vert1 = verts.get(indexVert1);
        Vertex3 vert2 = verts.get(indexVert2);
        
        triangles.add(new Face3(vert0, vert1, vert2, currentMaterial));
      }
      else if (tokens[0].equals("usemtl"))
      {
        Integer materialIndex = texturesMap.get(tokens[1]);
          // should never return null
        if (materialIndex == null)
        {
          ++numberOfMaterials;
          currentMaterial = numberOfMaterials;
          
          texturesMap.put(tokens[1], new Integer(currentMaterial));
          
          textures.add(new Material(tokens[1]));
        }
        else
        {
          currentMaterial = materialIndex;
          //println("usemtl: " + textures.get(currentMaterial).name + " (" + textures.get(currentMaterial).fillR + ", " + textures.get(currentMaterial).fillG + ", " + textures.get(currentMaterial).fillB + ")");
        }
      }
      else if (tokens[0].equals("s"))
      {
        // always just not do smooth shading but use flat shading
      }
      
      try
      {
        line = reader.readLine();
      }
      catch (IOException exception)
      {
        exception.printStackTrace();
        line = null;
      }
    }
  }
  
  public void Render()
  {
      // all models should have at least 1 material, so just call fill() with the first material's values.
    int currentMaterialIndex = 0;
    Material currentMaterial = textures.get(currentMaterialIndex);
    fill(currentMaterial.fillR, currentMaterial.fillG, currentMaterial.fillB);
    
    for (int n = 0; n < triangles.size(); ++n)
    {
      Face3 currentTri = triangles.get(n);
      if (currentTri.materialIndex != currentMaterialIndex)
      {
        currentMaterialIndex = currentTri.materialIndex;
        currentMaterial = textures.get(currentMaterialIndex);
        fill(currentMaterial.fillR, currentMaterial.fillG, currentMaterial.fillB);
      }
      beginShape(TRIANGLES);
      vertex(currentTri.vert0.x, currentTri.vert0.y, currentTri.vert0.z);
      vertex(currentTri.vert1.x, currentTri.vert1.y, currentTri.vert1.z);
      vertex(currentTri.vert2.x, currentTri.vert2.y, currentTri.vert2.z);
      endShape();
    }
  }
}

  // 3D Vertex
public class Vertex3
{
  public float x;
  public float y;
  public float z;
  
  public Vertex3()
  {
    x = y = z = 0.0;  
  }
  
  public Vertex3(float xx, float yy, float zz)
  {
    x = xx;
    y = yy;
    z = zz;
  }
}

  // Face with 3 Vertices (Triangle)
public class Face3
{
  public Vertex3 vert0;
  public Vertex3 vert1;
  public Vertex3 vert2;
  
    // only store the index of the material
    // the index is in the array of the model's 
    // material arraylist.
  public int materialIndex;
  
  public Face3()
  {
    vert0 = new Vertex3(1.0, 0.0, 0.0);
    vert1 = new Vertex3(0.0, 1.0, 0.0);
    vert2 = new Vertex3(0.0, 0.0, 1.0);
    
    materialIndex = 0;
  }
  
  public Face3(Vertex3 vertex0, Vertex3 vertex1, Vertex3 vertex2, int material)
  {
    vert0 = vertex0;
    vert1 = vertex1;
    vert2 = vertex2;
    
    materialIndex = material;
  }
  
  public Face3(float v0x, float v0y, float v0z,
               float v1x, float v1y, float v1z,
               float v2x, float v2y, float v2z, int material)
  {
    vert0 = new Vertex3(v0x, v0y, v0z);
    vert1 = new Vertex3(v1x, v1y, v1z);
    vert2 = new Vertex3(v2x, v2y, v2z);
    
    materialIndex = material;
  }
}

  // Material that stores diffuse colors
public class Material
{
  public String name;
  public float fillR;
  public float fillG;
  public float fillB;
  
  public Material(String name)
  {
    this.name = name;
    fillR = fillG = fillB = 150;
  }
  
  public Material(String name, float r, float g, float b)
  {
    this.name = name;
    fillR = r;
    fillG = g;
    fillB = b;
  }
}

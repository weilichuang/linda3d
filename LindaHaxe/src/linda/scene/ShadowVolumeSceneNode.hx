package linda.scene;
import flash.geom.Vector3D;
import flash.Vector;
import haxe.Log;
import linda.light.Light;
import linda.math.MathUtil;
import linda.math.Matrix4;
import linda.math.Triangle3D;
import linda.math.Vector3;
import linda.math.AABBox3D;
import linda.math.Vertex;
import linda.mesh.IMesh;
import linda.mesh.MeshBuffer;
import linda.video.IVideoDriver;

class ShadowVolumeSceneNode extends SceneNode
{
    private var shadowMesh:IMesh;
	
	private var useZFailMethod:Bool;
	
	private var infinity:Float;
	
	private var indexCount:Int;
	private var vertexCount:Int;

	private var shadowVolumesUsed:Int;
	
	private var edgeCount:Int;
	
	// used for zfail method, if face is front facing
	private var faceData:Vector<Bool>;

	private var vertices:Vector<Vector3>;
	private var indices:Vector<Int>;
	private var adjacency:Vector<Int>;
	private var edges:Vector<Int>;
	
	private var box:AABBox3D;

	// a shadow volume for every light
	private var shadowVolumes:Vector<ShadowVolume>;
	/**
	 * 
	 * @param	mgr   SceneManager
	 * @param	shadowMesh 
	 * @param	?zfailMethod
	 * @param	?infinity
	 */
	public function new(mgr:SceneManager,shadowMesh:IMesh,zfailMethod:Bool=false,infinity:Float=10000.0) 
	{
		super(mgr);
		
		autoCulling = false;

		this.useZFailMethod = zfailMethod;
		this.infinity = infinity;
		
		vertices = new Vector<Vector3>();
		indices = new Vector<Int>();
		adjacency = new Vector<Int>();
		edges = new Vector<Int>();
		
		//zfail
		faceData = new Vector<Bool>();
		
		shadowVolumes = new Vector<ShadowVolume>();
		
		indexCount = 0;
		vertexCount = 0;
		edgeCount = 0;
		shadowVolumesUsed = 0;
		
		setShadowMesh(shadowMesh);
	}
	
	public function clear():Void 
	{
		vertices.length = 0;
		indices.length = 0;
		adjacency.length = 0;
		edges.length = 0;
		faceData.length = 0;
		shadowVolumes.length = 0;
	}
	
    public inline function createShadowVolume(light:Vector3):Void
    {
	    var svp:ShadowVolume;

	    // builds the shadow volume and adds it to the shadow volume list.
	    if (shadowVolumes.length > shadowVolumesUsed)
	    {
		    // get the next unused buffer
		    svp = shadowVolumes[shadowVolumesUsed];
		    if (svp.size >= indexCount*5)
		    {
				svp.count = 0;
			}
		    else
		    {
		    	svp.size = indexCount*5;
		    	svp.count = 0;
		    	svp.vertices.length = 0;
		    	svp.vertices.length = svp.size;
		    }

		    shadowVolumesUsed++;
	    }
	    else
	    {
		    // add a buffer
		    svp=new ShadowVolume();
		    // lets make a rather large shadowbuffer
		    svp.size = indexCount*5;
		    svp.count = 0;
		    svp.vertices.length = svp.size;
		    shadowVolumes.push(svp);
		    shadowVolumesUsed++;
	    }

	    var faceCount:Int = Std.int(indexCount / 3);

	    if (faceCount * 6 > edgeCount)
	    {
		    edges.length = 0;
		    edgeCount = faceCount * 6;
		    edges.length = edgeCount;
	    }

	    var ls:Vector3 = light.scale(infinity);// light scaled

	    //if (UseZFailMethod)
	    //	createZFailVolume(faceCount, numedges, light, svp);
	    //else
	    //	createZPassVolume(faceCount, numedges, light, svp, false);

	    // the createZFailVolume does currently not work 100% correctly,
	    // so we create createZPassVolume with caps if the zfail method
	    // is used
	    var numedges:Int = createZPassVolume(faceCount,light, svp);

	    for (i in 0...numedges)
	    {
		    var v1:Vector3 = vertices[edges[2*i+0]];
		    var v2:Vector3 = vertices[edges[2*i+1]];
		    var v3:Vector3 = v1.subtract(ls);
		    var v4:Vector3 = v2.subtract(ls);

		    // Add a quad (two triangles) to the vertex list
		    if (svp!=null && svp.count < svp.size-5)
		    {
			    svp.vertices[svp.count++] = v1;
			    svp.vertices[svp.count++] = v2;
			    svp.vertices[svp.count++] = v3;

			    svp.vertices[svp.count++] = v2;
			    svp.vertices[svp.count++] = v4;
			    svp.vertices[svp.count++] = v3;
		    }
	    }
    }


    public inline function createZFailVolume(faceCount:Int,light:Vector3,svp:ShadowVolume):Int
    {
		var numedges:Int = 0;
	    var ls:Vector3 = light.scale(infinity); 
		
		var wFace0:Int ;
		var wFace1:Int ;
		var wFace2:Int ;
        var triangle:Triangle3D = new Triangle3D(null, null, null);
	    // Check every face if it is front or back facing the light.
	    for (i in 0...faceCount)
	    {
		    wFace0 = indices[3 * i + 0];
		    wFace1 = indices[3 * i + 1];
		    wFace2 = indices[3 * i + 2];

		    var v0:Vector3 = vertices[wFace0];
		    var v1:Vector3 = vertices[wFace1];
		    var v2:Vector3 = vertices[wFace2];
            
			
			triangle.setTriangle(v0, v1, v2);
		    if (triangle.isFrontFacing(light))
		    {
			    faceData[i] = false;         // it's a back facing face

			    if (svp.vertices!=null && svp.count < svp.size-5)
			    {
				        // add front cap
				    svp.vertices[svp.count++] = v0;
				    svp.vertices[svp.count++] = v2;
				    svp.vertices[svp.count++] = v1;

				        // add back cap
				    svp.vertices[svp.count++] = v0.subtract(ls);
				    svp.vertices[svp.count++] = v1.subtract(ls);
				    svp.vertices[svp.count++] = v2.subtract(ls);
			    }
		    }
		    else
		    {
				faceData[i] = true;         // it's a front facing face
			}
	    }
		triangle = null;

	    for(i in 0...faceCount)
	    {
		    if (faceData[i] == true)
		    {
			    wFace0 = indices[3*i+0];
			    wFace1 = indices[3*i+1];
			    wFace2 = indices[3*i+2];

			    var adj0:Int = adjacency[3*i+0];
			    var adj1:Int = adjacency[3*i+1];
			    var adj2:Int = adjacency[3*i+2];

			    if (adj0 != -1 && faceData[adj0] == false)
			    {
				        // add edge v0-v1
			    	edges[2*numedges+0] = wFace0;
			    	edges[2*numedges+1] = wFace1;
			    	numedges++;
			    }

			    if (adj1 != -1 && faceData[adj1] == false)
			    {
			    	        // add edge v1-v2
			    	edges[2*numedges+0] = wFace1;
			    	edges[2*numedges+1] = wFace2;
			    	numedges++;
			    }

			    if (adj2 != -1 && faceData[adj2] == false)
			    {
				        // add edge v2-v0
			    	edges[2*numedges+0] = wFace2;
			    	edges[2*numedges+1] = wFace0;
			    	numedges++;
			    }
		    }
			
	    }
		return numedges;
    }


    public inline function createZPassVolume(faceCount:Int,light:Vector3,svp:ShadowVolume):Int
    {
		var numedges:Int = 0;
		
		light.scaleBy(infinity);
		
	    if (light == new Vector3(0,0,0))
		    light.x = light.y = light.z = 0.0001;
        var triangle:Triangle3D = new Triangle3D(null, null, null);
	    for (i in 0...faceCount)
	    {
		    var wFace0:Int = indices[3*i+0];
		    var wFace1:Int = indices[3*i+1];
		    var wFace2:Int = indices[3*i+2];
            
			triangle.setTriangle(vertices[wFace0], vertices[wFace1], vertices[wFace2]);
		    if (triangle.isFrontFacing(light))
		    {
			    edges[2*numedges+0] = wFace0;
			    edges[2*numedges+1] = wFace1;
			    numedges++;

			    edges[2*numedges+0] = wFace1;
			    edges[2*numedges+1] = wFace2;
			    numedges++;

			    edges[2*numedges+0] = wFace2;
			    edges[2*numedges+1] = wFace0;
			    numedges++;

			    if (svp!=null && svp.count < svp.size-5)
			    {
				    svp.vertices[svp.count++] = vertices[wFace0];
				    svp.vertices[svp.count++] = vertices[wFace2];
				    svp.vertices[svp.count++] = vertices[wFace1];

				    svp.vertices[svp.count++] = vertices[wFace0].subtract(light);
				    svp.vertices[svp.count++] = vertices[wFace1].subtract(light);
				    svp.vertices[svp.count++] = vertices[wFace2].subtract(light);
			    }
		    }
	    }
		triangle = null;
		
		return numedges;
    }


	
	public function setShadowMesh(mesh:IMesh):Void 
	{
		this.shadowMesh = mesh;
	}
	
	

    public function updateShadowVolumes():Void 
    {
	    var oldIndexCount:Int = indexCount;
	    var oldVertexCount:Int = vertexCount;

	    vertexCount = 0;
	    indexCount = 0;
	    shadowVolumesUsed = 0;

	    var mesh:IMesh = shadowMesh;
	    if (mesh == null) return;
		

	    // calculate total amount of vertices and indices

	    var totalVerticeCount:Int = 0;
	    //var totalIndiceCount:Int = 0;
	    var bufcnt:Int = mesh.getMeshBufferCount();
	    for (i in 0...bufcnt)
	    {
		    var buf:MeshBuffer = mesh.getMeshBuffer(i);
		    //totalIndiceCount += buf.indices.length;
		    totalVerticeCount += buf.vertices.length;
	    }
		
		//如果顶点数大于已存在的点，则添加
		var len:Int = vertices.length;
		if (totalVerticeCount > len)
		{
			for ( j in len...totalVerticeCount)
			{
				vertices[j] = new Vector3();
			}
		}

	    // copy mesh
	    for (i in 0...bufcnt)
	    {
	    	var buf:MeshBuffer = mesh.getMeshBuffer(i);

	    	var idxcnt:Int = buf.indices.length;
			for (j in 0...idxcnt)
			{
	    		indices[indexCount++] = buf.indices[j] + vertexCount;
			}

	    	var vtxcnt:Int = buf.vertices.length;
	    	for (j in 0...vtxcnt) 
			{
				var v0:Vertex = buf.vertices[j];
				var v1:Vector3 = vertices[vertexCount++];
				v1.x = v0.x;
				v1.y = v0.y;
				v1.z = v0.z;
			}
	    }

	    // recalculate adjacency if necessary
	    if (oldVertexCount != vertexCount && oldIndexCount != indexCount && useZFailMethod)
		{
		    calculateAdjacency(0.0001);
		}

	    // create as much shadow volumes as there are lights but
	    // do not ignore the max light settings.
        var driver:IVideoDriver=sceneManager.getVideoDriver();
	    var lightCount:Int = driver.getLightCount();
		
	    var mat:Matrix4 = parent.getAbsoluteMatrix().clone();
		mat.inverse();
		
	    var ps:Vector3 = parent.getAbsolutePosition();
	    var ls:Vector3;
	    // TODO: Only correct for point lights.
		var light:Light;
	    for (i in 0...lightCount)
	    {
		    light = driver.getLight(i);
		    ls = light.position;
			
		    if (light.castShadows) // && (ls.subtract(ps).getLengthSquared() <= (light.radius*light.radius*4.0)))
		    {
			    mat.transformVector(ls);
			    createShadowVolume(ls);
		    }
	    }
		
		mat = null;
		ps = null;
    }


    // pre render method
    override public function onRegisterSceneNode():Void
    {        
	    if (visible)
	    {
	        sceneManager.registerNodeForRendering(this,SceneNode.SHADOW);
	        super.onRegisterSceneNode();
	    }
    }


    // renders the node.
    override public function render():Void
    {
		//updateShadowVolumes();
		
	    var driver:IVideoDriver = sceneManager.getVideoDriver();

	    if (driver==null || shadowVolumesUsed==0 ) return;

	    driver.setTransformWorld(parent.getAbsoluteMatrix());

	    for (i in 0...shadowVolumesUsed)
	    {
		    driver.drawStencilShadowVolume(shadowVolumes[i], useZFailMethod);
		}
    }


    // returns the axis aligned bounding box of this node
    override public function getBoundingBox():AABBox3D
    {
	        return box;
    }


    // Generates adjacency information based on mesh indices.
	public inline function calculateAdjacency(epsilon:Float=0.0001):Void
    {
	    adjacency.length = 0;
		adjacency.length = indexCount;

	    epsilon *= epsilon;

	    var t:Float = 0;

	    // go through all faces and fetch their three neighbours
		var f:Int = 0;
		while (f < indexCount)
		{
		    for (edge in 0...3)
		    {
			    var v1:Vector3 = vertices[indices[f+edge]];
			    var v2:Vector3 = vertices[indices[f+Std.int((edge+1)%3)]];

			    // now we search an_O_ther _F_ace with these two
			    // vertices, which is not the current face.

			    var of:Int=0;
                while (f < indexCount)
                {
					if (of != f)
				    {
					    var cnt1:Int = 0;
					    var cnt2:Int = 0;

					    for (e in 0...3)
					    {
						    t = Vector3.distanceSquared(v1,vertices[indices[of+e]]);
						    if (t <= MathUtil.ROUNDING_ERROR)   cnt1++;

						    t = Vector3.distanceSquared(v2,vertices[indices[of+e]]);
						    if (t <= MathUtil.ROUNDING_ERROR)   cnt2++;
					    }

					    if (cnt1 == 1 && cnt2 == 1) break;
				    }
					
					if (of == indexCount)
					{
						adjacency[f + edge] = f;
					} else
				    {
						adjacency[f + edge] = Std.int(of / 3);
					}
					
					of += 3;
                }
		    }
			f += 3;
	    }
    }
}
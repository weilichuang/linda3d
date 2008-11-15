package linda.scene
{
	import __AS3__.vec.Vector;
	
	import linda.material.Material;
	import linda.material.Texture;
	import linda.math.AABBox3D;
	import linda.math.Matrix4;
	import linda.math.Vertex;
	import linda.video.IVideoDriver;

	public class SkyBoxSceneNode extends SceneNode
	{
		private var topVertices:Vector.<Vertex>;
		private var topMaterial:Material;
		
		private var bottomVertices:Vector.<Vertex>;
		private var bottomMaterial:Material;
		
		private var leftVertices:Vector.<Vertex>;
		private var leftMaterial:Material;
		
		private var rightVertices:Vector.<Vertex>;
		private var rightMaterial:Material;
		
		private var frontVertices:Vector.<Vertex>;
		private var frontMaterial:Material;
		
		private var backVertices:Vector.<Vertex>;
		private var backMaterial:Material;
		
		private var box:AABBox3D;
		
		private var indices:Vector.<int>;
		
		private var materials:Vector.<Material>;
		public function SkyBoxSceneNode(mgr:SceneManager,top:Texture, 
			                            bottom:Texture,
			                            left:Texture,
			                            right:Texture, 
			                            front:Texture, 
			                            back:Texture)
		{
			super(mgr);
			debug=false;
			autoCulling=false;
			
            box=new AABBox3D();
            
            materials=new Vector.<Material>();

	        // create indices
            indices=new Vector.<int>(0,1,2,0,2,3);

	        // create front side
	        
	        var l:Number=999.;

	        frontMaterial = new Material();
	        frontMaterial.wireframe=false;
	        frontMaterial.gouraudShading=false;
	        frontMaterial.lighting=false;
	        frontMaterial.texture1=front;
	         materials.push(frontMaterial);
	         
	         
	        frontVertices=new Vector.<Vertex>(4);
	        frontVertices[0] = new Vertex(-l,-l,-l, 0,0,1, 0xFFFFFFFF, 1, 1);
	        frontVertices[1] = new Vertex( l,-l,-l, 0,0,1, 0xFFFFFFFF, 0, 1);
	        frontVertices[2] = new Vertex( l, l,-l, 0,0,1, 0xFFFFFFFF, 0, 0);
	        frontVertices[3] = new Vertex(-l, l,-l, 0,0,1, 0xFFFFFFFF, 1, 0);

	        // create left side

	        leftMaterial = new Material();
	        leftMaterial.wireframe=false;
	        leftMaterial.gouraudShading=false;
	        leftMaterial.lighting=false;
	        leftMaterial.texture1=left;
	        materials.push(leftMaterial);
	        leftVertices=new Vector.<Vertex>(4);
	        leftVertices[0] = new Vertex( l,-l,-l, -1,0,0, 0xFFFFFFFF, 1, 1);
	        leftVertices[1] = new Vertex( l,-l, l, -1,0,0, 0xFFFFFFFF, 0, 1);
	        leftVertices[2] = new Vertex( l, l, l, -1,0,0, 0xFFFFFFFF, 0, 0);
	        leftVertices[3] = new Vertex( l, l,-l, -1,0,0, 0xFFFFFFFF, 1, 0);

	        // create back side

	        backMaterial = new Material();
	        backMaterial.wireframe=false;
	        backMaterial.gouraudShading=false;
	        backMaterial.lighting=false;
	        backMaterial.texture1=back;
	        materials.push(backMaterial);
	        backVertices=new Vector.<Vertex>(4);
	        backVertices[0]  = new Vertex( l,-l, l, 0,0,-1, 0xFFFFFFFF, 1, 1);
	        backVertices[1]  = new Vertex(-l,-l, l, 0,0,-1, 0xFFFFFFFF, 0, 1);
	        backVertices[2]  = new Vertex(-l, l, l, 0,0,-1, 0xFFFFFFFF, 0, 0);
	        backVertices[3]  = new Vertex( l, l, l, 0,0,-1, 0xFFFFFFFF, 1, 0);

	        // create right side

	        rightMaterial = new Material();
	        rightMaterial.wireframe=false;
	        rightMaterial.gouraudShading=false;
	        rightMaterial.lighting=false;
	        rightMaterial.texture1=right;
	        materials.push(rightMaterial);
	        rightVertices=new Vector.<Vertex>(4);
	        rightVertices[0] = new Vertex(-l,-l, l, 1,0,0, 0xFFFFFFFF, 1, 1);
	        rightVertices[1] = new Vertex(-l,-l,-l, 1,0,0, 0xFFFFFFFF, 0, 1);
	        rightVertices[2] = new Vertex(-l, l,-l, 1,0,0, 0xFFFFFFFF, 0, 0);
	        rightVertices[3] = new Vertex(-l, l, l, 1,0,0, 0xFFFFFFFF, 1, 0);

	        // create top side

	        topMaterial = new Material();
	        topMaterial.wireframe=false;
	        topMaterial.gouraudShading=false;
	        topMaterial.lighting=false;
	        topMaterial.texture1=top;
	        materials.push(topMaterial);
	        topVertices=new Vector.<Vertex>(4);
	        topVertices[0] = new Vertex( l, l,-l, 0,-1,0, 0xFFFFFFFF, 1, 1);
	        topVertices[1] = new Vertex( l, l, l, 0,-1,0, 0xFFFFFFFF, 0, 1);
	        topVertices[2] = new Vertex(-l, l, l, 0,-1,0, 0xFFFFFFFF, 0, 0);
	        topVertices[3] = new Vertex(-l, l,-l, 0,-1,0, 0xFFFFFFFF, 1, 0);

	        // create bottom side

	        bottomMaterial = new Material();
	        bottomMaterial.wireframe=false;
	        bottomMaterial.gouraudShading=false;
	        bottomMaterial.lighting=false;
	        bottomMaterial.texture1=bottom;
	        materials.push(bottomMaterial);
	        bottomVertices=new Vector.<Vertex>(4);
	        bottomVertices[0] = new Vertex( l,-l, l, 0,1,0, 0xFFFFFFFF, 0, 0);
	        bottomVertices[1] = new Vertex( l,-l,-l, 0,1,0, 0xFFFFFFFF, 1, 0);
	        bottomVertices[2] = new Vertex(-l,-l,-l, 0,1,0, 0xFFFFFFFF, 1, 1);
	        bottomVertices[3] = new Vertex(-l,-l, l, 0,1,0, 0xFFFFFFFF, 0, 1);
		}
		override public function destroy():void
		{
			super.destroy();
			topVertices=null;
			bottomVertices=null;
			leftVertices=null;
			rightVertices=null;
			frontVertices=null;
			backVertices=null;
			
			topMaterial=null;
			bottomMaterial=null;
			leftMaterial=null;
			rightMaterial=null;
			frontMaterial=null;
			backMaterial=null;
			
			
			materials=null;
			indices=null;
			box=null;
			
			_tmpMatrix=null;
		}
		private var _tmpMatrix:Matrix4=new Matrix4();
	    override public function render():void
	    {
	    	var driver:IVideoDriver = sceneManager.getVideoDriver();
	        var camera:CameraSceneNode = sceneManager.getActiveCamera();

	        if (!camera || !driver) return;

            _tmpMatrix.setTranslation(camera.getAbsolutePosition());
            
            var temp_pc_dist:Number = driver.getPerspectiveCorrectDistance();
			driver.setPerspectiveCorrectDistance(100000);

		    driver.setTransformWorld(_tmpMatrix);
            //front
			driver.setMaterial(frontMaterial);
			driver.drawIndexedTriangleList(frontVertices,4,indices,6);
			//left
			driver.setMaterial(leftMaterial);
			driver.drawIndexedTriangleList(leftVertices,4,indices,6);
			//back
			driver.setMaterial(backMaterial);
			driver.drawIndexedTriangleList(backVertices,4,indices,6);
			//right
			driver.setMaterial(rightMaterial);
			driver.drawIndexedTriangleList(rightVertices,4,indices,6);
			//top
			driver.setMaterial(topMaterial);
			driver.drawIndexedTriangleList(topVertices,4,indices,6);
			//bottom
			driver.setMaterial(bottomMaterial);
			driver.drawIndexedTriangleList(bottomVertices,4,indices,6);
			
			driver.setPerspectiveCorrectDistance(temp_pc_dist);
	    }
	    override public function onPreRender():void
	    {
	    	if(visible)
	    	{
	    		sceneManager.registerNodeForRendering(this,SKYBOX);
	    		super.onPreRender();
	    	}
	    }
	    override public function getMaterial(i:int=0):Material
	    {
	    	if(i<0 || i>=6) return null;
	    	return materials[i];
	    }
	    override public function getMaterialCount():int
	    {
	    	return 6;
	    }
	    override public function getBoundingBox():AABBox3D
	    {
	    	return box;
	    }
	}
}
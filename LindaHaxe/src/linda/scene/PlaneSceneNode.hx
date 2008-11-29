package linda.scene;

        import flash.Vector;
		import haxe.Log;
        
        import linda.math.Vector3;
        import linda.math.AABBox3D;
        import linda.math.Vertex;
		
		import linda.material.Material;
        import linda.video.IVideoDriver;
		
        class PlaneSceneNode extends SceneNode
        {
                private var box      : AABBox3D;
                private var indices  : Vector<Int>;
                private var vertices : Vector<Vertex>;
                private var material : Material;
                public function new (mgr:SceneManager,width : Float,height : Float,?segsW : Int=2, ?segsH : Int=2)
                {
                        super (mgr);
                        
                        indices = new Vector<Int>();
                        material = new Material ();
                        vertices=new Vector<Vertex>();
                        box = new AABBox3D ();

                        createPlane (width,height,segsW,segsH);
                }
                private function createPlane (width : Float,height : Float,segsW : Int, segsH : Int) : Void
		        {
			        if (segsW < 1) segsW = 1;
			        if (segsH < 1) segsH = 1;
					
			        var perH : Float = height / segsH;
			        var perW : Float = width  / segsW;
			        var wid2 : Float = width  * 0.5;
			        var hei2 : Float = height * 0.5;
                    
					vertices.length = 0;
			        for (i in 0...(segsH+1))
			        {
				        for (j in 0...(segsW+1))
				        {
					        var vertex : Vertex = new Vertex ();
					        vertex.x = j * perW - wid2;
					        vertex.y = i * perH - hei2;
					        vertex.z = 0.;
					        vertex.u = j / segsW;
					        vertex.v = i / segsH;

					        if(i==0 && j==0)
					        {
					        	box.resetVertex(vertex);
					        }else
					        {
					            box.addVertex(vertex);
					        }
					        vertices.push(vertex);
				        }
			        }
			        // indices
					indices.length = 0;
			        var segsW1:Int=segsW+1;
			        for (i in 0...segsH)
			        {
				        for (j in 0...segsW)
				        {
					        indices.push(i * segsW1 + j);
							indices.push(i * segsW1 + j + 1);
							indices.push((i + 1) * segsW1 + j + 1);
							indices.push(i * segsW1 + j);
							indices.push((i + 1)* segsW1 + j + 1);
							indices.push((i + 1) * segsW1 + j);
				        }
			        }
		        }
                override public function destroy():Void
		        {
		        	vertices=null;
			        indices=null;
			        material=null;
			        box=null;
			        super.destroy();
		        }
                override  public function render () : Void
                {
                    var driver : IVideoDriver = sceneManager.getVideoDriver ();
                    driver.setMaterial (material);
                    driver.setTransformWorld(_absoluteMatrix);
                    driver.drawIndexedTriangleList (vertices, vertices.length, indices, indices.length);
                }
                override public function getBoundingBox () : AABBox3D
                {
                    return box;
                }
                override  public function onPreRender () : Void
                { 
                   if (visible)
                   {
                       if(material.transparenting)
                       {
                          sceneManager.registerNodeForRendering (this, SceneNode.TRANSPARENT);
                       }else
                       {
                          sceneManager.registerNodeForRendering(this,SceneNode.SOLID);
                       }
                       super.onPreRender ();
                   }
                        
                }
                override  public function getMaterial (?i : Int=0) : Material
                {
                   return material;
                }
                override public function getMaterialCount () : Int
                {
                   return 1;
                }
        }

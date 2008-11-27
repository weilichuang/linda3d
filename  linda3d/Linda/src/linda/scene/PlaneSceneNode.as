package linda.scene
{
        import __AS3__.vec.Vector;
        
        import flash.geom.Vector3D;
        
        import linda.material.Material;
        import linda.math.AABBox3D;
        import linda.math.Vertex;
        import linda.video.IVideoDriver;
        public class PlaneSceneNode extends SceneNode
        {
                private var box : AABBox3D;
                private var indices : Vector.<int>;
                private var vertices : Vector.<Vertex>;
                private var material : Material;
                public function PlaneSceneNode (mgr:SceneManager,width : Number,height : Number,segsW : int=2, segsH : int=2)
                {
                        super (mgr);
                        
                        indices = new Vector.<int>();
                        material = new Material ();
                        vertices=new Vector.<Vertex>();
                        box = new AABBox3D ();

                        createPlane (width,height,segsW,segsH);
                }
                private function createPlane (width : Number,height : Number,segsW : int, segsH : int) : void
		        {
			        if (segsW < 1) segsW = 1;
			        if (segsH < 1) segsH = 1;
			        var perH : Number = height / segsH;
			        var perW : Number = width / segsW;
			        var wid2 : Number = width * 0.5;
			        var hei2 : Number = height * 0.5;

			        for (var i : int = 0; i <= segsH; i+=1)
			        {
				        for (var j : int = 0; j <= segsW; j+=1)
				        {
					        var vertex : Vertex = new Vertex ();
					        vertex.x = j * perW - wid2;
					        vertex.y = i * perH - hei2;
					        vertex.z = 0;
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
			        var segsW1:int=segsW+1;
			        for (i = 0; i < segsH; i+=1)
			        {
				        for (j = 0; j < segsW; j+=1)
				        {
					        indices.push (i * segsW1 + j, (i) * segsW1 + j + 1, (i + 1) * segsW1 + j + 1);
					        indices.push (i * segsW1 + j, (i + 1)* segsW1 + j + 1, (i + 1) * segsW1 + j);
				        }
			        }
		        }
                override public function destroy():void
		        {
		        	vertices=null;
			        indices=null;
			        material=null;
			        box=null;
			        super.destroy();
		        }
                override public function render () : void
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
                override public function onPreRender () : void
                { 
                   if (visible)
                   {
                       if(material.transparenting)
                       {
                          sceneManager.registerNodeForRendering (this, SOLID);
                       }else
                       {
                          sceneManager.registerNodeForRendering(this,TRANSPARENT);
                       }
                       super.onPreRender ();
                   }
                        
                }
                override public function getMaterial (i : int=0) : Material
                {
                   return material;
                }
                override public function getMaterialCount () : int
                {
                   return 1;
                }
        }
}

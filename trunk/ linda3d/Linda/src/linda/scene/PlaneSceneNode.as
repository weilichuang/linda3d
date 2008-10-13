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
                public function PlaneSceneNode (width:Number,height:Number, pos : Vector3D = null, rotation : Vector3D = null,scale:Vector3D=null)
                {
                        super ( pos, rotation, scale);
                        
                        indices = new Vector.<int>(0, 1, 2,0,2,3);
                        material = new Material ();
                        var color : uint = 0x0066FF;
                        vertices=new Vector.<Vertex>();
                        vertices [0] = new Vertex (0, 0, 0, 1, 0, 0, 0xFF0000, 0, 1);
                        vertices [1] = new Vertex (1, 0, 0, 0, 1, 0, 0x00FF00, 1, 1);
                        vertices [2] = new Vertex (1, 1, 0, 0, 0, 1, 0xFF0000, 1, 0);
                        vertices [3] = new Vertex (0, 1, 0, 0, 1, 0, 0x0000FF, 0, 1);

                        box = new AABBox3D ();
                        for (var i : int = 0; i < 4; ++ i)
                        {
                                var vertex : Vertex = vertices [i];
                                vertex.x -= 0.5;
                                vertex.y -= 0.5;
                                vertex.x *= width;
                                vertex.y *= height;
                                box.addInternalPointXYZ (vertex.x, vertex.y, vertex.z);
                        }
                }
                override public function destroy():void
		        {
			        super.destroy();
			        vertices=null;
			        indices=null;
			        material=null;
			        box=null;
		        }
                override public function render () : void
                {
                        var driver : IVideoDriver = sceneManager.getVideoDriver ();
                        if(!driver) return;
                        driver.setMaterial (material);
                        driver.setTransformWorld(_absoluteMatrix);
                        driver.drawIndexedTriangleList (vertices, 4, indices, 6);
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
                                         sceneManager.registerNodeForRendering (this, SceneNodeType.SOLID);
                                }else
                                {
                                        sceneManager.registerNodeForRendering(this,SceneNodeType.TRANSPARENT);
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

package ;
import flash.display.MovieClip;
import flash.display.StageScaleMode;
import flash.events.KeyboardEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.ui.ContextMenu;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.display.Loader;
import flash.net.URLRequest;
import flash.ui.Mouse;
import flash.Vector;
import flash.Lib;
import haxe.Log;
import linda.Linda;
import linda.material.MipMapLevel;
import linda.material.Texture;
import linda.math.Dimension2D;
import linda.math.Matrix4;
import linda.math.Vector3;
import linda.math.MathUtil;
import flash.Memory;
import flash.utils.ByteArray;
import linda.material.Material;
import linda.mesh.md2.AnimatedMeshMD2;
import linda.mesh.IAnimatedMesh;
import linda.mesh.IMesh;
import linda.mesh.loader.Max3DSMeshFileLoader;
import linda.mesh.loader.MD2MeshFileLoader;
import linda.mesh.Mesh;
import linda.mesh.MeshBuffer;
import linda.mesh.objects.Cone;
import linda.mesh.objects.Cube;
import linda.mesh.objects.Cylinder;
import linda.mesh.objects.RegularPolygon;
import linda.mesh.objects.Sphere;
import linda.mesh.objects.Torus;
import linda.scene.CameraSceneNode;
import linda.scene.LightSceneNode;
import linda.scene.MeshSceneNode;
import linda.scene.MeshBufferSceneNode;
import linda.scene.PlaneSceneNode;
import linda.scene.SceneManager;
import linda.scene.SceneNode;
import linda.video.IVideoDriver;
import linda.video.VideoSoftware32;
import linda.video.VideoSoftware;

import linda.scene.AnimatedMeshSceneNode;
class MD2Test 
{
	private var node:AnimatedMeshSceneNode;
	private var manager:SceneManager;
	private var driver:IVideoDriver;
	private var camera:CameraSceneNode;
	private var light:LightSceneNode;
	private var target:Bitmap;
	
	private var texture:Texture;
	
	private var t:Int;

	static function main() 
	{
		var m:MD2Test = new MD2Test();
	}
	
	public function new()
	{
		prepare();
		
		texture = new Texture(Lib.attach("Faerie"),false);
		
		driver = new VideoSoftware(new Dimension2D(400, 400));
        driver.setPerspectiveCorrectDistance(400);
        driver.setMipMapDistance(100);
            
		manager=new SceneManager(driver);
        manager.setAmbient(0x333333);

		camera=new CameraSceneNode(manager,new Vector3());
        camera.setPosition(new Vector3(0., 150., 300.));
			
		manager.addChild(camera);
		manager.setActiveCamera(camera);

		node = new AnimatedMeshSceneNode(manager, null, false);
		
		light=new LightSceneNode(manager,0xff6600,200.,2);
		light.setPosition(new Vector3(0., 150., 200.));
        
		
		manager.addChild(light);
        
		//var contextMenu:ContextMenu = new ContextMenu();
		//Lib.current.contextMenu = contextMenu;
		//Lib.current.contextMenu.hideBuiltInItems();
		//Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		Lib.current.addEventListener(Event.ENTER_FRAME,_onEnterFrame);
		Lib.current.addChild(driver.getRenderTarget());

		var status:StatusPanel = new StatusPanel(100, 50);
		status.x = 400 - status.width - 1;
		Lib.current.addChild(status);

		Log.setColor(0xffffff);
		t = Lib.getTimer();
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, __moveNode);
		
		loader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.BINARY;
		loader.addEventListener(Event.COMPLETE, __loadmd2);
		loader.load(new URLRequest("media/faerie.md2"));
	}
	private var loader:URLLoader;
	private function __loadmd2(e:Event):Void 
	{
		var data:ByteArray = Lib.as(loader.data, ByteArray);
		var maxloader:MD2MeshFileLoader = new MD2MeshFileLoader();
		var mesh:IAnimatedMesh = maxloader.createAnimatedMesh(data);
		data.clear();
		data = null;
		maxloader = null;
		
		node.setAnimateMesh(mesh);
		node.setAnimationSpeed(40);
		node.setScale(new Vector3(5, 5, 5));
		node.setMaterialFlag(Material.GOURAUD_SHADE, true);
		node.setMaterialFlag(Material.LIGHT, true);
		node.setMaterialTexture(texture);
		manager.addChild(node);
		
		var node1:AnimatedMeshSceneNode = new AnimatedMeshSceneNode(manager,mesh,false);
		node1.setAnimationSpeed(20);
		node1.setMaterialFlag(Material.GOURAUD_SHADE, true);
		node1.setMaterialFlag(Material.LIGHT, true);
		node1.setMaterialFlag(Material.BACKFACE, false);
		node1.setMaterialFlag(Material.FRONTFACE, true);
		//node1.setMaterialTexture(texture);
		node1.z = 50;
		node.addChild(node1);
		
		var node2:AnimatedMeshSceneNode = new AnimatedMeshSceneNode(manager,mesh,false);
		node2.setAnimationSpeed(30);
		node2.setMaterialFlag(Material.GOURAUD_SHADE, true);
		node2.setMaterialFlag(Material.LIGHT, true);
		node2.setMaterialEmissiveColor(0x009900);
		//node1.setMaterialTexture(texture);
		node2.z = -50;
		node.addChild(node2);
		
		
		var node3:AnimatedMeshSceneNode = new AnimatedMeshSceneNode(manager,mesh,false);
		node3.setAnimationSpeed(40);
		node3.setMaterialFlag(Material.GOURAUD_SHADE, true);
		node3.setMaterialFlag(Material.LIGHT, true);
		node3.setMaterialFlag(Material.TRANSPARTENT, false);
		node3.setMaterialAlpha(0.6);
		node3.setMaterialTexture(texture);
		node3.x = -50;
		node.addChild(node3);
		
		
		var node4:AnimatedMeshSceneNode = new AnimatedMeshSceneNode(manager,mesh,false);
		node4.setAnimationSpeed(50);
		node4.setMaterialFlag(Material.GOURAUD_SHADE, false);
		node4.setMaterialFlag(Material.LIGHT, true);
		node4.setMaterialFlag(Material.WIREFRAME, true);
		node4.x = 50;
		node.addChild(node4);
	}
	
	
	private function __moveNode(e:KeyboardEvent):Void 
	{
		if (e.keyCode == 38)
		{
			node.z -= 15;
		}else if (e.keyCode == 40)
		{
			node.z += 15;
		}
	}

	private function _onEnterFrame(e:Event):Void
	{
		node.rotationY  += MathUtil.DEGTORAD;
		light.rotationY -= MathUtil.DEGTORAD;
		if(Lib.getTimer()  -  t >  4000)
		{
			t=Lib.getTimer();
			light.light.diffuseColor.color = Std.int(Math.random() * 0xffffff);
		}
		driver.beginScene();
		manager.drawAll();
		driver.endScene(); 
		//Log.trace(driver.getTriangleCountDrawn());
	}
	
	public function prepare():Void {
       var b:ByteArray = new ByteArray();
       b.length = 1024;
       Memory.select(b);
    }
}
package ;
import flash.display.StageScaleMode;
import flash.ui.ContextMenu;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.display.Loader;
import flash.net.URLRequest;
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

import linda.scene.AnimateMeshSceneNode;
class Main 
{
	private var node:SceneNode;
	private var node4:SceneNode;
	private var node2:SceneNode;
	private var node3:SceneNode;
	private var node1:SceneNode;
	private var manager:SceneManager;
	private var driver:IVideoDriver;
	private var camera:CameraSceneNode;
	private var light:LightSceneNode;
	private var target:Bitmap;
	
	private var texture:Texture;
	
	private var t:Int;
	
	private var colors:flash.Vector<UInt>;
	
	private var cube1:Cube;
	
	static function main() 
	{
		var m:Main = new Main();
	}
	
	public function new()
	{
		prepare();
		
		var bitmapData:BitmapData = new BitmapData(Std.int(loader.width), Std.int(loader.height), true, 0x0);
		bitmapData.draw(loader);
		texture = new Texture(bitmapData,false);
        bitmapData.dispose();
		
		driver = new VideoSoftware(new Dimension2D(500, 500));
        driver.setPerspectiveCorrectDistance(500);
        driver.setMipMapDistance(400);
            
		manager=new SceneManager(driver);
        manager.setAmbient(0x444444);

		camera=new CameraSceneNode(manager,new Vector3());
        camera.setPosition(new Vector3(0., 150., 300.));
			
		manager.addChild(camera);
		manager.setActiveCamera(camera);
		
		colors=new Vector<UInt>();
		for (i in 0...12)
		{
			colors[i] = Std.int(Math.random()*0xffffff);
		}
		
		var cube0:Cube = new Cube(250, 250, 250);
		cube1 = new Cube(100, 100, 100);
		cube1.setColor(colors);
		cube1.material.wireframe = true;

		node = new MeshBufferSceneNode(manager, new Sphere(100,20));
		node.setMaterialFlag(Material.GOURAUD_SHADE, true);
		node.setMaterialFlag(Material.LIGHT, true);
		node.setMaterialTexture(texture);

		
		node2 = new MeshBufferSceneNode(manager, cube0,false);
		node2.setMaterialFlag(Material.GOURAUD_SHADE, false);
		node2.setMaterialFlag(Material.LIGHT, true);
		node2.setMaterialFlag(Material.TRANSPARTENT, true);
		node2.setMaterialFlag(Material.WIREFRAME, false);
		node2.setMaterialAlpha(0.7);
		//node2.debug = true;
        
		
		node3 = new MeshBufferSceneNode(manager, cube1,false);
		node3.setMaterialFlag(Material.GOURAUD_SHADE, true);
		//node3.setMaterialFlag(Material.LIGHT, true);
		node3.setMaterialFlag(Material.TRANSPARTENT, false);
		node3.setMaterialFlag(Material.WIREFRAME, false);
		node3.setMaterialAlpha(0.6);
		node3.z = 150;
		//node3.debug = true;
		node.addChild(node3);
		
		node4 = new MeshBufferSceneNode(manager, cube1,true);
		node4.setMaterialFlag(Material.LIGHT, true);
		node4.z = -150;
		//node4.debug = true;
		node.addChild(node4);
		
		node1 = new MeshBufferSceneNode(manager, cube1,true);
		node1.setMaterialFlag(Material.LIGHT, false);
		node1.setMaterialEmissiveColor(0x0000ff);
		node1.setMaterialFlag(Material.BACKFACE, false);
		node1.setMaterialFlag(Material.WIREFRAME, true);
		node1.y = 150;
		//node1.debug = true;
		node.addChild(node1);

		light=new LightSceneNode(manager,0xff6600,200.,1);
		light.setPosition(new Vector3(0., 100., 200.));
		light.setAmbientColor(0x00ff00);

		manager.addChild(node);
		manager.addChild(node2);
		manager.addChild(light);
        
		var contextMenu:ContextMenu = new ContextMenu();
		Lib.current.contextMenu = contextMenu;
		Lib.current.contextMenu.hideBuiltInItems();
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		Lib.current.addEventListener(Event.ENTER_FRAME,_onEnterFrame);
		Lib.current.addChild(driver.getRenderTarget());
		
		
		var status:StatusPanel = new StatusPanel(100, 50);
		status.x = 500 - status.width - 1;
		Lib.current.addChild(status);

		Log.setColor(0xffffff);
		t = Lib.getTimer();
	}

	private function _onEnterFrame(e:Event):Void
	{
		node.rotationY  += 1;
		node2.rotationY -= 2;
		light.rotationY -= 1;
		if(Lib.getTimer()  -  t >  4000)
		{
			t=Lib.getTimer();
			light.light.diffuseColor.color = Std.int(Math.random() * 0xffffff);
			for (i in 0...12)
			{
				colors[i] = Std.int(Math.random()*0xffffff);
			}
			cube1.setColor(colors);
		}
		driver.beginScene();
		manager.drawAll();
		driver.endScene();
	}
	public function prepare():Void {
       var b:ByteArray = new ByteArray();
       b.length = 1024;
       Memory.select(b);
    }

}
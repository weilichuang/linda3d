package ;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.Vector;
import flash.Lib;
import haxe.Log;
import linda.material.Texture;
import linda.math.Dimension2D;
import linda.math.Matrix4;
import linda.math.Vector3;
import linda.math.MathUtil;
import flash.Memory;
import flash.utils.ByteArray;
import linda.material.Material;
import linda.mesh.objects.Cone;
import linda.mesh.objects.Cube;
import linda.mesh.objects.Cylinder;
import linda.mesh.objects.RegularPolygon;
import linda.mesh.objects.Sphere;
import linda.mesh.objects.Torus;
import linda.scene.CameraSceneNode;
import linda.scene.LightSceneNode;
import linda.scene.MeshSceneNode;
import linda.scene.PlaneSceneNode;
import linda.scene.SceneManager;
import linda.scene.SceneNode;
import linda.video.IVideoDriver;
import linda.video.VideoSoftware32;
import linda.video.VideoSoftware;
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
	
	private var t:Int;
	
	static function main() 
	{
		var m:Main = new Main();
	}
	
	public function new()
	{
		prepare();
		
		driver = new VideoSoftware(new Dimension2D(500, 500));
        driver.setPerspectiveCorrectDistance(500);
        driver.setMipMapDistance(400);
            
		manager=new SceneManager(driver);
        manager.setAmbient(0x000000);

		camera=new CameraSceneNode(manager,new Vector3());
        camera.setPosition(new Vector3(0., 150., 300.));
			
		manager.addChild(camera);
		manager.setActiveCamera(camera);
		
		var cube0:Cube = new Cube(250, 250, 250);
		var cube1:Cube = new Cube(100, 100, 100);

		node = new MeshSceneNode(manager, new Sphere(100,20));
		node.setMaterialFlag(Material.GOURAUD_SHADE, false);
		node.setMaterialFlag(Material.LIGHT, true);
		node.setMaterialEmissiveColor(0x000099);

		
		node2 = new MeshSceneNode(manager, cube0);
		node2.setMaterialFlag(Material.GOURAUD_SHADE, true);
		node2.setMaterialFlag(Material.LIGHT, true);
		node2.setMaterialFlag(Material.TRANSPARTENT,true);
		node2.setMaterialAlpha(0.8);
        
		
		node3 = new MeshSceneNode(manager, cube1);
		node3.setMaterialFlag(Material.GOURAUD_SHADE, true);
		node3.setMaterialFlag(Material.LIGHT, true);
		node3.setMaterialEmissiveColor(0x990000);
		node3.z = 150;
		node.addChild(node3);
		
		node4 = new MeshSceneNode(manager, cube1);
		node4.setMaterialFlag(Material.LIGHT, true);
		node4.setMaterialEmissiveColor(0x007700);
		node4.setMaterialFlag(Material.WIREFRAME, true);
		node4.z = -150;
		node.addChild(node4);
		
		node1 = new MeshSceneNode(manager, cube1);
		node1.setMaterialFlag(Material.LIGHT, false);
		node1.setMaterialEmissiveColor(0x0000ff);
		node1.setMaterialFlag(Material.BACKFACE, false);
		node1.setMaterialFlag(Material.WIREFRAME, true);
		node1.y = 150;
		node.addChild(node1);

		light=new LightSceneNode(manager,0xff6600,200.,1);
		light.setPosition(new Vector3(0., 100., 200.));
		
		manager.addChild(node);
		manager.addChild(node2);
		manager.addChild(light);

		Lib.current.addEventListener(Event.ENTER_FRAME,_onEnterFrame);
		Lib.current.addChild(driver.getRenderTarget());
		Lib.current.addChild(new StatusPanel(100, 50));
        
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
			light.light.diffuseColor.color=Std.int(Math.random()*0xffffff);
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
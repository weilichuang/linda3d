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
	private var node1:SceneNode;
	private var node2:SceneNode;
	private var manager:SceneManager;
	private var driver:IVideoDriver;
	private var camera:CameraSceneNode;
	private var light:LightSceneNode;
	private var target:Bitmap;
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
        manager.setAmbient(0x009900);

		camera=new CameraSceneNode(manager,new Vector3());
        camera.setPosition(new Vector3(0., 100., 300.));
			
		manager.addChild(camera);
		manager.setActiveCamera(camera);
		
		//var bitmapData:BitmapData = new BitmapData(100, 100, false, 0x990000);
		//var texture:Texture = new Texture(bitmapData);

		node = new MeshSceneNode(manager, new Sphere(100,10));
		node.setMaterialFlag(Material.GOURAUD_SHADE, true);
		node.setMaterialFlag(Material.LIGHT, true);
		node.setMaterialAlpha(0.7);
		//node.setMaterialTexture(texture);
		node.setMaterialFlag(Material.TRANSPARTENT,false);
		//node.setMaterialFlag(Material.WIREFRAME, true);
		
		node2 = new MeshSceneNode(manager, new Cube(250,250,250));
		node2.setMaterialFlag(Material.GOURAUD_SHADE, true);
		node2.setMaterialFlag(Material.LIGHT, true);
		node2.setMaterialFlag(Material.TRANSPARTENT,true);
		node2.setMaterialAlpha(0.8);
		//node2.setMaterialFlag(Material.TRANSPARTENT, false);

		
		light=new LightSceneNode(manager,0xff6600,200.,2);
		light.setPosition(new Vector3(0., 100., 200.));
		
		manager.addChild(node);
		manager.addChild(node2);
		manager.addChild(light);
		
		manager.updateAbsoluteMatrix();

		Lib.current.addEventListener(Event.ENTER_FRAME,_onEnterFrame);
		Lib.current.addChild(driver.getRenderTarget());
		
		Log.setColor(0xffffff);
		
		Lib.current.addChild(new StatusPanel(100, 50));

		t = Lib.getTimer();

		/*
		var alpha:Float = 0.6;
		var invAlpha:Float = 0.4;
		var color:UInt = (Std.int(alpha * 44 + invAlpha * (0x334455 >> 16 & 0xFF)) << 16 | 
								                 Std.int(alpha * 55 + invAlpha * (0x334455 >> 8 & 0xFF))  << 8  | 
								                 Std.int(alpha * 66 + invAlpha * (0x334455 & 0xFF)));
	    trace(color);//3030089
		
		 * var alpha:Int = Std.int(0.6*255);
		var invAlpha:Int = 255 - alpha;
		trace(alpha);
		var color:UInt = (
		                  ((alpha * 44 + invAlpha * (0x334455 >> 16 & 0xFF)) >> 8) << 16 | 
						  ((alpha * 55 + invAlpha * (0x334455 >> 8 & 0xFF)) >> 8)  << 8  | 
						  ((alpha * 66 + invAlpha * (0x334455 & 0xFF)) >> 8)
						  );
	    trace(color);//3030089
		 */
	}
	private var t:Int;
	private function _onEnterFrame(e:Event):Void
	{
			node.rotationY += 1;
			node2.rotationY -= 2;
			light.rotationY-=0.3;
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
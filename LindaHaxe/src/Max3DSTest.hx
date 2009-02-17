package ;
import flash.display.MovieClip;
import flash.display.StageAlign;
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
import linda.animator.AnimatorFlyCircle;
import linda.animator.AnimatorRotation;
import linda.Linda;
import linda.material.MipMapLevel;
import linda.material.Texture;
import linda.math.Color;
import linda.math.Dimension2D;
import linda.math.Matrix4;
import linda.math.Plane3D;
import linda.math.Vector3;
import linda.math.MathUtil;
import flash.Memory;
import flash.utils.ByteArray;
import linda.material.Material;
import linda.mesh.IAnimatedMesh;
import linda.mesh.IMesh;
import linda.mesh.loader.Max3DSMeshFileLoader;
import linda.mesh.loader.MD2MeshFileLoader;
import linda.mesh.Mesh;
import linda.mesh.MeshBuffer;
import linda.mesh.MeshManipulator;
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
import linda.scene.ShadowVolumeSceneNode;
import linda.scene.SkyBoxSceneNode;
import linda.video.IVideoDriver;
import linda.video.VideoSoftware32;
import linda.video.VideoSoftware;

import linda.scene.AnimatedMeshSceneNode;
class Max3DSTest 
{
	private var node1:MeshSceneNode;
	private var manager:SceneManager;
	private var driver:IVideoDriver;
	private var camera:CameraSceneNode;
	private var light:LightSceneNode;
	private var target:Bitmap;
	
	private var texture:Texture;
	
	private var t:Int;

	static function main() 
	{
		var m:Max3DSTest = new Max3DSTest();
	}
	public function new()
	{
		prepare();

		texture = new Texture(Lib.attach("Build"),false);
		
		driver = new VideoSoftware(new Dimension2D(500, 500));
        driver.setPerspectiveCorrectDistance(3000);
        driver.setMipMapDistance(500);
            
		manager=new SceneManager(driver);
        manager.setAmbient(0);

		camera=new CameraSceneNode(manager,new Vector3(0,100,0));
        camera.setPosition(new Vector3(0., 600., 600.));
		camera.bindTargetAndRotation(true);

		camera.addAnimator(new AnimatorFlyCircle(Lib.getTimer(), new Vector3(0,600,0), 600, 0.001, new Vector3(0, 1, 0)));
			
		manager.addChild(camera);
		manager.setActiveCamera(camera);

		node1 = new MeshSceneNode(manager,null,false);

		light = new LightSceneNode(manager, 0xff0000, 500., 2);
		light.light.castShadows = false;
		light.addAnimator(new AnimatorFlyCircle(Lib.getTimer(),new Vector3(0,100,0), 500, 0.002, new Vector3(0.3, 1, 0.2)));

		manager.addChild(node1);
		manager.addChild(light);
        
		var contextMenu:ContextMenu = new ContextMenu();
		Lib.current.contextMenu = contextMenu;
		//Lib.current.contextMenu.hideBuiltInItems();
		Lib.current.stage.align = StageAlign.TOP;
		Lib.current.stage.scaleMode = StageScaleMode.EXACT_FIT;
		Lib.current.addEventListener(Event.ENTER_FRAME,_onEnterFrame);
		Lib.current.addChild(driver.getRenderTarget());

		t = Lib.getTimer();

		loader = new URLLoader();
		loader.dataFormat = URLLoaderDataFormat.BINARY;
		loader.addEventListener(Event.COMPLETE, __load3ds);
		loader.load(new URLRequest("media/build.3DS"));
	}
	private var loader:URLLoader;
	private function __load3ds(e:Event):Void 
	{
		var data:ByteArray = Lib.as(loader.data, ByteArray);
		var maxloader:Max3DSMeshFileLoader = new Max3DSMeshFileLoader();
		var mesh:Mesh = cast(maxloader.createMesh(data), Mesh);
		//MeshManipulator.scale(mesh, new Vector3(2, 2, 2));
		data.clear();
		data = null;
		loader = null;
		node1.setMesh(mesh);
		node1.setMaterialFlag(Material.GOURAUD_SHADE, true);
		node1.setMaterialFlag(Material.LIGHT, true);
		node1.setMaterialFlag(Material.BACKFACE, true);
		node1.setMaterialTexture(texture);
		node1.setMaterialEmissiveColor(0x555555);
	}
	private function _onEnterFrame(e:Event):Void
	{
		if(Lib.getTimer()  -  t >  4000)
		{
			t=Lib.getTimer();
			light.light.diffuseColor.color = Std.int(Math.random() * 0xffffff);
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
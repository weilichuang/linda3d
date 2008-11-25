package mini3d.scene
{
	import flash.utils.getTimer;
	
	import mini3d.core.Material;
	import mini3d.math.AABBox3D;
	import mini3d.mesh.AnimatedMeshType;
	import mini3d.mesh.IAnimateMesh;
	import mini3d.mesh.IMesh;
	import mini3d.mesh.md2.AnimatedMeshMD2;
	import mini3d.mesh.md2.MD2Frame;
	import mini3d.render.RenderManager;

	public class AnimateMeshSceneNode extends SceneNode
	{
		private var materials : Array;
		private var mesh : IAnimateMesh;
		private var beginFrameTime : int;
		private var startFrame : int;
		private var endFrame : int;
		private var framesPerSecond : Number;
		private var currentFrame : int;
		private var looping : Boolean;
		public function AnimateMeshSceneNode (mgr:SceneManager,mesh : IAnimateMesh=null)
		{
			super (mgr);
			beginFrameTime = getTimer ();
			startFrame = 0;
			endFrame = 0;
			framesPerSecond = 50 / 1000;
			looping = true;
			materials = new Array ();

			setMesh (mesh);

		}
		override public function destroy():void
		{
			super.destroy();
			materials=null;
			mesh=null;
		}
		public function setCurrentFrame (frame : Number) : void
		{
			if (frame <= startFrame || frame > endFrame) return;
			currentFrame = frame;
			beginFrameTime = getTimer () - (currentFrame - startFrame) / framesPerSecond;
		}
		public function buildFrameNumber (timeMs : int) : int
		{
			if (startFrame == endFrame) return startFrame;
			if (framesPerSecond == 0) return startFrame;
			if (looping)
			{
					var lenInTime : int = (endFrame - startFrame) / framesPerSecond;
					return startFrame + ((timeMs - beginFrameTime) % lenInTime) * framesPerSecond;
			} else
			{
				var frame : int;
				var deltaFrame : Number = (timeMs - beginFrameTime ) * framesPerSecond;
				frame = startFrame + deltaFrame;
				if (frame > endFrame)
				{
						frame = endFrame;
				}
				return frame;
			}
		}
		public function getCurrentFrame () : int
		{
			return currentFrame;
		}
		public function getStartFrame () : int
		{
			return startFrame;
		}
		public function getEndFrame () : int
		{
			return endFrame;
		}
		
		override public function onPreRender () : void
		{
			if (visible)
			{
				var dirver: RenderManager = sceneManager.getRenderManager();

                sceneManager.registerNodeForRendering (this, SceneNode.NODE);
                
				super.onPreRender ();
			}
		}
		override public function onAnimate (timeMs : int) : void
		{
			currentFrame = buildFrameNumber (timeMs);
			super.onAnimate (timeMs);
		}
		override public function render () : void
		{
			var driver : RenderManager = sceneManager.getRenderManager();
			if ( ! mesh || ! driver) return;

			var m : IMesh= mesh.getMesh (currentFrame , 255, startFrame, endFrame);
			
			driver.setTransformWorld (_absoluteMatrix);
			
			var len:int=m.getMeshBufferCount ();
			for (var i : int = 0; i < len; i+=1)
			{
				driver.setMaterial (materials[i]);
				driver.drawMeshBuffer(container,m.getMeshBuffer (i));
			}
		}
		
		public function setFrameLoop (begin : int, end : int) : Boolean
		{
			var maxFrameCount : int = mesh.getFrameCount () - 1;
			if (end > maxFrameCount || begin > maxFrameCount) return false;
			if (end < begin)
			{
				startFrame = end;
				endFrame = begin;
			} else
			{
				startFrame = begin;
				endFrame = end;
			}
			setCurrentFrame (startFrame);
			return true;
		}
		public function setAnimationSpeed (per : int) : void
		{
			framesPerSecond = Math.abs(per) * 0.001;
		}
		public function getAnimationSpeed () : int
		{
			return framesPerSecond * 1000;
		}
		override public function getBoundingBox () : AABBox3D
		{
			if(!mesh) return null;
			return mesh.getBoundingBox();
		}
		override public function getMaterial (i : int = 0) : Material
		{
			return materials [i];
		}
		override public function getMaterialCount () : int
		{
			return materials.length;
		}
		public function setMD2Animation (data:MD2Frame) : Boolean
		{
			if ( ! mesh || mesh.getMeshType () != AnimatedMeshType.AMT_MD2) return false;
			
			var m : AnimatedMeshMD2 = mesh as AnimatedMeshMD2;
			if(!m) return false;
			
			var frame : MD2Frame = m.getFrame (data);
			if (frame)
			{
				setAnimationSpeed (frame.fps);
				setFrameLoop (frame.begin, frame.end);
				return true;
			}
			return false;
		}
		public function setLoopMode (loop : Boolean) : void
		{
			looping = loop;
		}
		public function setMesh (mesh : IAnimateMesh) : void
		{
			if ( ! mesh) return;
			this.mesh = mesh;
			var m : IMesh = mesh.getMesh (0, 255);
			if (!m) return;
            
            materials=new Array();
			var len:int=m.getMeshBufferCount ();
			for (var i : int = 0; i < len; i+=1)
			{
				var mat:Material=m.getMeshBuffer(i).material;
				materials.push (mat.clone());
			}
			setFrameLoop (0, mesh.getFrameCount () - 1);
		}
	}
}

package linda.scene
{
	import __AS3__.vec.Vector;
	
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	import linda.events.AnimationEvent;
	import linda.material.Material;
	import linda.math.AABBox3D;
	import linda.mesh.IMesh;
	import linda.mesh.animation.AnimatedMeshMD2;
	import linda.mesh.animation.AnimatedMeshType;
	import linda.mesh.animation.IAnimateMesh;
	import linda.mesh.animation.MD2Frame;
	import linda.video.IVideoDriver;
	
    [Event(name="start",type="cj7.events.AnimationEvent")]
    [Event(name="end",type="cj7.events.AnimationEvent")]
	public class AnimateMeshSceneNode extends SceneNode
	{
		private var materials : Vector.<Material>;
		private var mesh : IAnimateMesh;
		private var beginFrameTime : int;
		private var startFrame : int;
		private var endFrame : int;
		private var framesPerSecond : Number;
		private var currentFrameNr : int;
		private var looping : Boolean;
		private var transparent : Boolean;
		public function AnimateMeshSceneNode (mgr:SceneManager,mesh : IAnimateMesh = null)
		{
			super (mgr);
			beginFrameTime = getTimer ();
			startFrame = 0;
			endFrame = 0;
			framesPerSecond = 25 / 1000;
			looping = true;
			materials = new Vector.<Material> ();

			setMesh (mesh);
		}
		override public function destroy():void
		{
			materials=null;
			mesh=null;
			super.destroy();	
		}
		public function setCurrentFrame (frame : Number) : void
		{
			if (frame < startFrame || frame > endFrame) return;
			currentFrameNr = frame;
			beginFrameTime = getTimer() - (currentFrameNr - startFrame) / framesPerSecond;
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
				var deltaFrame : Number = (timeMs - beginFrameTime ) * framesPerSecond;
				var frame : int = startFrame + deltaFrame;
				if (frame > endFrame)
				{
					frame = endFrame;
					dispatchEvent(new AnimationEvent("end"));
				}
				return frame;
			}
		}
		public function getFrameNumber () : int
		{
			return currentFrameNr;
		}
		override public function onPreRender () : void
		{
			if (visible)
			{
				var dirver : IVideoDriver = sceneManager.getVideoDriver ();
                if(transparent)
                {
                	sceneManager.registerNodeForRendering (this, TRANSPARENT);
                }else
                {
                	sceneManager.registerNodeForRendering (this, SOLID);
                }
				super.onPreRender ();
			}
		}
		override public function onAnimate (timeMs : int) : void
		{
			currentFrameNr = buildFrameNumber (timeMs);
			super.onAnimate (timeMs);
		}
		override public function render () : void
		{
			var driver : IVideoDriver = sceneManager.getVideoDriver ();
			if ( ! mesh || ! driver) return;

			var m : IMesh= mesh.getMesh (currentFrameNr , 255, startFrame, endFrame);
			
			driver.setTransformWorld (_absoluteMatrix);
			
			var len:int=m.getMeshBufferCount ();
			for (var i : int = 0; i < len; i+=1)
			{	
			    driver.setMaterial(materials[i]);
				driver.drawMeshBuffer(m.getMeshBuffer(i));
			}
			if(debug)
			{
				driver.draw3DBox(getBoundingBox(),driver.getDebugColor());
			}
		}
		public function getStartFrame () : int
		{
			return startFrame;
		}
		public function getEndFrame () : int
		{
			return endFrame;
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
			if(per < 0 ) per = -per;
			framesPerSecond = per * 0.001;
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
			if (i < 0 || i >= materials.length) return super.getMaterial (i);
			return materials [i];
		}
		override public function getMaterialCount () : int
		{
			return materials.length;
		}
		public function setMD2Animation (data : MD2Frame) : Boolean
		{
			if ( ! mesh || mesh.getMeshType () != AnimatedMeshType.AMT_MD2) return false;
			
			var m : AnimatedMeshMD2 = mesh as AnimatedMeshMD2;
			if(!m) return false;
            var frameData : MD2Frame = m.getFrame(data);
			if (frameData)
			{
				setAnimationSpeed (frameData.fps);
				setFrameLoop (frameData.begin, frameData.end);
				frameData=null;
				return true;
			}
			return false;
		}
		public function setLoopMode (looped : Boolean) : void
		{
			looping = looped;
		}
		public function setMesh (mesh : IAnimateMesh) : void
		{
			if ( mesh == null ) return;
			this.mesh = mesh;
			
			var m : IMesh = mesh.getMesh (0, 255);
			
			if (!m) return;
            
            materials=new Vector.<Material> ();
			var mat : Material;
			var len:int=m.getMeshBufferCount ();
			for (var i : int = 0; i < len; i+=1)
			{
				mat = m.getMeshBuffer(i).material;
				materials.push (mat.clone());
			}
			
			setFrameLoop (0, mesh.getFrameCount () - 1);
		}
	}
}

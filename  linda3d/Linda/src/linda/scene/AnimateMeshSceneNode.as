package linda.scene
{
	import linda.events.AnimationEvent;
	import linda.material.Material;
	import linda.math.AABBox3D;
	import linda.mesh.IMesh;
	import linda.mesh.IMeshBuffer;
	import linda.mesh.animation.AnimatedMeshMD2;
	import linda.mesh.animation.AnimatedMeshType;
	import linda.mesh.animation.IAnimateMesh;
	import linda.mesh.animation.MD2Frame;
	import linda.video.IVideoDriver;
	
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
    [Event(name="start",type="cj7.events.AnimationEvent")]
    [Event(name="end",type="cj7.events.AnimationEvent")]
	public class AnimateMeshSceneNode extends SceneNode
	{
		private var materials : Array;
		private var mesh : IAnimateMesh;
		private var beginFrameTime : int;
		private var startFrame : int;
		private var endFrame : int;
		private var framesPerSecond : Number;
		private var currentFrameNr : int;
		private var looping : Boolean;
		private var transparent : Boolean;
		public function AnimateMeshSceneNode (mesh : IAnimateMesh = null, pos : Vector3D = null, rotation : Vector3D = null, scale : Vector3D = null)
		{
			super (pos, rotation, scale);
			beginFrameTime = getTimer ();
			startFrame = 0;
			endFrame = 0;
			framesPerSecond = 25 / 1000;
			looping = true;
			materials = new Array ();
			if (mesh)
			{
				setMesh (mesh);
			}
		}
		override public function destroy():void
		{
			super.destroy();
			materials=null;
			mesh=null;
		}
		public function setCurrentFrame (frame : Number) : void
		{
			if (frame < startFrame || frame > endFrame) return;
			currentFrameNr = frame;
			beginFrameTime = getTimer () - (currentFrameNr - startFrame) / framesPerSecond;
		}
		public function buildFrameNr (timeMs : int) : int
		{
			if (startFrame == endFrame) return startFrame;
			if (framesPerSecond == 0) return startFrame;
			if (looping)
			{
				//play animation looped
				if (framesPerSecond > 0) //forwards...
				{
					var lenInTime : int = (endFrame - startFrame) / framesPerSecond;
					return startFrame + ((timeMs - beginFrameTime) % lenInTime) * framesPerSecond;
				} else //backwards...
				{
					lenInTime = - (endFrame - startFrame) / framesPerSecond;
					return endFrame + ((timeMs - beginFrameTime) % lenInTime) * framesPerSecond;
				}
			} else
			{
				// play animation non looped
				var frame : int;
				if (framesPerSecond > 0) //forwards...
				{
					var deltaFrame : Number = (timeMs - beginFrameTime ) * framesPerSecond;
					frame = startFrame + deltaFrame;
					if (frame > endFrame)
					{
						frame = endFrame;
						dispatchEvent(new AnimationEvent("end"));
					}
				} 
				else //backwards... (untested)
				{
					deltaFrame = (timeMs - beginFrameTime ) * - framesPerSecond ;
					frame = endFrame - deltaFrame;
					if (frame < startFrame)
					{
						frame = startFrame;
						dispatchEvent(new AnimationEvent("end"));
					}
				}
				return frame;
			}
		}
		public function getFrameNr () : int
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
                	sceneManager.registerNodeForRendering (this, SceneNodeType.TRANSPARENT);
                }else
                {
                	sceneManager.registerNodeForRendering (this, SceneNodeType.SOLID);
                }
				
				super.onPreRender ();
			}
		}
		override public function onAnimate (timeMs : int) : void
		{
			currentFrameNr = buildFrameNr (timeMs);
			super.onAnimate (timeMs);
		}
		override public function render () : void
		{
			var driver : IVideoDriver = sceneManager.getVideoDriver ();
			if ( ! mesh || ! driver) return;

			var m : IMesh= mesh.getMesh (currentFrameNr , 255, startFrame, endFrame);
			
			driver.setTransformWorld (_absoluteMatrix);
			
			var len:int=m.getMeshBufferCount ();
			var mb : IMeshBuffer;
			var mat:Material;
			for (var i : int = 0; i < len; i ++)
			{
				mb = m.getMeshBuffer (i);
				mat = materials [i];
				driver.setMaterial (mat);
				driver.drawIndexedTriangleList (mb.getVertices () , mb.getVertexCount () , mb.getIndices () , mb.getIndexCount ());
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
		public function setMD2Animation (anim : int) : Boolean
		{
			if ( ! mesh || mesh.getMeshType () != AnimatedMeshType.AMT_MD2) return false;
			var m : AnimatedMeshMD2 = mesh as AnimatedMeshMD2;
			if(!m) return false;
			var frameData : MD2Frame = m.getFrameLoopByType (anim);
			if (frameData)
			{
				setAnimationSpeed (frameData.fps);
				setFrameLoop (frameData.begin, frameData.end);
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
			if ( ! mesh) return;
			this.mesh = mesh;
			var m : IMesh = mesh.getMesh (0, 255);
			if (!m) return;
            
            materials=new Array();
			var mat : Material;
			var mb : IMeshBuffer;
			var len:int=m.getMeshBufferCount ();
			for (var i : int = 0; i < len; i ++)
			{
				mb = m.getMeshBuffer (i);
				if (mb) mat = mb.getMaterial ();
				materials.push (mat);
			}
			// get start and begin time
			setFrameLoop (0, mesh.getFrameCount () - 1);
		}
	}
}

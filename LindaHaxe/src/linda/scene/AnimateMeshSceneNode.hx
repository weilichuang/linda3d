package linda.scene;

	import flash.Vector;
	
	import flash.geom.Vector3;
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

	class AnimateMeshSceneNode extends SceneNode
	{
		private var materials : Vector<Material>;
		private var mesh : IAnimateMesh;
		private var beginFrameTime : Int;
		private var startFrame : Int;
		private var endFrame : Int;
		private var framesPerSecond : Float;
		private var currentFrameNr : Int;
		private var looping : Bool;
		public function new (mgr:SceneManager,?mesh : IAnimateMesh = null)
		{
			super (mgr);
			beginFrameTime = getTimer ();
			startFrame = 0;
			endFrame = 0;
			framesPerSecond = 0.025;
			looping = true;
			materials = new Vector<Material> ();

			setMesh (mesh);
		}
		override public function destroy():Void
		{
			materials=null;
			mesh=null;
			super.destroy();	
		}
		public function setCurrentFrame (frame : Float) : Void
		{
			if (frame < startFrame || frame > endFrame) return;
			currentFrameNr = frame;
			beginFrameTime = getTimer() - (currentFrameNr - startFrame) / framesPerSecond;
		}
		public function buildFrameFloat (timeMs : Int) : Int
		{
			if (startFrame == endFrame) return startFrame;
			if (framesPerSecond == 0) return startFrame;
			if (looping)
			{
					var lenInTime : Int = (endFrame - startFrame) / framesPerSecond;
					return startFrame + ((timeMs - beginFrameTime) % lenInTime) * framesPerSecond;
			} else
			{
				var deltaFrame : Float = (timeMs - beginFrameTime ) * framesPerSecond;
				var frame : Int = startFrame + deltaFrame;
				if (frame > endFrame)
				{
					frame = endFrame;
					dispatchEvent(new AnimationEvent("end"));
				}
				return frame;
			}
		}
		public function getFrameFloat () : Int
		{
			return currentFrameNr;
		}
		override public function onRegisterSceneNode () : Void
		{
			if (visible)
			{
				var len:Int = materials.length;
				var mt : Material;
				var transparentCount:Int = 0;
				var solidCount:Int = 0;
				for ( i in 0...len)
				{
					mt = materials[i];
					if (mt.transparenting) 
					{
						transparentCount++;
					}else 
					{
						solidCount++;
					}

					if (solidCount>0 && transparentCount>0)
						break;
				}
				
				if (transparentCount > 0)
				{
					sceneManager.registerNodeForRendering(this, SceneNode.TRANSPARENT);
				}
				if ( solidCount > 0)
				{
					sceneManager.registerNodeForRendering(this, SceneNode.SOLID);
				}
				super.onRegisterSceneNode ();
			}
		}
		override public function onAnimate (timeMs : Int) : Void
		{
			currentFrameNr = buildFrameFloat (timeMs);
			super.onAnimate (timeMs);
		}
		override public function render () : Void
		{
			var driver : IVideoDriver = sceneManager.getVideoDriver ();
			if ( ! mesh) return;

			var m : IMesh= mesh.getMesh (currentFrameNr , 255, startFrame, endFrame);
			
			driver.setTransformWorld (_absoluteMatrix);
			
			var len:Int=m.getMeshBufferCount ();
			for (var i : Int = 0; i < len; i+=1)
			{	
			    driver.setMaterial(materials[i]);
				driver.drawMeshBuffer(m.getMeshBuffer(i));
			}
			if(debug)
			{
				driver.draw3DBox(getBoundingBox(),driver.getDebugColor());
			}
		}
		public function getStartFrame () : Int
		{
			return startFrame;
		}
		public function getEndFrame () : Int
		{
			return endFrame;
		}
		public function setFrameLoop (begin : Int, end : Int) : Bool
		{
			var maxFrameCount : Int = mesh.getFrameCount () - 1;
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
		public function setAnimationSpeed (per : Int) : Void
		{
			if(per < 0 ) per = -per;
			framesPerSecond = per * 0.001;
		}
		public function getAnimationSpeed () : Int
		{
			return framesPerSecond * 1000;
		}
		override public function getBoundingBox () : AABBox3D
		{
			if(!mesh) return null;
			return mesh.getBoundingBox();
		}
		override public function getMaterial (i : Int = 0) : Material
		{
			if (i < 0 || i >= materials.length) return super.getMaterial (i);
			return materials [i];
		}
		override public function getMaterialCount () : Int
		{
			return materials.length;
		}
		public function setMD2Animation (data : MD2Frame) : Bool
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
		public function setLoopMode (looped : Bool) : Void
		{
			looping = looped;
		}
		public function setMesh (mesh : IAnimateMesh) : Void
		{
			if ( mesh == null ) return;
			this.mesh = mesh;
			
			var m : IMesh = mesh.getMesh (0, 255);
			
			if (!m) return;
            
            materials=new Vector<Material> ();
			var mat : Material;
			var len:Int=m.getMeshBufferCount ();
			for (var i : Int = 0; i < len; i+=1)
			{
				mat = m.getMeshBuffer(i).material;
				materials.push (mat.clone());
			}
			
			setFrameLoop (0, mesh.getFrameCount () - 1);
		}
	}


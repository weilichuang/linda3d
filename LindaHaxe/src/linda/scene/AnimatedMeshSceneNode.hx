package linda.scene;

	import flash.Vector;
	
	import linda.math.Vector3;
	import flash.Lib;

	import linda.material.Material;
	import linda.math.AABBox3D;
	import linda.mesh.IMesh;
	import linda.mesh.MeshBuffer;
	import linda.mesh.md2.AnimatedMeshMD2;
	import linda.mesh.AnimatedMeshType;
	import linda.mesh.IAnimatedMesh;
	import linda.mesh.md2.MD2Frame;
	import linda.video.IVideoDriver;

	class AnimatedMeshSceneNode extends SceneNode
	{
		private var materials : Vector<Material>;
		private var materialCount:Int;
		private var useDefaultMaterial:Bool ;
		
		private var animateMesh : IAnimatedMesh;
		
		private var beginFrameTime : Int;
		private var startFrame : Int;
		private var endFrame : Int;
		private var framesPerSecond : Float;
		private var currentFrameNr : Int;
		private var looping : Bool;
		public function new (mgr:SceneManager,?mesh : IAnimatedMesh = null,?useDefaultMaterial:Bool=true)
		{
			super (mgr);
			
			beginFrameTime = Lib.getTimer ();
			startFrame = 0;
			endFrame = 0;
			framesPerSecond = 0.025;
			looping = true;
			
			materials = new Vector<Material> ();
			materialCount = 0;
			
			
			this.useDefaultMaterial = useDefaultMaterial;
			setAnimateMesh(mesh);
		}
		override public function destroy():Void
		{
			materials=null;
			animateMesh=null;
			super.destroy();	
		}
		public function setCurrentFrame (frame : Float) : Void
		{
			if (frame < startFrame || frame > endFrame) return;
			currentFrameNr = Std.int(frame);
			beginFrameTime = Lib.getTimer() - Std.int((currentFrameNr - startFrame) / framesPerSecond);
		}
		public function buildFrameNumber (timeMs : Int) : Int
		{
			if (startFrame == endFrame) return startFrame;
			if (framesPerSecond == 0) return startFrame;
			if (looping)
			{
					var lenInTime : Int = Std.int((endFrame - startFrame) / framesPerSecond);
					return Std.int(startFrame + ((timeMs - beginFrameTime) % lenInTime) * framesPerSecond);
			} else
			{
				var deltaFrame : Float = (timeMs - beginFrameTime ) * framesPerSecond;
				var frame : Int = Std.int(startFrame + deltaFrame);
				if (frame > endFrame)
				{
					frame = endFrame;
				}
				return frame;
			}
		}
		public function getFrameNumber () : Int
		{
			return currentFrameNr;
		}
		override public function onRegisterSceneNode () : Void
		{
			if (visible)
			{
				var mt : Material;
				var transparentCount:Int = 0;
				var solidCount:Int = 0;
				for ( i in 0...materialCount)
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
			currentFrameNr = buildFrameNumber (timeMs);
			super.onAnimate (timeMs);
		}
		override public function render () : Void
		{
			if (animateMesh==null) return;

			var m : IMesh= animateMesh.getMesh (currentFrameNr , 255, startFrame, endFrame);
			
			var driver : IVideoDriver = sceneManager.getVideoDriver ();
			driver.setTransformWorld (_absoluteMatrix);
			
			var len:Int=m.getMeshBufferCount ();
			for (i in 0...len)
			{	
			    driver.setMaterial(materials[i]);
				driver.setDistance(distance);
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
			var maxFrameCount : Int = this.animateMesh.getFrameCount () - 1;
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
			return Std.int(framesPerSecond * 1000);
		}
		override public function getBoundingBox () : AABBox3D
		{
			if(animateMesh==null) return null;
			return animateMesh.getBoundingBox();
		}
		override public function getMaterial (i : Int = 0) : Material
		{
			if (i < 0 || i >= materialCount) return null;
			return materials [i];
		}
		override public function getMaterialCount () : Int
		{
			return materialCount;
		}
		public function setMD2Animation (data : MD2Frame) : Bool
		{
			if ( animateMesh==null || animateMesh.getMeshType () != AnimatedMeshType.AMT_MD2) return false;
			
			var m : AnimatedMeshMD2 = Lib.as(animateMesh,AnimatedMeshMD2);
			if (m == null) return false;
			
            var frameData : MD2Frame = m.getFrame(data);
			if (frameData!=null)
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
		public function setAnimateMesh (mesh : IAnimatedMesh) : Void
		{
			animateMesh = mesh;
			
			if (animateMesh!=null)
			{
				var m : IMesh = animateMesh.getMesh (currentFrameNr, 255);
				
				setMaterials(m, useDefaultMaterial);
				
				setFrameLoop (0, animateMesh.getFrameCount () - 1);
			}
		}
		
		private function setMaterials(m:IMesh,value:Bool):Void 
		{
			materialCount = 0;
			materials.length = 0;
			if (m!=null)
			{
				var mb : MeshBuffer;
				var count:Int=m.getMeshBufferCount();
				for (i in 0...count)
				{
					mb = m.getMeshBuffer(i);
					if (value)
					{
						materials[i]=mb.material;
					}else
					{
						materials[i]=mb.material.clone();
					}
				}
				materialCount += count;
			}
		}
		public function setUseDefaultMaterial(value:Bool):Void 
		{
			useDefaultMaterial = value;
			
			var m : IMesh = animateMesh.getMesh(currentFrameNr, 255);	
			
			setMaterials(m, useDefaultMaterial);
		}
		public function isUseDefaultMaterial():Bool 
		{
			return useDefaultMaterial;
		}
	}


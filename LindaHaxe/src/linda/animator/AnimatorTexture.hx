package linda.animator;

	import flash.Vector;
	
	import linda.material.ITexture;
	import linda.material.Texture;
	import linda.scene.SceneNode;

	class AnimatorTexture implements IAnimator
	{
		private var textures:Vector<Texture>;
		private var timePerFrame:Int;
		private var startTime:Int;
		private var endTime:Int;
		private var loop:Bool;
		public function new(textures:Vector<Texture>,timePerFrame:Int,loop:Bool,startTime:Int)
		{
			this.timePerFrame=timePerFrame;
			this.loop=loop;
			this.startTime=startTime;
			this.textures=textures;
			endTime=startTime+(timePerFrame*textures.length);
		}

		public function animateNode(node:SceneNode, timeMs:Float):Void
		{
			if(textures && textures.length > 0)
			{
				var t:Int=timeMs-startTime;
				
				var idx:Int=0;
				if(!loop && timeMs >= endTime)
				{
					idx = textures.length -1;
				}else
				{
					idx = (t/timePerFrame) % textures.length;
				}
				if(idx < textures.length)
				{
					node.setMaterialTexture(textures[idx],1);
				}
				
			}
		}
		public function setTextures(textures:Vector<Texture>):Void
		{
			this.textures=textures;
		}
		public function setTimePerFrame(per:Int):Void
		{
			timePerFrame=per;
		}
		
	}
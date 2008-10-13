package linda.animator
{
	import __AS3__.vec.Vector;
	
	import linda.material.ITexture;
	import linda.material.Texture;
	import linda.scene.SceneNode;

	public class SceneNodeAnimatorTexture implements ISceneNodeAnimator
	{
		private var textures:Vector.<Texture>;
		private var timePerFrame:int;
		private var startTime:int;
		private var endTime:int;
		private var loop:Boolean;
		public function SceneNodeAnimatorTexture(textures:Vector.<Texture>,timePerFrame:int,loop:Boolean,startTime:int)
		{
			this.timePerFrame=timePerFrame;
			this.loop=loop;
			this.startTime=startTime;
			this.textures=textures;
			endTime=startTime+(timePerFrame*textures.length);
		}

		public function animateNode(node:SceneNode, timeMs:Number):void
		{
			if(textures && textures.length > 0)
			{
				var t:int=timeMs-startTime;
				
				var idx:int=0;
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
		public function setTextures(textures:Vector.<Texture>):void
		{
			this.textures=textures;
		}
		public function setTimePerFrame(per:int):void
		{
			timePerFrame=per;
		}
		
	}
}
﻿package linda.video;

	import flash.Vector;
	
	import flash.display.BitmapData;
	
	import linda.material.Material;
	import linda.math.Vertex4D;
	//Todo 设置MipMap方式需要修改
	class TriangleRenderer
	{
		private var target : Vector<UInt>;
		private var buffer : Vector<Float>;
		private var material : Material;

		private var perspectiveCorrect:Bool;
		private var perspectiveDistance:Float;
		private var mipMapDistance:Float;

		//alpha
		private var alpha:Int;
		private var invAlpha:Int;
		
		public var height:Int;
		
		public function new()
		{
			perspectiveCorrect = false;
			perspectiveDistance = 400.;
			mipMapDistance = 500.;
		}
		
		public function setVector (target : Vector<UInt>, buffer : Vector<Float>) : Void
		{
			this.target = target;
			this.buffer = buffer;
		}
		public function setHeight(height:Int):Void
		{
			this.height=height;
		}
		public function setPerspectiveCorrectDistance(?distance:Float=400.):Void
		{
			perspectiveDistance=distance;
		}
		public function setMipMapDistance(?distance:Float=500.):Void
		{
			mipMapDistance=distance;
		}
		public function setMaterial (mat : Material) : Void
		{
			material = mat;
			if(material.transparenting)
			{
				alpha = Std.int(material.alpha*0xFF);
				invAlpha = 0xFF - alpha;
			}	
		}
	}


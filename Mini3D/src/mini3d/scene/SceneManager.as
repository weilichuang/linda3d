package mini3d.scene
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.utils.getTimer;
	
	import mini3d.core.ViewFrustum;
	import mini3d.math.AABBox3D;
	import mini3d.math.Matrix4;
	import mini3d.render.RenderManager;
	public class SceneManager extends SceneNode
	{
		private var _manager : RenderManager;
		private var _viewFrustum : ViewFrustum;
		private var _activeCamera : CameraSceneNode;
		private var _nodeList : Array;
		public function SceneManager (driver : RenderManager)
		{
			super(null);
			_nodeList=new Array();
			setRenderManager(driver);
		}

		override public function destroy() : void
		{
			_manager = null;
			_viewFrustum = null;
			_activeCamera = null;
			_nodeList = null;
			
			super.destroy();
		}
		
		public function setRootContainer(root:DisplayObjectContainer):void
		{
			root.addChild(container);
		}

		public function getRenderManager () : RenderManager
		{
			return _manager;
		}

		public function setRenderManager (manager : RenderManager) : void
		{
			if (manager)
			{
				_manager = manager;
			}
		}

		public function registerNodeForRendering (node : SceneNode , type : int) : void
		{
			switch (type)
			{
				case SceneNode.NODE :
				{
					if (!isCulled (node))
					{
						_nodeList.push (node);
					}
				}
				break;
			}
		}

		public function drawAll () : void
		{
			if ( !_manager || !_activeCamera) return ;
			
			onPreRender ();
			
			_activeCamera.render();
			
			clear(container);
			while(container.numChildren > 0) container.removeChildAt(0);
			
			_nodeList.sortOn ('distance' , Array.NUMERIC | Array.DESCENDING);
			var len : int = _nodeList.length;
			var node : SceneNode;
			for (var i : int = 0; i < len; i+=1)
			{
				node = _nodeList [i];
				node.render ();
				container.addChild(node.container);
			}

			_nodeList = [];

			onAnimate (getTimer());
		}

		private function clear(s : Sprite) : void
		{
			s.graphics.clear();
			var num : int = s.numChildren;
			for(var i : int = 0;i < num; i+=1)
			{
				clear(Sprite(s.getChildAt(i)));
			}
		}

		override public function render() : void
		{
			_manager.beginScene();
			drawAll();
			_manager.endScene();
		}

		public function getActiveCamera () : CameraSceneNode
		{
			return _activeCamera;
		}

		public function setActiveCamera (camera : CameraSceneNode) : void
		{
			if (camera)
			{
				_activeCamera = camera;
				_viewFrustum = _activeCamera.getViewFrustum ();
			}
		}

		private var tmpBox : AABBox3D = new AABBox3D();
		public function isCulled (node : SceneNode) : Boolean
		{
			if( !_viewFrustum) return false;
			//转换视景体到物体本地坐标�?
			var node_matrix : Matrix4 = node.getAbsoluteMatrix ();
			//tmpBox.copy(node.getBoundingBox());
			//node_matrix.transformBox(tmpBox);
			var nodeBox : AABBox3D = node.getBoundingBox();
			tmpBox.minX = nodeBox.minX;
			tmpBox.minY = nodeBox.minY;
			tmpBox.minZ = nodeBox.minZ;
			tmpBox.maxX = nodeBox.maxX;
			tmpBox.maxY = nodeBox.maxY;
			tmpBox.maxZ = nodeBox.maxZ;
			
			
			//------------------------------- node_matrix.transformBox(tmpBox)---------------------//
			var vx : Number , vy : Number , vz : Number;
			vx = node_matrix.m00 * tmpBox.minX + node_matrix.m10 * tmpBox.minY + node_matrix.m20 * tmpBox.minZ + node_matrix.m30;
			vy = node_matrix.m01 * tmpBox.minX + node_matrix.m11 * tmpBox.minY + node_matrix.m21 * tmpBox.minZ + node_matrix.m31;
			vz = node_matrix.m02 * tmpBox.minX + node_matrix.m12 * tmpBox.minY + node_matrix.m22 * tmpBox.minZ + node_matrix.m32;
			tmpBox.minX = vx;
			tmpBox.minY = vy;
			tmpBox.minZ = vz;
			vx = node_matrix.m00 * tmpBox.maxX + node_matrix.m10 * tmpBox.maxY + node_matrix.m20 * tmpBox.maxZ + node_matrix.m30;
			vy = node_matrix.m01 * tmpBox.maxX + node_matrix.m11 * tmpBox.maxY + node_matrix.m21 * tmpBox.maxZ + node_matrix.m31;
			vz = node_matrix.m02 * tmpBox.maxX + node_matrix.m12 * tmpBox.maxY + node_matrix.m22 * tmpBox.maxZ + node_matrix.m32;
			tmpBox.maxX = vx;
			tmpBox.maxY = vy;
			tmpBox.maxZ = vz;
			
			//box.repair ();
			var t : Number;
			if (tmpBox.minX > tmpBox.maxX) t = tmpBox.minX , tmpBox.minX = tmpBox.maxX , tmpBox.maxX = t;
			if (tmpBox.minY > tmpBox.maxY) t = tmpBox.minY , tmpBox.minY = tmpBox.maxY , tmpBox.maxY = t;
			if (tmpBox.minZ > tmpBox.maxZ) t = tmpBox.minZ , tmpBox.minZ = tmpBox.maxZ , tmpBox.maxZ = t;
			//------------------------------- node_matrix.transformBox(tmpBox)---------------------//
			
			
			var fBox : AABBox3D = _viewFrustum.getBoundingBox();
			if( !(tmpBox.minX <= fBox.maxX && tmpBox.minY <= fBox.maxY && tmpBox.minZ <= fBox.maxZ &&
				tmpBox.maxX >= fBox.minX && tmpBox.maxY >= fBox.minY && tmpBox.maxZ >= fBox.minZ))
			return true;
			
			
			// 计算物体离相机的距离，为排序做准�备
			var camera_matrix : Matrix4 = _activeCamera.getAbsoluteMatrix ();
			vx = node_matrix.m30 - camera_matrix.m30;
			vy = node_matrix.m31 - camera_matrix.m31;
			vz = node_matrix.m32 - camera_matrix.m32;
			node.distance = Math.sqrt(vx * vx + vy * vy + vz * vz);
			return false;
		}
	}
}

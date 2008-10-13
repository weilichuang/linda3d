package linda.collision
{
	import flash.geom.Matrix;
	/**
	* 拾取三角形
	* 算法简介：首先得到鼠标的屏幕位置，然后转为世界坐标。在从相机射出一条线到该点。
	* 首先计算与该线相交的SceneNode(利用其包围盒），然后在计算其内部的物体或
	*/
	public class TriangleSelector
	{
		public function TriangleSelector ()
		{
		}
		public function getTriangles () : Array
		{
			return [];
		}
		public function getTriangleCount () : int
		{
			return 0;
		}
	}
}

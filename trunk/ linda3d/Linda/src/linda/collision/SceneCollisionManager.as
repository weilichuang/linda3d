package linda.collision
{
	import __AS3__.vec.Vector;
	
	import flash.geom.Vector3D;
	
	import linda.math.AABBox3D;
	import linda.math.Dimension2D;
	import linda.math.Line3D;
	import linda.math.Matrix4;
	import linda.math.Quaternion;
	import linda.math.Triangle3D;
	import linda.math.Vector2D;
	import linda.scene.SceneManager;
	import linda.scene.SceneNode;
	import linda.scene.camera.CameraSceneNode;
	import linda.video.IVideoDriver;
	public class SceneCollisionManager
	{
		private var sceneManager : SceneManager;
		private var driver : IVideoDriver;
		private var triangles : Array;
		private var camera : CameraSceneNode;
		public function SceneCollisionManager (manager : SceneManager, driver : IVideoDriver)
		{
			sceneManager = manager;
			camera = sceneManager.getActiveCamera ();
			this.driver = driver;
			triangles = new Array ();
		}
		/**
		*  Returns the scene node, which is currently visible under the overgiven
		*  screencoordinates, viewed from the currently active camera.
		*/
		public function getSceneNodeFromScreenCoordinatesBB (pos : Vector2D) : SceneNode
		{
			var ln : Line3D = getRayFromScreenCoordinates (pos);
			if (ln.start.equals (ln.end)) return null;
			return getSceneNodeFromRayBB (ln);
		}
		/**
		* Returns the nearest scene node which collides with a 3d ray.
		*/
		public function getSceneNodeFromRayBB (ray : Line3D) : SceneNode
		{
			var best : SceneNode;
			var dist : Number = 9999999999.0;
			getPickedNodeBB (sceneManager.getRootSceneNode () , ray, dist, best);
			return best;
		}
		// recursive method for going through all scene nodes
		public function getPickedNodeBB (root : SceneNode, ray : Line3D,
		outbestdistance : Number, outbestnode : SceneNode) : void
		{
			var edges : Array = new Array ();
			var children : Vector.<SceneNode> = root.getChildren ();
			for (var i : int = 0; i < children.length; i ++)
			{
				var current : SceneNode = children [i];
				if (current.visible)
				{
					// get world to object space transform
					var mat : Matrix4 = new Matrix4 ();
					if ( ! current.getAbsoluteMatrix ().getInverse (mat)) continue;
					// transform vector from world space to object space
					var line : Line3D = ray;
					mat.transformVector (line.start);
					mat.transformVector (line.end);
					var box : AABBox3D = current.getBoundingBox ();
					// do intersection test in object space
					if (box.intersectsWithLine (line.getMiddle () , line.getVector () , line.getLength () * 0.5))
					{
						edges = box.getEdges ();
						var distance : Number = 0.0;
						var e:int=0;
						var v:Vector3D;
						for (e = 0; e < 8; e ++)
						{
							v=edges [e];
							//var t : Number = v.getDistanceFromSQ (line.start);
							var t : Number = Vector3D.distance(v,line.start);
							if (t > distance)
							distance = t;
						}
						if (distance < outbestdistance)
						{
							outbestnode = current;
							outbestdistance = distance;
						}
					}
				}
				getPickedNodeBB (current, ray, outbestdistance, outbestnode);
			}
		}
		// Returns the scene node, at which the overgiven camera is looking at 
		public function getSceneNodeFromCameraBB () : SceneNode
		{
			if ( ! camera) return null;
			var start : Vector3D = camera.getAbsolutePosition ();
			var end : Vector3D = camera.getTarget ();
			//fixme
			end = start.add ((end.subtract (start)).getNormalize ().scale (camera.getFar ()));
			var line : Line3D = new Line3D (start, end);
			return getSceneNodeFromRayBB (line);
		}
		// Finds the collision point of a line and lots of triangles, if there is one.
		public function getCollisionPoint (ray : Line3D, selector : TriangleSelector, outIntersection : Vector3D,
		outTriangle : Triangle3D) : Boolean
		{
			if ( ! selector)
			{
				return false;
			}
			var totalcnt : int = selector.getTriangleCount ();
			//Triangles.set_used(totalcnt);
			var cnt : int = 0;
			selector.getTriangles ();
			//triangles, totalcnt, cnt, ray);
			var linevect : Vector3D = ray.getVector().clone();
			linevect.normalize();
			var intersection : Vector3D;
			var nearest : Number = 9999999999999.0;
			var found : Boolean = false;
			var raylength : Number = ray.getLength();
			for (var i : int = 0; i < cnt; i ++)
			{
				if (triangles [i].getIntersectionWithLine (ray.start, linevect, intersection))
				{
					var tmp : Number = Vector3D.distance(intersection,ray.start);
					var tmp2 : Number = Vector3D.distance(intersection,ray.end);
					if (tmp < raylength && tmp2 < raylength && tmp < nearest)
					{
						nearest = tmp;
						outTriangle = triangles [i];
						outIntersection = intersection;
						found = true;
					}
				}
			}
			return found;
		}
		// Returns a 3d ray which would go through the 2d screen coodinates.
		public function getRayFromScreenCoordinates (pos : Vector2D) : Line3D
		{
			var ln : Line3D = new Line3D ();
			ln.setLineXYZ (0, 0, 0, 0, 0, 0);
			if ( ! sceneManager || ! camera) return ln;

			var f : ViewFrustum = camera.getViewFrustum ();
			var farLeftUp : Vector3D = f.getFarLeftUp ();
			var lefttoright : Vector3D = f.getFarRightUp ().subtract (farLeftUp);
			var uptodown : Vector3D = f.getFarLeftDown ().subtract (farLeftUp);
			var viewPort :Dimension2D = driver.getScreenSize ();
			//driver.getViewPort();
			//core::dimension2d<s32> screenSize(viewPort.getWidth(), viewPort.getHeight());
			var dx : Number = pos.x / viewPort.width;
			var dy : Number = pos.y / viewPort.height;
			if (camera.isOrthogonal ())
			{
			   ln.start = f.cameraPosition.add ((lefttoright.scale (dx - 0.5))).add (uptodown.scale (dy - 0.5));
			}
			else
			{
			   ln.start = f.cameraPosition;
			}
			ln.end = farLeftUp.add (lefttoright.scale (dx)).add (uptodown.scale (dy));
			return ln;
		}
		// Calculates 2d screen position from a 3d position.
		public function getScreenCoordinatesFrom3DPosition (pos3d : Vector3D) : Vector2D
		{
			
			var pos2d : Vector2D = new Vector2D ( - 1000, - 1000);
			if ( ! sceneManager || ! driver || ! camera) return pos2d;
			
			var trans : Matrix4 = camera.getViewProjectionMatrix().clone();
			var scale : Matrix4 = new Matrix4();//driver.getTransformClipScale();

	        var transformedPos:Quaternion=new Quaternion();

	        transformedPos.x = pos3d.x;
	        transformedPos.y = pos3d.y;
	        transformedPos.z = pos3d.z;
	        transformedPos.w = 1.0;

	        trans.multiplyWith1x4Matrix(transformedPos);

	        if (transformedPos.w < 0) return new Vector2D ( - 10000, - 10000);
            var zDiv:Number = transformedPos.w==0 ? scale.m22 : scale.m22/transformedPos.w;

			pos2d.x = (transformedPos.x * scale.m00) * zDiv + scale.m30;
			pos2d.y = (transformedPos.y * scale.m11) * zDiv + scale.m31;

			return pos2d;
		}
	}
}

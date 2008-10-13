package linda.mesh.utils
{
	import linda.material.Material;
	import linda.math.Dimension2D;
	import linda.math.Plane3D;
	import linda.math.Vector2D;
	import linda.math.Vertex;
	import linda.mesh.IMesh;
	import linda.mesh.Mesh;
	import linda.mesh.MeshBuffer;
	public class GeometryCreator
	{
		// creates a hill plane
		public static function createHillPlaneMesh (tileSize : Dimension2D, tc : Dimension2D, material : Material,
		hillHeight : Number, ch : Dimension2D, textureRepeatCount : Dimension2D) : IMesh
		{
			var tileCount : Dimension2D = tc;
			var countHills : Dimension2D = ch;
			if (countHills.width < 0.01)
			countHills.width = 1.;
			if (countHills.height < 0.01)
			countHills.height = 1.;
			// center
			var center : Vector2D = new Vector2D ((tileSize.width * tileCount.width) / 2.0, (tileSize.height * tileCount.height) / 2.0);
			// texture coord step
			var tx : Dimension2D = new Dimension2D (textureRepeatCount.width / tileCount.width,
			textureRepeatCount.height / tileCount.height);
			// add one more point in each direction for proper tile count
			tileCount.height++;
			tileCount.width++;
			var buffer : MeshBuffer = new MeshBuffer ();
			var vtx : Vertex;
			// create vertices from left-front to right-back
			var x : int;
			var sx : Number = 0, tsx : Number = 0;
			for (x = 0; x < tileCount.width; x ++)
			{
				var sy : Number = 0, tsy : Number = 0;
				for (var y : int = 0; y < tileCount.height; y ++)
				{
					vtx = new Vertex ();
					vtx.color = 0xffffff;
					vtx.x = sx - center.x;
					vtx.y = 0;
					vtx.z = sy - center.y;
					vtx.u = tsx;
					vtx.v = 1 - tsy;
					if (hillHeight != 0.0)
					vtx.y = (Math.sin (vtx.x * countHills.width * Math.PI / center.x) * Math.cos (vtx.z * countHills.height * Math.PI / center.y)) * hillHeight;
					buffer.vertices.push (vtx);
					sy += tileSize.height;
					tsy += tx.height;
				}
				sx += tileSize.width;
				tsx += tx.width;
			}
			// create indices
			for (x = 0; x < tileCount.width - 1; x ++)
			{
				for (y = 0; y < tileCount.height - 1; y ++)
				{
					var current : int = x * tileCount.height + y;
					buffer.indices.push (current);
					buffer.indices.push (current + 1);
					buffer.indices.push (current + tileCount.height);
					buffer.indices.push (current + 1);
					buffer.indices.push (current + 1 + tileCount.height);
					buffer.indices.push (current + tileCount.height);
				}
			}
			// recalculate normals
			var len : int = buffer.indices.length;
			var plane : Plane3D = new Plane3D (null, 0);
			var v0 : Vertex;
			var v1 : Vertex;
			var v2 : Vertex;
			for (var i : int = 0; i < len; i += 3)
			{
				v0 = buffer.vertices [buffer.indices [i + 0]];
				v1 = buffer.vertices [buffer.indices [i + 1]];
				v2 = buffer.vertices [buffer.indices [i + 2]];
				plane.setPlane3 (v0.position, v1.position, v2.position);
				v0.normal = plane.normal;
				v1.normal = plane.normal;
				v2.normal = plane.normal;
			}
			if (material) buffer.material = material;
			buffer.recalculateBoundingBox ();
			var mesh : Mesh = new Mesh ();
			mesh.addMeshBuffer (buffer);
			mesh.recalculateBoundingBox ();
			buffer = null;
			return mesh;
		}
		/*
		a cylinder, a cone and a cross
		point up on (0,1.f, 0.f )
		*/
		public static function createCylinderMesh (tesselationCylinder : int, height : Number,
		cylinderHeight : Number, width : Number,
		vtxColor0 : uint, vtxColor1 : uint) : IMesh
		{
			// cylinder
			var buffer : MeshBuffer = new MeshBuffer ();
			if (tesselationCylinder == 0) tesselationCylinder = 1;
			// floor, bottom
			var angleStep : Number = (Math.PI * 2.) / tesselationCylinder;
			var v : Vertex;
			for (var i : int = 0; i != tesselationCylinder; i ++)
			{
				var angle : Number = angleStep * i;
				v = new Vertex ();
				v.color = vtxColor0;
				v.x = width * Math.cos (angle );
				v.y = 0.;
				v.z = width * Math.sin (angle );
				v.normal = v.position.clone ();
				v.normal.normalize ();
				buffer.vertices.push (v );
				v = new Vertex ();
				v.x = width * 0.5 * Math.cos (angle );
				v.y = cylinderHeight;
				v.z = width * 0.5 * Math.sin (angle );
				v.normal = v.position.clone ();
				v.normal.normalize ();
				buffer.vertices.push (v );
				angle += (angleStep / 2.);
				v = new Vertex ();
				v.color = vtxColor1;
				v.x = (width * 0.75 ) * Math.cos (angle );
				v.y = 0.;
				v.z = (width * 0.75 ) * Math.sin (angle );
				v.normal = v.position.clone ();
				v.normal.normalize ();
				buffer.vertices.push (v );
				v = new Vertex ();
				v.x = (width * 0.25 ) * Math.cos (angle );
				v.y = cylinderHeight;
				v.z = (width * 0.25 ) * Math.sin (angle );
				v.normal = v.position.clone ();
				v.normal.normalize ();
				buffer.vertices.push (v );
			}
			var nonWrappedSize : int = ((tesselationCylinder * 2 ) - 1 ) * 2;
			for (i = 0; i != nonWrappedSize; i += 2 )
			{
				buffer.indices.push (i + 2 );
				buffer.indices.push (i + 0 );
				buffer.indices.push (i + 1 );
				buffer.indices.push (i + 2 );
				buffer.indices.push (i + 1 );
				buffer.indices.push (i + 3 );
			}
			buffer.indices.push (0 );
			buffer.indices.push (i + 0 );
			buffer.indices.push (i + 1 );
			buffer.indices.push (0 );
			buffer.indices.push (i + 1 );
			buffer.indices.push (1 );
			// close down
			v = new Vertex ();
			v.x = 0.;
			v.y = 0.;
			v.z = 0.;
			v.normal.x = 0.;
			v.normal.y = - 1.;
			v.normal.z = 0.;
			buffer.vertices.push (v );
			var index : int = buffer.vertices.length - 1;
			for (i = 0; i != nonWrappedSize; i += 2 )
			{
				buffer.indices.push (index );
				buffer.indices.push (i + 0 );
				buffer.indices.push (i + 2 );
			}
			buffer.indices.push (index );
			buffer.indices.push (i + 0 );
			buffer.indices.push (0 );
			// add to mesh
			var mesh : Mesh = new Mesh ();
			buffer.recalculateBoundingBox ();
			mesh.addMeshBuffer (buffer);
			return mesh;
		}
		public static function createConeMesh (tesselationCone : int, height : Number,
		cylinderHeight : Number, width : Number,
		vtxColor0 : uint, vtxColor1 : uint) : IMesh
		{
			// cone
			var buffer : MeshBuffer = new MeshBuffer ();
			var v : Vertex;
			var angleStep : Number = (Math.PI * 2.) / tesselationCone;
			for (var i : int = 0; i != tesselationCone; i ++)
			{
				var angle : Number = angleStep * i;
				v = new Vertex ();
				v.color = vtxColor0;
				v.x = width * Math.cos (angle );
				v.y = cylinderHeight;
				v.z = width * Math.sin (angle );
				v.normal = v.position.clone ();
				v.normal.normalize ();
				buffer.vertices.push (v );
				v = new Vertex ();
				angle += angleStep / 2.;
				v.color = vtxColor1;
				v.x = (width * 0.75 ) * Math.cos (angle );
				v.y = cylinderHeight;
				v.z = (width * 0.75 ) * Math.sin (angle );
				v.normal = v.position.clone ();
				v.normal.normalize ();
				buffer.vertices.push (v );
			}
			var nonWrappedSize : int = buffer.vertices.length - 1;
			// close top
			v.x = 0.;
			v.y = height;
			v.z = 0.;
			v.normal.x = 0.;
			v.normal.y = 1.;
			v.normal.z = 0.;
			buffer.vertices.push (v );
			index = buffer.vertices.length - 1;
			for (i = 0; i != nonWrappedSize; i += 1 )
			{
				buffer.indices.push (i + 0 );
				buffer.indices.push (index );
				buffer.indices.push (i + 1 );
			}
			buffer.indices.push (i + 0 );
			buffer.indices.push (index );
			buffer.indices.push (0 );
			// close down
			v.x = 0.;
			v.y = cylinderHeight;
			v.z = 0.;
			v.normal.x = 0.;
			v.normal.y = - 1.;
			v.normal.z = 0.;
			buffer.vertices.push (v );
			var index : int = buffer.vertices.length - 1;
			for (i = 0; i != nonWrappedSize; i += 1 )
			{
				buffer.indices.push (index );
				buffer.indices.push (i + 0 );
				buffer.indices.push (i + 1 );
			}
			buffer.indices.push (index );
			buffer.indices.push (i + 0 );
			buffer.indices.push (0 );
			// add to already existing mesh
			buffer.recalculateBoundingBox ();
			var mesh : Mesh = new Mesh ();
			mesh.addMeshBuffer (buffer);
			mesh.recalculateBoundingBox ();
			return mesh;
		}
	}
}

package  linda.mesh.objects;
import linda.math.MathUtil;
import linda.math.Vertex;
import linda.mesh.MeshBuffer;

class Cone extends MeshBuffer
{
	public function new (?radius:Float=100.,?length:Float=100.,?tesselation:Int=5,?colorTop:UInt=0xff0000,?colorBottom:UInt=0x00ff00,?oblique:Float=0.)
	{
		super();
		build(radius, length, tesselation, colorTop, colorBottom, oblique);
	}
	public inline function build(radius:Float,length:Float,tesselation:Int,colorTop:UInt,colorBottom:UInt,oblique:Float):Void 
	{
			vertices.length = 0;
			indices.length  = 0;

			var angleStep:Float = MathUtil.TWO_PI / tesselation;
			var angleStepHalf:Float = angleStep*0.5;

			var vertex:Vertex;
			var i:Int = 0;

			while(i != tesselation)
			{
				var angle:Float = angleStep * i;
                vertex = new Vertex();
				vertex.color = colorTop;
				vertex.x = radius * MathUtil.cos(angle);
				vertex.y = 0.;
				vertex.z = radius * MathUtil.sin(angle);
				vertex.nx = vertex.x;
				vertex.ny = vertex.y;
				vertex.nz = vertex.z;
				vertex.normalize();
				vertices.push(vertex);

				angle += angleStepHalf;
				vertex = new Vertex();
				vertex.color = colorTop;
				vertex.x = radius * MathUtil.cos(angle);
				vertex.y = 0.;
				vertex.z = radius * MathUtil.sin(angle);
				vertex.nx = vertex.x;
				vertex.ny = vertex.y;
				vertex.nz = vertex.z;
				vertex.normalize();
				vertices.push(vertex);
				
				i++;
			}
			var nonWrappedSize:Int = vertices.length - 1;

			// close top
			vertex = new Vertex();
			vertex.color = colorTop;
			vertex.x = oblique;
			vertex.y = length;
			vertex.z = 0.;
			vertex.nx = 0.;
			vertex.ny = 1.;
			vertex.nz = 0.;
			vertices.push(vertex);

			var index:Int = vertices.length - 1;
            i = 0;
			while(i != nonWrappedSize)
			{
				indices.push ( i + 0 );
				indices.push ( index );
				indices.push ( i + 1 );
				
				i++;
			}

			indices.push(i + 0);
			indices.push(index);
			indices.push(0);

			// close down
			vertex = new Vertex();
			vertex.color = colorBottom;
			vertex.x = 0;
			vertex.y = 0;
			vertex.z = 0.;
			vertex.nx = 0.;
			vertex.ny = -1.;
			vertex.nz = 0.;
			vertices.push(vertex);


			index = vertices.length - 1;
            i = 0;
			while(i != nonWrappedSize)
			{
				indices.push(index);
				indices.push(i + 0);
				indices.push(i + 1);
				
				i++;
			}

			indices.push(index);
			indices.push(i + 0);
			indices.push(0);

			recalculateBoundingBox();
	}
}
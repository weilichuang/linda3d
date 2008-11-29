package  linda.mesh.objects;

	class Cone extends Cylinder
	{
		public function new (?radius : Float = 100., ?height : Float = 100., ?segmentsW : Int = 8, ?segmentsH : Int = 6)
		{
			super (radius, height, segmentsW, segmentsH, 0);
		}
	}

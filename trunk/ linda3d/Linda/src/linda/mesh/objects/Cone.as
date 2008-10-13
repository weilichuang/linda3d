package  linda.mesh.objects
{
	public class Cone extends Cylinder
	{
		public function Cone (radius : Number = 100, height : Number = 100, segmentsW : int = 8, segmentsH : int = 6)
		{
			super (radius, height, segmentsW, segmentsH, 0);
		}
	}
}

package linda.mesh.export
{
	import flash.utils.ByteArray;
	
	import linda.mesh.IMesh;
	
	public interface IEncoder
	{
		function get bytes():ByteArray;
		function clear():void;
		function encode (m : IMesh) : void;
	}
}
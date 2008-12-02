/**
 * ...
 * @author DefaultUser (Tools -> Custom Arguments...)
 */

package linda.scene;
    import linda.mesh.LineBuffer;
    import linda.math.Vector3;
	import linda.material.Material;
	import linda.math.AABBox3D;
	import linda.math.Matrix4;
	import linda.math.Vertex;
	import linda.video.IVideoDriver;

class LineBufferSceneNode extends SceneNode
{
	private var lineBuffer:LineBuffer;
	private var alpha:Float;
	public function new(mgr:SceneManager,?buffer : LineBuffer = null)
	{
		super (mgr);
		alpha = 1.0;
		setLineBuffer(buffer);
	}
	override public function destroy():Void
	{
		super.destroy();
		lineBuffer=null;
	}
	public  function setMeshBuffer (buffer : LineBuffer) : Void
	{
		lineBuffer = buffer;
	}
	public function setAlpha(value:Float):Void 
	{
		if (value < 0) alpha = 0;
		else if (value > 1) alpha = 1;
		else alpha = value;
	}
	public function getAlpha():Float
	{
		return this.alpha;
	}
	override public function onRegisterSceneNode() : Void
	{
		if (visible)
		{
			if (alpha < 1)
			{
				sceneManager.registerNodeForRendering(this, SceneNode.TRANSPARENT);
			}else
			{
				sceneManager.registerNodeForRendering(this, SceneNode.SOLID);
			}
			super.onRegisterSceneNode();
		}
	}
	override public function render() : Void
	{
		if (lineBuffer == null) return;
			
		var driver : IVideoDriver = sceneManager.getVideoDriver();
		driver.setTransformWorld(_absoluteMatrix);
        driver.drawIndexedLineList(lineBuffer.vertices, lineBuffer.vertices.length, lineBuffer.indices, lineBuffer.indices.length);
		if(debug)
		{
			driver.draw3DBox(lineBuffer.boundingBox,driver.getDebugColor());
		}
	}
	override  public function getBoundingBox () : AABBox3D
	{
		return lineBuffer.boundingBox;
	}
}
/**
 * ...
 * @author andy
 */

package linda.math;

class Particle 
{
    // Position of the particle
    public var pos:Vector3;

	// Direction and speed of the particle
	public var vector:Vector3;

	// Start life time of the particle
	public var startTime:Int;

	// End life time of the particle
	public var endTime:Int;

	// Current color of the particle
	public var color:Color;

	// Original color of the particle.
	/** That's the color of the particle it had when it was emitted. */
	public var startColor:Color;

	// Original direction and speed of the particle.
	/** The direction and speed the particle had when it was emitted. */
	public var startVector:Vector3;

	// Scale of the particle.
	/** The current scale of the particle. */
	public var size:Dimension2D;

	// Original scale of the particle.
	/** The scale of the particle when it was emitted. */
	public var startSize:Dimension2D;
	public function new() 
	{
	}
	
}
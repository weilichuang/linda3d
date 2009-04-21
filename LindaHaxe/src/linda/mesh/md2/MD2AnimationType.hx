package linda.mesh.md2;

class MD2AnimationType
{
	public static inline var STAND              :AnimationData = new AnimationData(  0,  39,  9);
	public static inline var RUN                :AnimationData = new AnimationData( 40,  45, 10);
	public static inline var ATTACK             :AnimationData = new AnimationData( 46,  53, 10);
	public static inline var PAIN_A             :AnimationData = new AnimationData( 54,  57,  7);
	public static inline var PAIN_B             :AnimationData = new AnimationData( 58,  61,  7);
	public static inline var PAIN_C             :AnimationData = new AnimationData( 62,  65,  7);
	public static inline var JUMP               :AnimationData = new AnimationData( 66,  71,  7);
	public static inline var FLIP               :AnimationData = new AnimationData( 72,  83,  7);
	public static inline var SALUTE             :AnimationData = new AnimationData( 84,  94,  7);
	public static inline var FALLBACK           :AnimationData = new AnimationData( 95, 111, 10);
	public static inline var WAVE               :AnimationData = new AnimationData(112, 122,  7);
	public static inline var POINT              :AnimationData = new AnimationData(123, 134,  6);
	public static inline var CROUCH_STAND       :AnimationData = new AnimationData(135, 153, 10);
	public static inline var CROUCH_WALK        :AnimationData = new AnimationData(154, 159,  7);
	public static inline var CROUCH_ATTACK      :AnimationData = new AnimationData(160, 168, 10);
	public static inline var CROUCH_PAIN        :AnimationData = new AnimationData(169, 172,  7);
	public static inline var CROUCH_DEATH       :AnimationData = new AnimationData(173, 177,  5);
	public static inline var DEATH_FALLBACK     :AnimationData = new AnimationData(178, 183,  7);
	public static inline var DEATH_FALLFORWARD  :AnimationData = new AnimationData(184, 189,  7);
	public static inline var DEATH_FALLBACKSLOW :AnimationData = new AnimationData(190, 197,  7);
	public static inline var BOOM               :AnimationData = new AnimationData(197, 197,  5);
	public static inline var ALL                :AnimationData = new AnimationData(  0, 197,  7);
}
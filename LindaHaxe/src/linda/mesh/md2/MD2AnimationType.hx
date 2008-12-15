package linda.mesh.md2;

class MD2AnimationType
{
	public static inline var STAND              :MD2Frame = new MD2Frame(  0,  39,  9);
	public static inline var RUN                :MD2Frame = new MD2Frame( 40,  45, 10);
	public static inline var ATTACK             :MD2Frame = new MD2Frame( 46,  53, 10);
	public static inline var PAIN_A             :MD2Frame = new MD2Frame( 54,  57,  7);
	public static inline var PAIN_B             :MD2Frame = new MD2Frame( 58,  61,  7);
	public static inline var PAIN_C             :MD2Frame = new MD2Frame( 62,  65,  7);
	public static inline var JUMP               :MD2Frame = new MD2Frame( 66,  71,  7);
	public static inline var FLIP               :MD2Frame = new MD2Frame( 72,  83,  7);
	public static inline var SALUTE             :MD2Frame = new MD2Frame( 84,  94,  7);
	public static inline var FALLBACK           :MD2Frame = new MD2Frame( 95, 111, 10);
	public static inline var WAVE               :MD2Frame = new MD2Frame(112, 122,  7);
	public static inline var POINT              :MD2Frame = new MD2Frame(123, 134,  6);
	public static inline var CROUCH_STAND       :MD2Frame = new MD2Frame(135, 153, 10);
	public static inline var CROUCH_WALK        :MD2Frame = new MD2Frame(154, 159,  7);
	public static inline var CROUCH_ATTACK      :MD2Frame = new MD2Frame(160, 168, 10);
	public static inline var CROUCH_PAIN        :MD2Frame = new MD2Frame(169, 172,  7);
	public static inline var CROUCH_DEATH       :MD2Frame = new MD2Frame(173, 177,  5);
	public static inline var DEATH_FALLBACK     :MD2Frame = new MD2Frame(178, 183,  7);
	public static inline var DEATH_FALLFORWARD  :MD2Frame = new MD2Frame(184, 189,  7);
	public static inline var DEATH_FALLBACKSLOW :MD2Frame = new MD2Frame(190, 197,  7);
	public static inline var BOOM               :MD2Frame = new MD2Frame(197, 197,  5);
	public static inline var ALL                :MD2Frame = new MD2Frame(  0, 197,  7);
}
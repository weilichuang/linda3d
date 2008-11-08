package mini3d.mesh.md2
{
	public class MD2AnimationType
	{
		public static const STAND              :MD2Frame = new MD2Frame(  0,  39,  9);
		public static const RUN                :MD2Frame = new MD2Frame( 40,  45, 10);
		public static const ATTACK             :MD2Frame = new MD2Frame( 46,  53, 10);
		public static const PAIN_A             :MD2Frame = new MD2Frame( 54,  57,  7);
		public static const PAIN_B             :MD2Frame = new MD2Frame( 58,  61,  7);
		public static const PAIN_C             :MD2Frame = new MD2Frame( 62,  65,  7);
		public static const JUMP               :MD2Frame = new MD2Frame( 66,  71,  7);
		public static const FLIP               :MD2Frame = new MD2Frame( 72,  83,  7);
		public static const SALUTE             :MD2Frame = new MD2Frame( 84,  94,  7);
		public static const FALLBACK           :MD2Frame = new MD2Frame( 95, 111, 10);
		public static const WAVE               :MD2Frame = new MD2Frame(112, 122,  7);
		public static const POINT              :MD2Frame = new MD2Frame(123, 134,  6);
		public static const CROUCH_STAND       :MD2Frame = new MD2Frame(135, 153, 10);
		public static const CROUCH_WALK        :MD2Frame = new MD2Frame(154, 159,  7);
		public static const CROUCH_ATTACK      :MD2Frame = new MD2Frame(160, 168, 10);
		public static const CROUCH_PAIN        :MD2Frame = new MD2Frame(169, 172,  7);
		public static const CROUCH_DEATH       :MD2Frame = new MD2Frame(173, 177,  5);
		public static const DEATH_FALLBACK     :MD2Frame = new MD2Frame(178, 183,  7);
		public static const DEATH_FALLFORWARD  :MD2Frame = new MD2Frame(184, 189,  7);
		public static const DEATH_FALLBACKSLOW :MD2Frame = new MD2Frame(190, 197,  7);
		public static const BOOM               :MD2Frame = new MD2Frame(197, 197,  5);
		public static const ALL                :MD2Frame = new MD2Frame(  0, 197,  7);
	}
}
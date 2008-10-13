package linda.mesh.animation
{
	public class MD2AnimationType
	{
		public static const STAND : int = 0;
		public static const RUN : int = 1;
		public static const ATTACK : int = 2;
		public static const PAIN_A : int = 3;
		public static const PAIN_B : int = 4;
		public static const PAIN_C : int = 5;
		public static const JUMP : int = 6;
		public static const FLIP : int = 7;
		public static const SALUTE : int = 8;
		public static const FALLBACK : int = 9;
		public static const WAVE : int = 10;
		public static const POINT : int = 11;
		public static const CROUCH_STAND : int = 12;
		public static const CROUCH_WALK : int = 13;
		public static const CROUCH_ATTACK : int = 14;
		public static const CROUCH_PAIN : int = 15;
		public static const CROUCH_DEATH : int = 16;
		public static const DEATH_FALLBACK : int = 17;
		public static const DEATH_FALLFORWARD : int = 18;
		public static const DEATH_FALLBACKSLOW : int = 19;
		public static const BOOM : int = 20;
		public static const ALL : int = 21;
		public static const COUNT : int = 22;
		public static const animationList : Array = [[0, 39, 9 ] , // STAND
		[40, 45, 10 ] , // RUN
		[46, 53, 10 ] , // ATTACK
		[54, 57, 7 ] , // PAIN_A
		[58, 61, 7 ] , // PAIN_B
		[62, 65, 7 ] , // PAIN_C
		[66, 71, 7 ] , // JUMP
		[72, 83, 7 ] , // FLIP
		[84, 94, 7 ] , // SALUTE
		[95, 111, 10 ] , // FALLBACK
		[112, 122, 7 ] , // WAVE
		[123, 134, 6 ] , // POINT
		[135, 153, 10 ] , // CROUCH_STAND
		[154, 159, 7 ] , // CROUCH_WALK
		[160, 168, 10 ] , // CROUCH_ATTACK
		[169, 172, 7 ] , // CROUCH_PAIN
		[173, 177, 5 ] , // CROUCH_DEATH
		[178, 183, 7 ] , // DEATH_FALLBACK
		[184, 189, 7 ] , // DEATH_FALLFORWARD
		[190, 197, 7 ] , // DEATH_FALLBACKSLOW
		[197, 197, 5 ] , // BOOM
		[0, 197, 7 ]];
		}
}
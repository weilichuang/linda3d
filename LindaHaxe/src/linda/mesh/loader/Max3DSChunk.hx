package linda.mesh.loader;

class Max3DSChunk 
{
		public static inline var MAIN3DS : UInt = 0x4D4D;
		public static inline var VERSION : UInt = 0x0002;
		public static inline var EDIT3DS : UInt = 0x3D3D;
		public static inline var KEYF3DS : UInt = 0xB000;
		//EDIT_3DS
		public static inline var EDIT_CONFIG1 : UInt = 0x0100;
		public static inline var EDIT_CONFIG2 : UInt = 0x3D3E;
		public static inline var LIGHT : UInt = 0x4600;
		public static inline var EDIT_OBJECT : UInt = 0x4000;
		public static inline var EDIT_MATERIAL : UInt = 0xAFFF;
		public static inline var MAT_NAME : UInt = 0xA000;
		public static inline var MAT_MAP : UInt = 0xA200;
		public static inline var MAT_PATH : UInt = 0xA300;
		public static inline var OBJ_TRIMESH : UInt = 0x4100;
		public static inline var OBJ_CAMERA : UInt = 0x4700;
		//EIDT_OBJECT:
		public static inline var TRI_VERTEX : UInt = 0x4110;
		public static inline var TRI_FACEVERT : UInt = 0x4120;
		public static inline var TRI_FACEMAT : UInt = 0x4130;
		public static inline var TRI_UV : UInt = 0x4140;
		public static inline var TRI_LOCAL : UInt = 0x4160;
		//KEYF3DS:
		public static inline var KEYF_OBJDES : UInt = 0xB002;
		public static inline var KEYF_FRAMES : UInt = 0xB008;
		public static inline var KEYF_OBJHIERARCH : UInt = 0xB010;
		public static inline var KEYF_PIVOTPOINT : UInt = 0xB013;
		public static inline var KEYF_OBJPIVOT : UInt = 0xB020;
}

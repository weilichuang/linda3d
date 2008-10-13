package linda.video.scanline
{
	import linda.video.TRType;
	
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	

	internal class SBuffer 
	{
		/** variable: lines
		 * Array of <Scanline>, one for each vert
		 */
		public var lines:Array;
		/** variable: lineCount
		 * Total line count
		 */
		public var lineCount:int;
		
		/** variable: segments
		 * Array of <Seg>, seg buffer
		 */
		public var segments:Array;
		
		/** variable: materials
		 * Array of <Mat>, mat buffer
		 */
		public var materials:Array;
		
		/** variable: segmentCount
		 * Total segment count
		 */
		public var segmentCount:int;
		
		/** varibale: materialCount
		 * Total material count
		 */
		public var materialCount:int;
		
		/** variable: segmentsUsed
		 * Used segement count
		 */
		public var segmentsUsed:int;
		
		/** variable: materialsUsed
		 * Used material count
		 */
		public var materialsUsed:int;
		
		/** variable: renderTarget
		 * BitmapData to render to
		 */
		private var renderTarget:BitmapData;
		
		/** variable: rect
		 * Rect to use when rendering flat color
		 */
		private var rect:Rectangle = new Rectangle(0,0,1,1);
		// =======================================================
		//! constructor
		// =======================================================
		/** 
		 * function: SSBuffer
		 * Creates a new sbuffer
		 */
		public function SBuffer() 
		{
			// nothing to do.
		}
		
		public function getRenderTarget():BitmapData
		{
			return renderTarget;
		}
		
		/**
		 * function: init
		 * Initializes the sbuffer
		 * parameters:
		 * renderTarget - <ITexture> to render sbuffer
		 * width and height for sbuffer are taken from the renderTarget's width and height values
		 * 
		 */ 
		public function init(renderTarget:BitmapData):void 
		{
			// set render target
			this.renderTarget = renderTarget;
			
			// create the scan lines based on the height of the render target
			if(!lines)
			{
				lines = new Array();
			}	
			else
			{
				lines.length = 0;
			}
			
			var l:int = renderTarget.height;
			for(var i:int=0;i<l;i++)
			{
				lines[i] = new Scanline();
			}
			lineCount = lines.length;
			
			/* create segments buffer
			Estimate 500 triangles in a line
			one segment per triangle * render target height is needed.
			We have checks in the triangle fill routines
			to allocate more if needed*/
			segmentCount = 0;
			
			if(!segments)
			{
				segments = new Array();
			}
			else	
			{
				segments.length = 0;
			}
			
			
			allocateSegments(renderTarget.height * 100);
			
			
			/* create material buffer
			Two mats per triangle are needed.
			Estimate 2000 triangles
			We have checks in the triangle fill routines
			to allocate more if needed*/
			if(!materials)
			{
				materials = new Array();
			}
			else
			{
				materials.length = 0;
			}
				
			materialCount = 0;
			allocateMaterial(100);
		}
		
		/** function: allocateMaterial
		 */
		public function allocateMaterial(amount:int):void
		{
			var l:int = materialCount + amount;
			for(var i:int=materialCount;i<l;i++)
			{
				materials[i] = new Mat();
			}
			materialCount = materials.length;
		}
		
		/** function: allocateSegments
		 */
		public function allocateSegments(amount:int):void
		{
			var l:int = segmentCount + amount;
			for(var i:int=segmentCount;i<l;i++)
			{
				segments[i] = new Seg();
			}
			segmentCount = segments.length;
		}
		
		/** function: reset
		 * Resets the buffer before rendering
		 * 
		 * parameters:
		 * fillBG		- <Boolean>, fill the render target background before rendering?
		 * color 		- <uint>, the background color to fill the render target if fillBG is true
		 */
		public function reset(fillBG:Boolean, color:uint):void 
		{
			// lock the render target
			renderTarget.lock();
			
			if(fillBG)
			{
				renderTarget.fillRect(renderTarget.rect,color);
			}
			
			// reset buffer use
			segmentsUsed = 0;
			materialsUsed = 0;
			
			// loop all lines and reset
			for (var i:int=0;i<lineCount;i++)
			{ 
				var ln:Scanline = lines[i];
				ln.n = 0;
				ln.na = 0;
			}
		}
		
		/** function: insertAlphaSegment
		 */
		public function insertAlphaSegment(seg:Seg,y:int):void
		{
			// get current line
			var scanline:Scanline = lines[y];
						
			// get first segment
			var seg1:Seg = scanline.firstAlpha;
			var seg1_last:Seg = null;
			
			// loop all segments
			for(var i:int=0;i<scanline.na;i++)
			{
				var seg0z0:Number = seg.z0 + (seg.dzdx * seg.x0);
				var seg1z0:Number = seg1.z0 + (seg1.dzdx * seg1.x0);
				var seg0z1:Number = seg.z0 + (seg.dzdx * seg.x1);
				var seg1z1:Number = seg1.z0 + (seg1.dzdx * seg1.x1);
				
				// check first point
				if(seg0z0 < seg1z0)
				{
					// check second point
					if(seg0z1 < seg1z1)
					{
						// seg is in front of seg1
						if(seg1.prev == null)
						{
							// insert seg as first on scanline
							scanline.firstAlpha = seg;
							scanline.na++;
							seg.prev = null;
							// link seg1
							seg.next = seg1;
							seg1.prev = seg;
							// inserted whole seg - exit
							return;
						}
						else
						{
							// insert seg between seg1.prev and seg1
							seg1.prev.next = seg;
							seg.prev = seg1.prev;
							seg1.prev = seg;
							seg.next = seg1;
							scanline.na++;
							// inserted whole seg - exit
							return;
						}
					}
					else // seg0z1 > seg1z1
					{
						seg1_last = seg1;
						seg1 = seg1.next;
					}
				}
				else // seg0z0 >= seg1z0
				{
					// check second point
					if(seg0z1 < seg1z1)
					{
						seg1_last = seg1;
						seg1 = seg1.next;
					}
					else // seg.z1 >= seg1.z1
					{
						// seg is behind seg1
						seg1_last = seg1;
						seg1 = seg1.next;
						// continue
					}
				}
			}
			
			// insert
			if (scanline.na > 0)
			{
				// add on
				seg1_last.next = seg;
				seg.prev = seg1_last;
				scanline.na++;
			}
			else
			{
				// insert as first segment
				scanline.firstAlpha = seg;
				seg.prev = null;
				scanline.na++;
			}
			
			
			//seg.next = null;			
		}

		public function render():void 
		{
			var sc:int;
			var x1:int, x0:int,c:uint,c2:uint;
			var tw:int, th:int, z0:Number, zs:Number;
			var lx1:Number, rx1:Number, dx:Number;
			var subTex:Number;
			
			// line
			var ln:Scanline;

			// color
			var r:Number, g:Number, b:Number, a:Number, rs:Number, gs:Number, bs:Number, ax:Number;
			
			// texture
			var t:BitmapData;
			var u:Number, v:Number, us:Number, vs:Number;
			
			var w:Number
						
			var s:Seg, m:Mat; 
			
			var rc:Number;
			var gc:Number;
			var bc:Number;
							
			// loop all lines
			for(var y:int=0;y<lineCount;y++)
			{
				// get the line
				ln = lines[y];

				// get first segment & seg count
				s = ln.first;
				sc = ln.n;

				// loop all segments (SOLID)
				for(var l:int=0;l<sc;l++)
				{
					
					// get material		
					m = s.m;

					if(m.t)
					{
						/** ========================================================
						 * texture flat, texture gouraud
						 * =========================================================
						 */
						 if(m.p == 6)//VideoDriverSoftware.TEXTURE_GOURAUD)
						 {
						 	// ---------------------------------------------------------------------------
						 	x0 = s.x0;
							x1 = s.x1;
							
							t = m.t;
							tw = t.width-1;
							th = t.height-1;
							
							// get x
							lx1 = m.lx0 + (m.ldxdy * y);
							rx1 = m.rx0 + (m.rdxdy * y);
							
							// get sub texel adjustment
							subTex = int(lx1)+1-lx1;//Math.ceil(lx1) - lx1;

							// get span
							dx = 1 / (rx1 - lx1);
							
							// get u
							us = (((m.ru0 + (m.rdudy*y)) - (m.lu0 + (m.ldudy*y)))* dx);
							u = (m.lu0 + (m.ldudy * y)) + (subTex * us) - (lx1*us);
							
							// get v
							vs = (((m.rv0 + (m.rdvdy*y))	- (m.lv0 + (m.ldvdy*y)))* dx);
							v = (m.lv0 + (m.ldvdy * y)) + (subTex * vs) - (lx1*vs);
							
							// get r
							rs = (((m.rr0 + (m.rdrdy * y)) - (m.lr0 + (m.ldrdy * y))) * dx);
							r = (m.lr0 + (m.ldrdy * y)) - (lx1*rs);
							
							// get g
							gs = (((m.rg0 + (m.rdgdy * y)) - (m.lg0 + (m.ldgdy * y))) * dx);
							g = (m.lg0 + (m.ldgdy * y)) - (lx1*gs);
							
							// get b
							bs = (((m.rb0 + (m.rdbdy * y)) - (m.lb0 + (m.ldbdy * y))) * dx);
							b = (m.lb0 + (m.ldbdy * y)) - (lx1*bs);

							if(m.pc) // perspective correct
							{
								z0 = s.z0;
								zs = s.dzdx;
							
								// iterate over span
								for(; x0<x1; x0++ )
								{
									/*w = 1/(z0 + (zs * x0));
									c = t.getPixel((((u + (us * x0)))*w)&tw,(((v + (vs * x0)))*w)&th);
																		
									var rc:Number = ((((c>>16)&0xFF) * (r + (rs * x0)))>>8)*2
									var gc:Number = ((((c>>8)&0xFF) * (g + (gs * x0)))>>8)*2
									var bc:Number = (((c&0xFF) * (b + (bs * x0)))>>8)*2
									
									renderTarget.setPixel(x0,y,(rc > 0xFF ? 0xFF0000 : rc<<16)|(gc > 0xFF ? 0xFF00 : gc<<8)|(bc > 0xFF ? 0xFF : bc))		
									*/
									w = 1/(z0 + (zs * x0));
									c = t.getPixel((((u + (us * x0)))*w)&tw,(((v + (vs * x0)))*w)&th);

									renderTarget.setPixel(x0,y,(((((c>>16)&0xFF) * (r + (rs * x0)))>>8)<<16) | (((((c>>8)&0xFF) * (g + (gs * x0)))>>8)<<8) | (((c&0xFF) * (b + (bs * x0)))>>8) )		
								
								}
							}
							else // affine
							{
								// iterate over span
								for(;x0<x1;x0++)
								{
									c = t.getPixel(((u + (us * x0)))&tw,((v + (vs * x0)))&th);
									renderTarget.setPixel(x0,y,(((((c>>16)&0xFF) * (r + (rs * x0)))>>8)<<16) | (((((c>>8)&0xFF) * (g + (gs * x0)))>>8)<<8) | (((c&0xFF) * (b + (bs * x0)))>>8) )		
								
								}
							}
							// ---------------------------------------------------------------------------
						 }
						 else // VideoDriverSoftware.TEXTURE_FLAT
						 {
						 	// ---------------------------------------------------------------------------
						 	x0 = s.x0;
							x1 = s.x1;
							
							t = m.t;
							tw = t.width-1;
							th = t.height-1;
							
							// get x
							lx1 = m.lx0 + (m.ldxdy * y);
							rx1 = m.rx0 + (m.rdxdy * y);
							
							// get sub texel adjustment
							subTex = int(lx1)+1-lx1;//Math.ceil(lx1) - lx1;

							// get span
							dx = 1 / (rx1 - lx1);
							
							// get u
							us = (((m.ru0 + (m.rdudy*y)) - (m.lu0 + (m.ldudy*y)))* dx);
							u = (m.lu0 + (m.ldudy * y)) + (us * subTex)-(lx1*us);
							
							// get v
							vs = (((m.rv0 + (m.rdvdy*y)) - (m.lv0 + (m.ldvdy*y)))* dx);
							v = (m.lv0 + (m.ldvdy * y)) + (vs * subTex) -(lx1*vs);
							
							if(m.pc) // perspective correct
							{
								z0 = s.z0
								zs = s.dzdx
							
								// iterate over span
								for(;x0<x1;x0++)
								{
									
									renderTarget.setPixel(x0,y,t.getPixel((((u + (us * x0)))/(z0 + (zs * x0)))&tw,(((v + (vs * x0)))/(z0 + (zs * x0)))&th));
								}
							}
							else // affine
							{
								// iterate over span
								for(;x0<x1;x0++)
								{
									renderTarget.setPixel(x0,y,t.getPixel((((u + (us * x0))))&tw,(((v + (vs * x0))))&th));
								}
							}
							// ---------------------------------------------------------------------------
						 }
					}
					else
					{
						/** ========================================================
						 * wire, flat, gouraud
						 * =========================================================
						 */
						 
						if(m.p == TRType.GOURAUD)
						{
							x0 = s.x0;
							x1 = s.x1;
							
							// make x int
							lx1 = (m.lx0 + (m.ldxdy * y));
							rx1 = (m.rx0 + (m.rdxdy * y));
							
							// get span
							dx = 1 / (rx1 - lx1);
							
							// get r
							rs = (((m.rr0 + (m.rdrdy*y)) - (m.lr0 + (m.ldrdy*y)))* dx);
							r = (m.lr0 + (m.ldrdy*y)) - (lx1*rs);
							
							// get g
							gs = ((m.rg0 + (m.rdgdy * y)) - (m.lg0 + (m.ldgdy * y))) * dx;
							g = (m.lg0 + (m.ldgdy * y)) - (lx1*gs);
							
							// get b
							bs = ((m.rb0 + (m.rdbdy * y)) - (m.lb0 + (m.ldbdy * y))) * dx;
							b = (m.lb0 + (m.ldbdy * y)) - (lx1*bs);
							
							// iterate over span
							for(;x0<x1;x0++)
							{
								var rr:Number = (r + (rs * x0));
								var gg:Number = (g + (gs * x0));
								var bb:Number = (b + (bs * x0));
								
								rr = rr > 0xFF ? 0xFF : (rr < 0x0 ? 0x0 : (rr&0xFF));
								gg = gg > 0xFF ? 0xFF : (gg < 0x0 ? 0x0 : (gg&0xFF));
								bb = bb > 0xFF ? 0xFF : (bb < 0x0 ? 0x0 : (bb&0xFF));
								
								renderTarget.setPixel(x0,y,(rr<<16)+(gg<<8)+bb)
								
							}
						}
						else if(m.p == TRType.FLAT)
						{
							rect.x = s.x0;
							rect.y = y;
							rect.right = s.x1;
							renderTarget.fillRect(rect,(m.rr0<<16)+(m.rg0<<8)+m.rb0);
						}
						else // VideoDriverSoftware.WIRE
						{
							// make x 
							lx1 = (m.lx0 + (m.ldxdy * y));
							rx1 = (m.rx0 + (m.rdxdy * y));
							
							// get span
							dx = 1 / (rx1 - lx1);
							
							// get r
							rs = (((m.rr0 + (m.rdrdy*y)) - (m.lr0 + (m.ldrdy*y)))* dx);
							r = (m.lr0 + (m.ldrdy*y)) - (lx1*rs);
							
							// get g
							gs = ((m.rg0 + (m.rdgdy * y)) - (m.lg0 + (m.ldgdy * y))) * dx;
							g = (m.lg0 + (m.ldgdy * y)) - (lx1*gs);
							
							// get b
							bs = ((m.rb0 + (m.rdbdy * y)) - (m.lb0 + (m.ldbdy * y))) * dx;
							b = (m.lb0 + (m.ldbdy * y)) - (lx1*bs);
							
							rr = (r + (rs * s.x0));
							gg = (g + (gs * s.x0));
							bb = (b + (bs * s.x0));
							
							rr = rr > 0xFF ? 0xFF : (rr < 0x0 ? 0x0 : (rr&0xFF));
							gg = gg > 0xFF ? 0xFF : (gg < 0x0 ? 0x0 : (gg&0xFF));
							bb = bb > 0xFF ? 0xFF : (bb < 0x0 ? 0x0 : (bb&0xFF));
								
							renderTarget.setPixel(s.x0,y,(rr<<16)+(gg<<8)+bb);
							
							rr = (r + (rs * s.x1-1));
							gg = (g + (gs * s.x1-1));
							bb = (b + (bs * s.x1-1));
							
							rr = rr > 0xFF ? 0xFF : (rr < 0x0 ? 0x0 : (rr&0xFF));
							gg = gg > 0xFF ? 0xFF : (gg < 0x0 ? 0x0 : (gg&0xFF));
							bb = bb > 0xFF ? 0xFF : (bb < 0x0 ? 0x0 : (bb&0xFF));
								
							renderTarget.setPixel(s.x1-1,y,(rr<<16)+(gg<<8)+bb);
						}
					}
					s = s.next;
				}// end loop all segments (SOLID)
				
				/* ALPHA starts here*/
				
				// get first segment & seg count
				s = ln.firstAlpha;
				sc = ln.na;
				
				// loop all segments (ALPHA)
				for(l=0;l<sc;l++)
				{
					// get material		
					m = s.m;
					
					// read material
					if(m.t)
					{
						/** ========================================================
						 * texture flat, texture gouraud
						 * =========================================================
						 */
						 if(m.p == TRType.TEXTURE_GOURAUD_ALPHA)
						 {
							 	// ---------------------------------------------------------------------------
							 	x0 = s.x0;
								x1 = s.x1;
								
								t = m.t;
								tw = t.width-1;
								th = t.height-1;
								
								// make x int
								lx1 = int(m.lx0 + (m.ldxdy * y));
								rx1 = int(m.rx0 + (m.rdxdy * y));
								
								// get span
								dx = 1 / (rx1 - lx1);
								
								// get sub texel adjustment
								subTex = int(lx1)+1-lx1;//Math.ceil(lx1) - lx1;

								// get u
								us = (((m.ru0 + (m.rdudy*y)) - (m.lu0 + (m.ldudy*y)))* dx);
								u = (m.lu0 + (m.ldudy * y)) + (us * subTex) -(lx1*us);
								
								// get v
								vs = (((m.rv0 + (m.rdvdy*y)) - (m.lv0 + (m.ldvdy*y)))* dx);
								v = (m.lv0 + (m.ldvdy * y)) + (vs * subTex) -(lx1*vs);
							
								// get r
								rs = (((m.rr0 + (m.rdrdy*y)) - (m.lr0 + (m.ldrdy*y)))* dx);
								r = (m.lr0 + (m.ldrdy*y)) - (lx1*rs);
								
								// get g
								gs = ((m.rg0 + (m.rdgdy * y)) - (m.lg0 + (m.ldgdy * y))) * dx;
								g = (m.lg0 + (m.ldgdy * y)) - (lx1*gs);
								
								// get b
								bs = ((m.rb0 + (m.rdbdy * y)) - (m.lb0 + (m.ldbdy * y))) * dx;
								b = (m.lb0 + (m.ldbdy * y)) - (lx1*bs);	
								
								if(m.pc)
								{
									z0 = s.z0;
									zs = s.dzdx;
								
									// iterate over span
									for(; x0<x1; x0++ )
									{
										w = 1/(z0 + (zs * x0));
										c = renderTarget.getPixel(x0,y);
										c2 = t.getPixel32((((u + (us * x0)))*w)&tw,(((v + (vs * x0)))*w)&th);
										a = (c2>>24)&0xFF;
														
										if(a > 0)
										{		
											var aa:Number = (a/255);
										
											rc = ((((c2>>16)&0xFF) * (r + (rs * x0)))>>8)*2;
											gc = ((((c2>>8)&0xFF) * (g + (gs * x0)))>>8)*2;
											bc = (((c2&0xFF) * (b + (bs * x0)))>>8)*2;

											rr = ((c>>16)&0xFF)+(( (rc > 0xFF ? 0xFF : rc) -((c>>16)&0xFF))*aa);
											gg = ((c>>8)&0xFF)+(( (gc > 0xFF ? 0xFF : gc) -((c>>8)&0xFF))*aa);
											bb = (c&0xFF)+(( (bc > 0xFF ? 0xFF : bc) -(c&0xFF))*aa);
												
											renderTarget.setPixel(x0,y,(rr<<16) | (gg<<8) | bb )		
										}
									}
									
								}
								else
								{
									// iterate over span
									for(;x0<x1;x0++)
									{
										c = renderTarget.getPixel(x0,y);
										c2 = t.getPixel32(((u + (us * x0)))&tw,((v + (vs * x0)))&th);
										a = (c2>>24)&0xFF;
													
										if(a > 0)
										{		
											aa = (a/255);
																					
											rc = ((((c2>>16)&0xFF) * (r + (rs * x0)))>>8)*2;
											gc = ((((c2>>8)&0xFF) * (g + (gs * x0)))>>8)*2;
											bc = (((c2&0xFF) * (b + (bs * x0)))>>8)*2;

											rr = ((c>>16)&0xFF)+(( (rc > 0xFF ? 0xFF : rc) -((c>>16)&0xFF))*aa);
											gg = ((c>>8)&0xFF)+(( (gc > 0xFF ? 0xFF : gc) -((c>>8)&0xFF))*aa);
											bb = (c&0xFF)+(( (bc > 0xFF ? 0xFF : bc) -(c&0xFF))*aa);
												
											renderTarget.setPixel(x0,y,(rr<<16) | (gg<<8) | bb )				
										}
									}
								}
						 }
						 else // FLAT_ALPHA
						 {
							 	x0 = s.x0;
								x1 = s.x1;
								
								t = m.t;
								tw = t.width-1;
								th = t.height-1;
								
								// get x
								lx1 = m.lx0 + (m.ldxdy * y);
								rx1 = m.rx0 + (m.rdxdy * y);
								
								// get span
								dx = 1 / (rx1 - lx1);
		
								// get sub texel adjustment
								subTex = int(lx1)+1-lx1;//Math.ceil(lx1) - lx1;

								// get u
								us = (((m.ru0 + (m.rdudy*y)) - (m.lu0 + (m.ldudy*y)))* dx);
								u = (m.lu0 + (m.ldudy * y)) + (us * subTex) -(lx1*us);
								
								// get v
								vs = (((m.rv0 + (m.rdvdy*y))	- (m.lv0 + (m.ldvdy*y)))* dx);
								v = (m.lv0 + (m.ldvdy * y)) + (vs * subTex) -(lx1*vs);
								
								if(m.pc)
								{
									z0 = s.z0;
									zs = s.dzdx;
								
									// iterate over span
									for(;x0<x1;x0++)
									{
										c = renderTarget.getPixel(x0,y);
										c2 = t.getPixel32((((u + (us * x0))) / (z0 + (zs * x0)))&tw,(((v + (vs * x0)))/(z0 + (zs * x0)))&th);
										a = (c2>>24)&0xFF;
													
										if(a > 0)
										{		
											aa = (a/255);
											
											rr = ((c>>16)&0xFF)+((((c2>>16)&0xFF)-((c>>16)&0xFF))*aa);
											gg = ((c>>8)&0xFF)+((((c2>>8)&0xFF)-((c>>8)&0xFF))*aa);
											bb = (c&0xFF)+(((c2&0xFF)-(c&0xFF))*aa);
											
											renderTarget.setPixel(x0,y, (rr<<16) | (gg<<8) | bb );
										}
									}
								}
								else
								{
									// iterate over span
									for(;x0<x1;x0++)
									{
										c = renderTarget.getPixel(x0,y);
										c2 = t.getPixel32((((u + (us * x0))))&tw,(((v + (vs * x0))))&th);
										a = (c2>>24)&0xFF;
													
										if(a > 0)
										{		
											aa = (a/255);
											
											rr = ((c>>16)&0xFF)+((((c2>>16)&0xFF)-((c>>16)&0xFF))*aa);
											gg = ((c>>8)&0xFF)+((((c2>>8)&0xFF)-((c>>8)&0xFF))*aa);
											bb = (c&0xFF)+(((c2&0xFF)-(c&0xFF))*aa);
											
											renderTarget.setPixel(x0,y, (rr<<16) | (gg<<8) | bb );
										}
									}
								}
							}
					}
					else 
					{
						/** ========================================================
						 * gouraud Alpha
						 * =========================================================
						 */
							x0 = s.x0;
							x1 = s.x1;
							
							// get x
							lx1 = m.lx0 + (m.ldxdy * y);
							rx1 = m.rx0 + (m.rdxdy * y);
							
							// get span
							dx = 1 / (rx1 - lx1);
							
							// get r
							rs = (((m.rr0 + (m.rdrdy*y)) - (m.lr0 + (m.ldrdy*y)))* dx);
							r = (m.lr0 + (m.ldrdy*y)) - (lx1*rs);
							
							// get g
							gs = ((m.rg0 + (m.rdgdy * y)) - (m.lg0 + (m.ldgdy * y))) * dx;
							g = (m.lg0 + (m.ldgdy * y)) - (lx1*gs);
							
							// get b
							bs = ((m.rb0 + (m.rdbdy * y)) - (m.lb0 + (m.ldbdy * y))) * dx;
							b = (m.lb0 + (m.ldbdy * y)) - (lx1*bs);
							
							// get a
							//ax = ((m.ra0 + (m.rdady * y)) - (m.la0 + (m.ldady * y))) * dx;
							//a = (m.la0 + (m.ldady * y)) - (lx1*ax);
							
							// iterate over span
							for(;x0<x1;x0++)
							{
								c = renderTarget.getPixel(x0,y);
								
								//Todo use material.alpha;
								aa = 0.5;//((a + (ax * x0))/255);
								
								rr = ((c>>16)&0xFF)+(((r + (rs * x0))-((c>>16)&0xFF))*aa);
								gg = ((c>>8)&0xFF)+(((g + (gs * x0))-((c>>8)&0xFF))*aa);
								bb = (c&0xFF)+(((b + (bs * x0))-(c&0xFF))*aa);
								
								renderTarget.setPixel(x0,y, (rr<<16) + (gg<<8) + bb );
							}
					}
					s = s.next;
				}// end loop all segments (ALPHA)
				
			} // end loop all lines (y)
			
			//shadow
			// unlock the render target
			renderTarget.unlock();
		}
	}
}
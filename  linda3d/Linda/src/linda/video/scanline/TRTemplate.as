package linda.video.scanline
{
	import __AS3__.vec.Vector;
	
	import linda.material.*;
	import linda.math.Vertex4D;
	import linda.video.ITriangleRenderer;
	
	import flash.display.*;

	internal class TRTemplate implements ITriangleRenderer
	{
		// left edge - le
		private var ledb:Number;
		private var ledg:Number;
		private var ledr:Number;
		private var ledu:Number;
		private var ledv:Number;
		private var ledx:Number;
		private var ledz:Number;
		private var ler:Number;
		private var leg:Number;
		private var leb:Number;
		private var leu:Number;
		private var lev:Number;
		private var lex:Number;
		private var lez:Number;
		
		// right edge - re
		private var redb:Number;
		private var redg:Number;
		private var redr:Number;
		private var redu:Number;
		private var redv:Number;
		private var redx:Number;
		private var redz:Number;
		private var rer:Number;
		private var reg:Number;
		private var reb:Number;
		private var reu:Number;
		private var rev:Number;
		private var rex:Number;
		private var rez:Number;
		
		
		// buffer
		private var _buffer:SBuffer;
		private var _buffer_mat_array:Array;
		private var _buffer_seg_array:Array;
		private var _buffer_line_array:Array;
		private var _buffer_seg:Seg;
		
		// textures
		private var _material:Material;
		private var _texture:Texture;
		private var _texture_pc_distance:Number;
		private var _texture_mip_distance:Number;
		
		// uv
		private var v0u:Number, v0v:Number;
		private var v1u:Number, v1v:Number;
		private var v2u:Number, v2v:Number;
		
		public var type:int;
		
		public function TRTemplate(buffer:SBuffer)
		{
			// store buffer links
			_buffer = buffer;
			_buffer_mat_array = _buffer.materials;
			_buffer_seg_array = _buffer.segments;
			_buffer_line_array = _buffer.lines;
			// create a segment to reuse when inserting in buffer
			_buffer_seg = new Seg();
		}

		public function drawIndexedTriangleList (vertices : Vector.<Vertex4D>, vertexCount : int, indexList : Vector.<int>, indexCount : int):void
		{
		
			// get used material and segment count
			var mat_count:int = _buffer.materialsUsed;
			var seg_count:int = _buffer.segmentsUsed;
			
			// check resource allocation
			if((mat_count + indexCount*4) > _buffer.materialCount)
			{
				// allocate more materials
				_buffer.allocateMaterial(indexCount*4);
			}
			/*
			if((seg_count + triangleCount * _buffer.lineCount) > _buffer.segmentCount)
			{
				// allocated more segments
				_buffer.allocateSegments(triangleCount * _buffer.lineCount);
			}*/
			
			var tex0:BitmapData = null;
			var v0:Vertex4D;
			var v1:Vertex4D;
			var v2:Vertex4D;
			var tw:int;
			var th:int;
			var pc:Boolean;
			
			// --------------------------------------------------------------------------
			// loop all triangles
			for (var vi:int=0; vi<indexCount; vi+=3)
			{
				// get the three points
				var idx:int = indexList[vi];
				v0 = vertices[idx];
				idx = indexList[int(vi+1)];
				v1 = vertices[idx];
				idx = indexList[int(vi+2)];
				v2 = vertices[idx];
												
				// sort for height for faster drawing.
				if (v0.iy > v1.iy)
				{
					var swpV:Vertex4D = v0;
					v0 = v1;
					v1 = swpV;
				}
				if (v0.iy > v2.iy)
				{
					swpV = v0;
					v0 = v2;
					v2 = swpV;
				}
				if (v1.iy > v2.iy)
				{
					swpV = v1;
					v1 = v2;
					v2 = swpV;
				}
				
				// check resource allocation
				// allocate 10 segments per line, * height of triangle 
				if((seg_count + ((v2.iy - v0.iy) * 2)) > _buffer.segmentCount)
				{
					// allocated more segments
					_buffer.allocateSegments(((v2.iy - v0.iy) * 2));
				}
				
				
				// mip mapping
				if(_texture)
				{
					var at:Number = ( v1.u - v0.u );
					var bt:Number = ( v1.v - v0.v );
					var ct:Number = ( v2.u - v0.u );
					var dt:Number = ( v2.v - v0.v );
					at = at > 0 ? at : -at;
					bt = bt > 0 ? bt : -bt;
					ct = ct > 0 ? ct : -ct;
					dt = dt > 0 ? dt : -dt;
					
					var longest_uv:Number =  at > bt ? at : bt;
					longest_uv =  ct > longest_uv ? ct : longest_uv;
					longest_uv =  dt > longest_uv ? dt : longest_uv;
					longest_uv *= longest_uv;
					
					at = ( v1.x - v0.x );
					bt = ( v1.y - v0.y );
					ct = ( v2.x - v0.x );
					dt = ( v2.y - v0.y );
					at = at > 0 ? at : -at;
					bt = bt > 0 ? bt : -bt;
					ct = ct > 0 ? ct : -ct;
					dt = dt > 0 ? dt : -dt;
					var longest_xy:Number =  at > bt ? at : bt;
					longest_xy =  ct > longest_xy ? ct : longest_xy;
					longest_xy =  dt > longest_xy ? dt : longest_xy;
					
					tex0 = _texture.getBitmapData(0);
					tw = tex0.width;
										
					//var pixel_area:Number = (v2.y - v0.y) * Math.abs(longest);
					var pixel_area:Number = longest_xy*longest_xy;
					var mip_ratio:Number = (tw*tw)  / (pixel_area / longest_uv);
					var tex_index:int = Math.log(mip_ratio) / Math.log(4);

					tex0 = _texture.getBitmapData(tex_index);
					tw = tex0.width;
					th = tex0.height;
					
					// choose perspective correct mapping
					if(v0.w < _texture_pc_distance || v1.w < _texture_pc_distance || v2.w < _texture_pc_distance)
					{
						pc = true;
					}
					else
					{
						pc = false;
					}
				}

				// calculate longest span
				var longest:Number = (v1.y - v0.y) / (v2.y - v0.y) * (v2.x - v0.x) + (v0.x - v1.x);
				var ystart:int, yend:int;
				var	subPix:Number;
				var	overHeight:Number;
				
				// sub pixel accuracy
				subPix = v0.iy - v0.y;
				
				if(longest > 0)
				{
					// ---------------------------------------------------------------
					// edge le - v0 to v1
					
					// edge deltas
					overHeight = 1.0 / (v1.y - v0.y);
					
					if(tex0)
					{
						if(pc)
						{
							ledu = ((v1.u*tw*v1.z) - (v0.u*tw*v0.z)) * overHeight;
							ledv = ((v1.v*th*v1.z) - (v0.v*th*v0.z)) * overHeight;
						
							leu  = (v0.u*tw*v0.z)+ ledu * subPix;
							lev  = (v0.v*th*v0.z)+ ledv * subPix;
						}
						else
						{
							ledu = ((v1.u*tw) - (v0.u*tw)) * overHeight;
							ledv = ((v1.v*th) - (v0.v*th)) * overHeight;
						
							leu  = (v0.u*tw)+ ledu * subPix;
							lev  = (v0.v*th)+ ledv * subPix;
						}
					}
										
					ledx = (v1.x - v0.x) * overHeight;
					ledz = (v1.z - v0.z) * overHeight;
					
					ledr = (v1.r - v0.r) * overHeight;
					ledg = (v1.g - v0.g) * overHeight;
					ledb = (v1.b - v0.b) * overHeight;
				
					// screen pixel adjustments
					lex  = v0.x + ledx * subPix;
					lez  = v0.z + ledz * subPix;
					
					ler  = v0.r + ledr * subPix;
					leg  = v0.g + ledg * subPix;
					leb  = v0.b + ledb * subPix;
					
					// ---------------------------------------------------------------
					// edge re - v0 to v2

					overHeight = 1.0 / (v2.y - v0.y);
					
					if(tex0)
					{
						if(pc)
						{
							redu = ((v2.u*tw*v2.z) - (v0.u*tw*v0.z)) * overHeight;
							redv = ((v2.v*th*v2.z) - (v0.v*th*v0.z)) * overHeight;
						
							reu  = (v0.u*tw*v0.z)+ redu * subPix;
							rev  = (v0.v*th*v0.z)+ redv * subPix;
						}
						else
						{
							redu = ((v2.u*tw) - (v0.u*tw)) * overHeight;
							redv = ((v2.v*th) - (v0.v*th)) * overHeight;
						
							reu  = (v0.u*tw)+ redu * subPix;
							rev  = (v0.v*th)+ redv * subPix;
						}
					}
					
					redx = (v2.x - v0.x) * overHeight;
					redz = (v2.z - v0.z) * overHeight;
					
					redr = (v2.r - v0.r) * overHeight;
					redg = (v2.g - v0.g) * overHeight;
					redb = (v2.b - v0.b) * overHeight;
				
					// screen pixel adjustments
					rex  = v0.x + redx * subPix;
					rez  = v0.z + redz * subPix;
					
					rer  = v0.r + redr * subPix;
					reg  = v0.g + redg * subPix;
					reb  = v0.b + redb * subPix;
				}
				else
				{
					// ---------------------------------------------------------------
					// edge le - v0 to v2
					//calcEdgeDeltas(le, v0, v2, tex0, tex1, pc);
					
					overHeight = 1.0 / (v2.y - v0.y);
					
					if(tex0)
					{
						if(pc)
						{
							ledu = (v2.u*v2.z - v0.u*v0.z) * tw * overHeight;
							ledv = (v2.v*v2.z - v0.v*v0.z) * th * overHeight;
						
							leu  = (v0.u*tw*v0.z)+ ledu * subPix;
							lev  = (v0.v*th*v0.z)+ ledv * subPix;
						}
						else
						{
							ledu = (v2.u - v0.u) * tw * overHeight;
							ledv = (v2.v - v0.v) * th * overHeight;
						
							leu  = v0.u*tw + ledu * subPix;
							lev  = v0.v*th + ledv * subPix;
						}
					}

					ledx = (v2.x - v0.x) * overHeight;
					ledz = (v2.z - v0.z) * overHeight;
					
					ledr = (v2.r - v0.r) * overHeight;
					ledg = (v2.g - v0.g) * overHeight;
					ledb = (v2.b - v0.b) * overHeight;
				
					// screen pixel adjustments

					lex  = v0.x + ledx * subPix;
					lez  = v0.z + ledz * subPix;
					
					ler  = v0.r + ledr * subPix;
					leg  = v0.g + ledg * subPix;
					leb  = v0.b + ledb * subPix;
					
					// ---------------------------------------------------------------
					// edge re - v0 to v1
					//calcEdgeDeltas(re, v0, v1, tex0, tex1, pc);
					
					overHeight = 1.0 / (v1.y - v0.y);
					
					if(tex0)
					{
						if(pc)
						{
							redu = (v1.u*v1.z - v0.u*v0.z) * tw  * overHeight;
							redv = (v1.v*v1.z - v0.v*v0.z) * th  * overHeight;
						
							reu  = (v0.u*tw*v0.z)+ redu * subPix;
							rev  = (v0.v*th*v0.z)+ redv * subPix;
						}
						else
						{
							redu = (v1.u - v0.u) * tw  * overHeight;
							redv = (v1.v - v0.v) * th  * overHeight;
						
							reu  = (v0.u*tw)+ redu * subPix;
							rev  = (v0.v*th)+ redv * subPix;
						}
					}
										
					redx = (v1.x - v0.x) * overHeight;
					redz = (v1.z - v0.z) * overHeight;
					
					redr = (v1.r - v0.r) * overHeight;
					redg = (v1.g - v0.g) * overHeight;
					redb = (v1.b - v0.b) * overHeight;
				
					// screen pixel adjustments
					rex  = v0.x + redx * subPix;
					rez  = v0.z + redz * subPix;
					
					rer  = v0.r + redr * subPix;
					reg  = v0.g + redg * subPix;
					reb  = v0.b + redb * subPix;
				}
				
				ystart = v0.iy;
				yend = v1.iy;
				
				for(var j:int=0;j<2;j++)
				{
					// get a material
					var mat:Mat = _buffer_mat_array[mat_count++];
					mat.pc = pc;
					mat.p = type;
					mat.t = tex0;
					
					// rx edge
					mat.rdxdy = redx;
					mat.rx0 = rex - (ystart * redx);
	
					// rr edge
					mat.rdrdy = redr;
					mat.rr0 = rer - (ystart * redr);
					
					// rg edge
					mat.rdgdy = redg;
					mat.rg0 = reg - (ystart * redg);
					
					// rb edge
					mat.rdbdy = redb;
					mat.rb0 = reb - (ystart * redb);
					
					// ru edge
					mat.rdudy = redu;
					mat.ru0 = reu - (ystart * redu);
					
					// rv edge
					mat.rdvdy = redv;
					mat.rv0 = rev - (ystart * redv);
										
					// lx edge
					mat.ldxdy = ledx;
					mat.lx0 = lex - (ystart * ledx);
									
					// lr edge
					mat.ldrdy = ledr;
					mat.lr0 = ler - (ystart * ledr);
					
					// lg edge
					mat.ldgdy = ledg;
					mat.lg0 = leg - (ystart * ledg);
					
					// lb edge
					mat.ldbdy = ledb;
					mat.lb0 = leb - (ystart * ledb);

					// lu edge
					mat.ldudy = ledu;
					mat.lu0 = leu - (ystart * ledu);
					
					// lv edge
					mat.ldvdy = ledv;
					mat.lv0 = lev - (ystart * ledv);
					
					for(;(ystart < yend);ystart++)
					{
						
						var	lx1:int = int(lex)+1;//Math.ceil(lex);
						var	rx1:int = int(rex)+1;//Math.ceil(rex);
						
						var overWidth:Number = 1.0 / (rex - lex);
						var dz:Number  = (rez - lez) * overWidth;
						
						var subTex:Number = lx1 - lex;
						var z:Number  = (lez + dz * subTex);
						
						if((rx1 - lx1) > 0)					
						{
							// set the segment
							_buffer_seg.x0 = lx1;
							_buffer_seg.x1 = rx1;
							
							_buffer_seg.m = mat;
						
							_buffer_seg.dzdx = dz;
							_buffer_seg.z0 = z - (lex * dz);
							
							// --------------------------------------------------------------------
							// insert into buffer
							var s:Seg = _buffer_seg;		
							var l:Scanline = _buffer_line_array[ystart];

							if(!l) continue;			
								
							var c:Seg = l.first;
							
							var c0:Seg;
							var s0:Seg;
							var ret:Boolean = false;
										
							// get line's segment count
							var len:int = l.n;
							// loop all current segments
							for(var i:int = 0;i<len;)
							{
								//CASE 1 --------------------------------------------------------------------
								// ssss
								//     cccc
								if(s.x1 <= c.x0)
								{
									s0 = _buffer_seg_array[seg_count++];
									
									if (c.prev)
									{
										c.prev.next = s0;
									}
									else
									{
										l.first = s0;
									}
									len++;
									s0.prev = c.prev;
									s0.next = c;
									s0.x0 = s.x0;
									s0.x1 = s.x1;
									s0.z0 = s.z0;
									s0.dzdx = s.dzdx;
									s0.m = s.m;
									c.prev = s0;
									
									ret = true;
									break;
								}
								//CASE 2 --------------------------------------------------------------------
								//     ssss
								// cccc
								else if (s.x0 >= c.x1)
								{
									c0 = c;
									c = c.next;
									i++;
									continue;
								}
								// SUB CASE --------------------------------------------------------------------
								else if (s.x0 < c.x0)
								{
									//CASE 3 --------------------------------------------------------------------
									if((s.x1 > c.x0) && (s.x1 < c.x1))
									{
										var x:Number = ((s.dzdx == c.dzdx)? -1 : (s.z0 - c.z0) / (c.dzdx - s.dzdx));
										
										if ((x > c.x0) && (x < s.x1))
										{
											
											if ((c.z0 - 0x1000*c.dzdx) < (s.z0 - 0x1000*s.dzdx))
											{
												s0 = _buffer_seg_array[seg_count++];
												if (c.prev)
												{
													c.prev.next = s0;
												}
												else
												{
													l.first = s0;
												}
												len++;
												s0.prev = c.prev;
												s0.next = c;
												s0.x0 = s.x0;
												s0.x1 = int(x)+1;//Math.ceil(x);
												s0.z0 = s.z0;
												s0.dzdx = s.dzdx;
												s0.m = s.m
												c.prev = s0;
												c.x0 = int(x)+1;//Math.ceil(x);
												//return;
												ret = true;
												break;
											}
											else 
											{
												s0 = _buffer_seg_array[seg_count++];
												var s1:Seg = _buffer_seg_array[seg_count++];
												var s2:Seg = _buffer_seg_array[seg_count++];
												
												if (c.prev)
												{
													c.prev.next = s0;
												}
												else
												{
													l.first = s0;
												}
												len+= 3;
												s0.prev = c.prev;
												s0.next = s1;
												s0.x0 = s.x0;
												s0.x1 = c.x0;
												s0.z0 = s.z0;
												s0.dzdx = s.dzdx;
												s0.m = s.m
												s1.prev = s0;
												s1.next = s2;
												s1.x0 = s0.x1;
												s1.x1 = int(x)+1;//Math.ceil(x);
												s1.z0 = c.z0;
												s1.dzdx = c.dzdx;
												s1.m = c.m
												s2.prev = s1;
												s2.next = c;
												s2.x0 = int(x)+1;//Math.ceil(x);
												s2.x1 = s.x1;
												s2.z0 = s.z0;
												s2.dzdx = s.dzdx;
												s2.m = s.m
												c.x0 = s2.x1;
												c.prev = s2;
												//return;
												ret = true;
												break;
											}
										}
										else 
										{
											s0 = _buffer_seg_array[seg_count++];
											if (c.prev)
											{
												c.prev.next = s0;
											}
											else
											{
												l.first = s0;
											}
											len++;
											s0.prev = c.prev;
											s0.next = c;
											c.prev = s0;
											s0.x0 = s.x0;
											var mx:Number = (c.x0 + s.x1)/2;
											
											if ((c.z0 + mx*c.dzdx) < (s.z0 + mx*s.dzdx))
											{
												s0.x1 = c.x0 = s.x1;
											}
											else
											{
												s0.x1 =c.x0;
											}
											s0.z0 = s.z0;
											s0.dzdx = s.dzdx;
											s0.m = s.m;
											//return;
											ret = true;
											break;
										}
									}// end if case 3
									//CASE 6 --------------------------------------------------------------------
									
									else if(s.x1 > c.x1)
									{
										x = ((s.dzdx == c.dzdx)? -1 : (s.z0 - c.z0) / (c.dzdx - s.dzdx));
										
										if ((x > c.x0) && (x < c.x1))
										{
											s0 = _buffer_seg_array[seg_count++];
											if (c.prev)
											{
												c.prev.next = s0;
											}
											else
											{
												l.first = s0;
											}
											len++;
											s0.prev = c.prev;
											s0.next = c;
											s0.x0 = s.x0;
											
											if ((c.z0 - 0x1000*c.dzdx) < (s.z0 - 0x1000*s.dzdx))
											{
												c.x0 = s0.x1 = int(x)+1;//Math.ceil(x);
												s.x0 = c.x1;
											}
											else 
											{
												s0.x1 = c.x0;
												s.x0 = c.x1 = int(x)+1;//Math.ceil(x);
											}
											s0.z0 = s.z0;
											s0.dzdx = s.dzdx;
											s0.m = s.m
											c.prev = s0;
											c0 = c;
											c = c.next;
											i += 2;
											continue;
										}
										else 
										{
											mx = (c.x0 + c.x1)/2;
											
											if ((c.z0 + mx*c.dzdx) < (s.z0 + mx*s.dzdx))
											{
												if (c.prev)
												{
													c.prev.next = c.next;
													c0 = c.prev;
													if(c.next)
													{
														c.next.prev = c.prev
													}
												}
												else 
												{
													l.first = c.next;
													if(c.next)
													{
														c.next.prev = null;
													}
												}
												len--;
												c = c.next;
												continue;
											}
											else 
											{
												s0 = _buffer_seg_array[seg_count++];
												if (c.prev)
												{
													c.prev.next = s0;
												}
												else
												{
													l.first = s0;
												}
												len++;
												s0.prev = c.prev;
												s0.next = c;
												s0.x0 = s.x0;
												s0.x1 = c.x0;
												s0.z0 = s.z0;
												s0.dzdx = s.dzdx;
												s0.m = s.m
												s.x0 = c.x1;
												c.prev = s0;
												c0 = c;
												c = c.next;
												i += 2;
												continue;
											}
										}
									}// end if case 6
									//CASE 8b --------------------------------------------------------------------
									
									else if(s.x1 == c.x1)
									{
										x = ((s.dzdx == c.dzdx)? -1 : (s.z0 - c.z0) / (c.dzdx - s.dzdx));
										
										if ((x > c.x0) && (x < c.x1))
										{
											
											if ((c.z0 - 0x1000*c.dzdx) < (s.z0 - 0x1000*s.dzdx))
											{
												s0 = _buffer_seg_array[seg_count++];
												if (c.prev)
												{
													c.prev.next = s0;
												}
												else
												{
													l.first = s0;
												}
												len++;
												s0.prev = c.prev;
												s0.next = c;
												s0.x0 = s.x0;
												s0.x1 = int(x)+1;//Math.ceil(x);
												s0.z0 = s.z0;
												s0.dzdx = s.dzdx;
												s0.m = s.m
												c.prev = s0;
												c.x0 = int(x)+1;//Math.ceil(x);
												//return;
												ret = true;
												break;
											}
											else 
											{
												s0 = _buffer_seg_array[seg_count++];
												s1 = _buffer_seg_array[seg_count++];
												len+= 2;
												
												if (c.prev)
												{
													c.prev.next = s0;
												}
												else
												{
													l.first = s0;
												}
												s0.prev = c.prev;
												s0.next = c;
												s0.x0 = s.x0;
												s0.x1 = c.x0;
												s0.z0 = s.z0;
												s0.dzdx = s.dzdx;
												s0.m = s.m
												s1.prev = c;
												s1.next = c.next;
												if (s1.next)
												{
													s1.next.prev = s1;
												}
												s1.x0 = int(x)+1;//Math.ceil(x);
												s1.x1 = s.x1;
												s1.z0 = s.z0;
												s1.dzdx = s.dzdx;
												s1.m = s.m;
												c.x1 = int(x)+1;//Math.ceil(x);
												c.prev = s0;
												c.next = s1;
												//return;
												ret = true;
												break;
											}
										}
										else 
										{
											mx = (c.x0 + c.x1)/2;
											
											if ((c.z0 + mx*c.dzdx) < (s.z0 + mx*s.dzdx))
											{
												c.x0 = s.x0;
												c.z0 = s.z0;
												c.dzdx = s.dzdx;
												c.m = s.m;
												//return;
												ret = true;
												break;
											}
											else 
											{
												s0 = _buffer_seg_array[seg_count++];
												if (c.prev)
												{
													c.prev.next = s0;
												}
												else
												{
													l.first = s0;
												}
												len++;
												s0.prev = c.prev;
												s0.next = c;
												s0.x0 = s.x0;
												s0.x1 = c.x0;
												s0.z0 = s.z0;
												s0.dzdx = s.dzdx;
												s0.m = s.m
												c.prev = s0;
												//return;
												ret = true;
												break;
											}
										}
									}// end if case 8b
								}// end sub case
								// SUB CASE --------------------------------------------------------------------
								else if (s.x0 > c.x0)
								{
				
									//CASE 4 --------------------------------------------------------------------
									
									if((s.x0 < c.x1) && (s.x1 > c.x1))
									{
										x = ((s.dzdx == c.dzdx)? -1 : (s.z0 - c.z0) / (c.dzdx - s.dzdx));
										
										if ((x > s.x0) && (x < c.x1))
										{
											
											if ((c.z0 - 0x1000*c.dzdx) < (s.z0 - 0x1000*s.dzdx))
											{
												s0 = _buffer_seg_array[seg_count++];
												s1 = _buffer_seg_array[seg_count++];
												len += 2;
												s0.prev = c;
												s0.next = s1;
												s0.x0 = s.x0;
												s0.x1 = int(x)+1;//Math.ceil(x);
												s0.z0 = s.z0;
												s0.dzdx = s.dzdx;
												s0.m = s.m
												s1.prev = s0;
												s1.next = c.next;
												if (s1.next)
												{
													s1.next.prev = s1;
												}
												s1.x0 = int(x)+1;//Math.ceil(x);
												s1.x1 = c.x1;
												s1.z0 = c.z0;
												s1.dzdx =c.dzdx;
												s1.m =c.m
												s.x0 = c.x1;
												c.next = s0;
												c.x1 = s0.x0;
												c0 = s1;
												c = s1.next;
												i += 3;
												continue;
											}
											else 
											{
												s.x0 = c.x1 = int(x)+1;//Math.ceil(x);
												c0 = c;
												c = c.next;
												i++;
												continue;
											}
										}
										else 
										{
											mx = (s.x0 + c.x1)/2;
											
											if ((c.z0 + mx*c.dzdx) < (s.z0 + mx*s.dzdx))
											{
												c.x1 = s.x0;
											}
											else 
											{
												s.x0 = c.x1;
											}
											c0 = c;
											c =c.next;
											i++;
											continue;
										}
									}// end if case 4
									//CASE 5 --------------------------------------------------------------------
									//else if ((S.x0 > C.x0) && (S.x1 < C.x1)){
									else if(s.x1 < c.x1)
									{
										x = ((s.dzdx == c.dzdx)? -1 : (s.z0 - c.z0) / (c.dzdx - s.dzdx));
										if ((x > s.x0) && (x < s.x1))
										{
											//if ((C.z0 - 0x1000*C.dzdx) < (S.z0 - 0x1000*S.dzdx)){
											s0 = _buffer_seg_array[seg_count++];
											s1 = _buffer_seg_array[seg_count++];
											len += 2;
											s0.prev = c;
											s0.next = s1;
											s1.x1 = c.x1;
											if ((c.z0 - 0x1000*c.dzdx) < (s.z0 - 0x1000*s.dzdx))
											{
												c.x1 = s0.x0 = s.x0;
												s1.x0 = s0.x1 = int(x)+1;//Math.ceil(x);
											}
											else 
											{
												c.x1 = s0.x0 = int(x)+1;//Math.ceil(x);
												s1.x0 = s0.x1 = s.x1;
											}
											s0.z0 = s.z0;
											s0.dzdx = s.dzdx;
											s0.m = s.m
											s1.prev = s0;
											s1.next = c.next;
											if (s1.next) 
											{
												s1.next.prev = s1;
											}
											s1.z0 = c.z0;
											s1.dzdx =c.dzdx;
											s1.m =c.m
											c.next = s0;
											//return;
											ret = true;
											break;
										}
										else 
										{
											mx = (s.x0 + s.x1)/2;
											//if ((C.z0 + S.x0*C.dzdx) < (S.z0 + S.x0*S.dzdx)){
											if ((c.z0 + mx*c.dzdx) < (s.z0 + mx*s.dzdx))
											{
												s0 = _buffer_seg_array[seg_count++];
												s1 = _buffer_seg_array[seg_count++];
												len += 2;
												s0.prev = c;
												s0.next = s1;
												s0.x0 = s.x0;
												s0.x1 = s.x1;
												s0.z0 = s.z0;
												s0.dzdx = s.dzdx;
												s0.m = s.m
												s1.prev = s0;
												s1.next = c.next;
												if (s1.next) 
												{
													s1.next.prev = s1;
												}
												s1.x0 = s0.x1;
												s1.x1 = c.x1;
												s1.z0 = c.z0;
												s1.dzdx = c.dzdx;
												s1.m = c.m
												c.next = s0;
												c.x1 = s0.x0;
												//return;
												ret = true;
												break;
											}
											//return;
											ret = true;
											break;
										}
									}// end if case 5
									//CASE 8a --------------------------------------------------------------------
									//else if ((S.x0 > C.x0) && (S.x1 == C.x1)){
									else if (s.x1 == c.x1)
									{
										x = ((s.dzdx == c.dzdx)? -1 : (s.z0 - c.z0) / (c.dzdx - s.dzdx));
										if ((x > s.x0) && (x < s.x1))
										{
											//if ((C.z0 - 0x1000*C.dzdx) < (S.z0 - 0x1000*S.dzdx)){
											if ((c.z0 - 0x1000*c.dzdx) < (s.z0 - 0x1000*s.dzdx))
											{
												s0 = _buffer_seg_array[seg_count++];
												s1 = _buffer_seg_array[seg_count++];
												len+= 2;
												s0.prev = c;
												s0.next = s1;
												s0.x0 = s.x0;
												s0.x1 = int(x)+1;//Math.ceil(x);
												s0.z0 = s.z0;
												s0.dzdx = s.dzdx;
												s0.m = s.m
												s1.prev = s0;
												s1.next = c.next;
												if (s1.next) 
												{
													s1.next.prev = s1;
												}
												s1.x0 = int(x)+1;//Math.ceil(x);
												s1.x1 = c.x1;
												s1.z0 = c.z0;
												s1.dzdx = c.dzdx;
												s1.m = c.m
												c.next = s0;
												c.x1 = s0.x0;
												//return;
												ret = true;
												break;
											}
											else 
											{
												s0 = _buffer_seg_array[seg_count++];
												len++;
												s0.prev = c;
												s0.next = c.next;
												if (s0.next) 
												{
													s0.next.prev = s0;
												}
												s0.x0 = int(x)+1;//Math.ceil(x);
												s0.x1 = s.x1;
												s0.z0 = s.z0;
												s0.dzdx = s.dzdx;
												s0.m = s.m
												c.next = s0;
												c.x1 = int(x)+1;//Math.ceil(x);
												//return;
												ret = true;
												break;
											}
										}
										else
										{
											mx = (s.x0 + s.x1)/2;
											//if ((C.z0 + S.x0*C.dzdx) < (S.z0 + S.x0*S.dzdx)){
											if ((c.z0 + mx*c.dzdx) < (s.z0 + mx*s.dzdx))
											{
												s0 = _buffer_seg_array[seg_count++];
												len++;
												s0.prev = c;
												s0.next = c.next;
												if (s0.next) 
												{
													s0.next.prev = s0;
												}
												s0.x0 = s.x0;
												s0.x1 = s.x1;
												s0.z0 = s.z0;
												s0.dzdx = s.dzdx;
												s0.m = s.m
												c.next = s0;
												c.x1 = s0.x0;
												//return;
												ret = true;
												break;
											}
											//return;
											ret = true;
											break;
										}
									}// end if case 8a
								}// end sub case
								// SUB CASE --------------------------------------------------------------------
								else if (s.x0 == c.x0)
								{
				
									//CASE 7a --------------------------------------------------------------------
									//else if ((S.x0 == C.x0) && (S.x1 < C.x1)){
									if(s.x1 < c.x1)
									{
										x = ((s.dzdx == c.dzdx)? -1 : (s.z0 - c.z0) / (c.dzdx - s.dzdx));
										if ((x > s.x0) && (x < s.x1))
										{
											//if ((C.z0 - 0x1000*C.dzdx) < (S.z0 - 0x1000*S.dzdx)){
											if ((c.z0 - 0x1000*c.dzdx) < (s.z0 - 0x1000*s.dzdx))
											{
												s0 = _buffer_seg_array[seg_count++];
												if (c.prev)
												{
													c.prev.next = s0;
												}
												else
												{
													l.first = s0;
												}
												len++;
												s0.prev = c.prev;
												s0.next = c;
												s0.x0 = s.x0;
												s0.x1 = int(x)+1;//Math.ceil(x);
												s0.z0 = s.z0;
												s0.dzdx = s.dzdx;
												s0.m = s.m
												c.prev = s0;
												c.x0 = int(x)+1;//Math.ceil(x);
												//return;
												ret = true;
												break;
											}
											else 
											{
												s0 = _buffer_seg_array[seg_count++];
												s1 = _buffer_seg_array[seg_count++];
												len+= 2;
												s0.prev = c;
												s0.next = s1;
												s0.x0 = int(x)+1;//Math.ceil(x);
												s0.x1 = s.x1;
												s0.z0 = s.z0;
												s0.dzdx = s.dzdx;
												s0.m = s.m
												s1.prev = s0;
												s1.next = c.next;
												if (s1.next) 
												{
													s1.next.prev = s1;
												}
												s1.x0 = s0.x1;
												s1.x1 = c.x1;
												s1.z0 = c.z0;
												s1.dzdx = c.dzdx;
												s1.m = c.m
												c.next = s0;
												c.x1 = int(x)+1;//Math.ceil(x);
												//return;
												ret = true;
												break;
											}
										}else {
											mx = (s.x0 + s.x1)/2;
											//if ((C.z0 + S.x0*C.dzdx) < (S.z0 + S.x0*S.dzdx)){
											if ((c.z0 + mx*c.dzdx) < (s.z0 + mx*s.dzdx))
											{
												s0 = _buffer_seg_array[seg_count++];
												if (c.prev)
												{
													c.prev.next = s0;
												}
												else
												{
													l.first = s0;
												}
												len++;
												s0.prev = c.prev;
												s0.next = c;
												s0.x0 = s.x0;
												s0.x1 = s.x1;
												s0.z0 = s.z0;
												s0.dzdx = s.dzdx;
												s0.m = s.m
												c.prev = s0;
												c.x0 = s0.x1;
												//return;
												ret = true;
												break;
											}
											//return;
											ret = true;
											break;
										}
									} // end if case 7a
									//CASE 7b --------------------------------------------------------------------
									//else if ((S.x0 == C.x0) && (S.x1 > C.x1)){
									else if(s.x1 > c.x1)
									{
										x = ((s.dzdx == c.dzdx)? -1 : (s.z0 - c.z0) / (c.dzdx - s.dzdx));
										if ((x > c.x0) && (x < c.x1))
										{
											//if ((C.z0 - 0x1000*C.dzdx) < (S.z0 - 0x1000*S.dzdx)){
											if ((c.z0 - 0x1000*c.dzdx) < (s.z0 - 0x1000*s.dzdx))
											{
												s0 = _buffer_seg_array[seg_count++];
												if (c.prev)
												{
													c.prev.next = s0;
												}
												else
												{
													l.first = s0;
												}
												len++;
												s0.prev = c.prev;
												s0.next = c;
												s0.x0 = s.x0;
												s0.x1 = int(x)+1;//Math.ceil(x);
												s0.z0 = s.z0;
												s0.dzdx = s.dzdx;
												s0.m = s.m
												c.x0 = int(x)+1;//Math.ceil(x);
												s.x0 = c.x1;
												c.prev = s0;
												c0 = c;
												c = c.next;
												i += 2;
												continue;
											}
											else 
											{
												s.x0 = c.x1 = int(x)+1;//Math.ceil(x);
												c0 = c;
												c = c.next;
												i++;
												continue;
											}
										}
										else 
										{
											mx = (c.x0 + c.x1)/2;
											//if ((C.z0 + C.x0*C.dzdx) M (S.z0 + C.x0*S.dzdx)){
											if ((c.z0 + mx*c.dzdx) < (s.z0 + mx*s.dzdx))
											{
												if (c.prev)
												{
													c.prev.next = c.next;
													c0 = c.prev;
													if(c.next)
													{
														c.next.prev =c.prev
													}
												}
												else 
												{
													l.first = c.next;
													if(c.next)
													{
														c.next.prev = null;
													} 
												}
												len--;
												c = c.next;
												continue;
											}
											else
											{
												s.x0 = c.x1;
												c0 = c;
												c = c.next;
												i++;
												continue;
											}
										}
									}// end if case 7b
									//CASE 9 --------------------------------------------------------------------
									//else if ((S.x0 == C.x0) && (S.x1 == C.x1)){
									else if (s.x1 == c.x1)
									{
										x = ((s.dzdx == c.dzdx)? -1 : (s.z0 - c.z0) / (c.dzdx - s.dzdx));
										
										if ((x > s.x0) && (x < s.x1))
										{
											//if ((C.z0 - 0x1000*C.dzdx) < (S.z0 - 0x1000*S.dzdx)){
											if ((c.z0 - 0x1000*c.dzdx) < (s.z0 - 0x1000*s.dzdx))
											{
												s0 = _buffer_seg_array[seg_count++];
												if (c.prev)
												{
													c.prev.next = s0;
												}
												else
												{
													l.first = s0;
												}
												len++;
												s0.prev = c.prev;
												s0.next = c;
												s0.x0 = s.x0;
												s0.x1 = int(x)+1;//Math.ceil(x);
												s0.z0 = s.z0;
												s0.dzdx = s.dzdx;
												s0.m = s.m
												c.prev = s0;
												c.x0 = int(x)+1;//Math.ceil(x);
												//return;
												ret = true;
												break;
											}
											else 
											{
												s0 = _buffer_seg_array[seg_count++];
												len++;
												s0.prev = c;
												s0.next = c.next;
												if (s0.next) s0.next.prev = s0;
												s0.x0 = int(x)+1;//Math.ceil(x);
												s0.x1 = s.x1;
												s0.z0 = s.z0;
												s0.dzdx = s.dzdx;
												s0.m = s.m
												c.next = s0;
												c.x1 = int(x)+1;//Math.ceil(x);
												//return;
												ret = true;
												break;
											}
										}
										else 
										{
											mx = (c.x0 + c.x1)/2;
											//if ((C.z0 + mx*C.dzdx) < (S.z0 + mx*S.dzdx)){
											if ((c.z0 + mx*c.dzdx) < (s.z0 + mx*s.dzdx))
											{
												c.z0 = s.z0;
												c.dzdx = s.dzdx;
												c.m = s.m
												//return;
												ret = true;
												break;
											}
											//return;
											ret = true;
											break;
										}
									}// end if case 9
								}// end sub case
							}
							
							if(!ret)
							{
								s0 = _buffer_seg_array[seg_count++];
								if (len>0)
								{
									c0.next = s0;
									s0.prev = c0;
								}
								else
								{
									l.first = s0;
									s0.prev = null;
								}
								s0.next = null;
								len++;
								s0.x0 = s.x0;
								s0.x1 = s.x1;
								s0.z0 = s.z0;
								s0.dzdx = s.dzdx;
								s0.m = s.m;
							}
							
							// important - set line's segment counter
							l.n = len;
						}

						lex += ledx;
						lez += ledz;
						
						rex += redx;
						rez += redz;
					}	
					
					if(j == 1)  break;
						
					// calculate starting points
					var height:Number = v1.iy - v0.iy;
					

					reu += redu * height;
					rev += redv * height;
					rer += redr * height;
					reg += redg * height;
					reb += redb * height;
					
					leu += ledu * height;
					lev += ledv * height;
					ler += ledr * height;
					leg += ledg * height;
					leb += ledb * height;
					
					// sub pixel accuracy
					subPix = v1.iy - v1.y;
					
					if(longest > 0)
					{
						// ---------------------------------------------------------------
						// edge le - v1 to v2
						// calcEdgeDeltas(le, v1, v2, tex0, tex1, pc);
						
						overHeight = 1.0 / (v2.y - v1.y);
					
						if(tex0)
						{
							if(pc)
							{
								ledu = ((v2.u*v2.z) - (v1.u*v1.z)) * tw * overHeight;
								ledv = ((v2.v*v2.z) - (v1.v*v1.z)) * th * overHeight;
							
								leu  = (v1.u*tw*v1.z)+ ledu * subPix;
								lev  = (v1.v*th*v1.z)+ ledv * subPix;
							}
							else
							{
								ledu = (v2.u - v1.u) * tw * overHeight;
								ledv = (v2.v - v1.v) * th * overHeight;
							
								leu  = (v1.u*tw)+ ledu * subPix;
								lev  = (v1.v*th)+ ledv * subPix;
							}
						}
					
						ledx = (v2.x - v1.x) * overHeight;
						ledz = (v2.z - v1.z) * overHeight;
						
						ledr = (v2.r - v1.r) * overHeight;
						ledg = (v2.g - v1.g) * overHeight;
						ledb = (v2.b - v1.b) * overHeight;
					
						// screen pixel adjustments
						lex  = v1.x + ledx * subPix;
						lez  = v1.z + ledz * subPix;
						
						ler  = v1.r + ledr * subPix;
						leg  = v1.g + ledg * subPix;
						leb  = v1.b + ledb * subPix;
					}
					else
					{	
						// ---------------------------------------------------------------
						// edge re - v1 to v2
						// calcEdgeDeltas(re, v1, v2, tex0, tex1, pc);
						
						overHeight = 1.0 / (v2.y - v1.y);
					
						if(tex0)
						{
							if(pc)
							{
								redu = (v2.u*v2.z - v1.u*v1.z) * tw * overHeight;
								redv = (v2.v*v2.z - v1.v*v1.z) * th * overHeight;
							
								reu  = (v1.u*tw*v1.z)+ redu * subPix;
								rev  = (v1.v*th*v1.z)+ redv * subPix;
							}
							else
							{
								redu = (v2.u - v1.u) * tw * overHeight;
								redv = (v2.v - v1.v) * th * overHeight;
							
								reu  = (v1.u*tw)+ redu * subPix;
								rev  = (v1.v*th)+ redv * subPix;
							}
						}
						
						redx = (v2.x - v1.x) * overHeight;
						redz = (v2.z - v1.z) * overHeight;
						
						redr = (v2.r - v1.r) * overHeight;
						redg = (v2.g - v1.g) * overHeight;
						redb = (v2.b - v1.b) * overHeight;
					
						// screen pixel adjustments
						rex  = v1.x + redx * subPix;
						rez  = v1.z + redz * subPix;
						
						rer  = v1.r + redr * subPix;
						reg  = v1.g + redg * subPix;
						reb  = v1.b + redb * subPix;
					}

					ystart = v1.iy;
					yend = v2.iy;
					
				}// end 2 half triangles
			}// end loop all triangles
			
			// set used materials
			_buffer.materialsUsed = mat_count;
			// set used segments
			_buffer.segmentsUsed = seg_count;
		}
		
		public function setMaterial(mat:Material):void
		{
			_material=mat;
			_texture = _material.texture1 as Texture;
		} 
		
		public function setPerspectiveCorrectDistance(distance:Number=400):void
		{
			_texture_pc_distance = distance;
		}
		
		public function setMipMapDistance(distance:Number=800):void
		{
			_texture_mip_distance = distance;
		}
		public function drawIndexedLineList(vertices :Vector.<Vertex4D>, vertexCount : int, indexList : Vector.<int>, indexCount : int):void
		{
		}
		public function setRenderTarget (target : BitmapData, buffer : BitmapData) : void
		{
			
		}
	}
}
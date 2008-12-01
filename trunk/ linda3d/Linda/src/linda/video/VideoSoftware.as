package linda.video
{
        import __AS3__.vec.Vector;
       
        import flash.display.*;
        import flash.geom.*;
       
        import linda.light.Light;
        import linda.material.ITexture;
        import linda.material.Material;
        import linda.math.*;
        import linda.mesh.MeshBuffer;
        import linda.video.pixel.*;

        public class VideoSoftware extends VideoNull implements IVideoDriver
        {
                protected var curRender : ITriangleRenderer;
                protected var renderers : Vector.<ITriangleRenderer>;
               
                protected var target : Bitmap;
                protected var rect:Rectangle;

                protected var targetVector:Vector.<uint>;
                protected var bufferVector:Vector.<Number>;
               
                protected var _clip_scale : Matrix4;

                private var texture : ITexture;
                private var material : Material;
               
                private var _lightDirs : Vector.<Vector3D>;
                private var _lightsPos : Vector.<Vector3D>;
               
               
                //matrix vars
                private var _view : Matrix4;
                private var _world : Matrix4;
                //ClipScale from NDC to DC Space
                private var _projection : Matrix4;
                private var _current : Matrix4 ;
                private var _view_project : Matrix4;
                private var _world_inv : Matrix4;
                private var _oppcam_pos : Vector3D;
                private var _cam_pos : Vector3D;
                private var _ndc_planes : Vector.<Vector3D>;

                private var _transformedVertexs : Vector.<Vertex4D>;
                private var _unclipped_vertices : Vector.<Vertex4D>;
                private var _clipped_vertices : Vector.<Vertex4D>;
                private var _clipped_indices : Vector.<int>;
                private var _clipped_vertices0 : Vector.<Vertex4D>;
                private var _clipped_vertices1 : Vector.<Vertex4D>;
                private var _clipped_vertices2 : Vector.<Vertex4D>;
                private var _clipped_vertices3 : Vector.<Vertex4D>;
                private var _clipped_vertices4 : Vector.<Vertex4D>;

                public function VideoSoftware (size : Dimension2D)
                {
                        super();
                        init(size);
                }
                private function init (size:Dimension2D) : void
                {
                        target = new Bitmap ();
                        renderTarget.addChild(target);
                       
                        _clip_scale = new Matrix4 ();

                        //render
                        renderers = new Vector.<ITriangleRenderer> (TRType.COUNT,true);
                        renderers [TRType.WIRE] = new TRWire ();
                        renderers [TRType.FLAT] = new TRFlat ();
                        renderers [TRType.GOURAUD] = new TRGouraud ();
                        renderers [TRType.TEXTURE_FLAT] = new TRTextureFlat ();
                        renderers [TRType.TEXTURE_GOURAUD] = new TRTextureGouraud ();
                        renderers [TRType.FLAT_ALPHA] = new TRFlatAlpha ();
                        renderers [TRType.GOURAUD_ALPHA] = new TRGouraudAlpha ();
                        renderers [TRType.TEXTURE_FLAT_ALPHA] = new TRTextureFlatAlpha ();
                        renderers [TRType.TEXTURE_GOURAUD_ALPHA] = new TRTextureGouraudAlpha ();

                        //预存一些点
                        _transformedVertexs = new Vector.<Vertex4D> ();
                        for (var i : int = 0; i < 2000; i+=1)
                        {
                                _transformedVertexs [i] = new Vertex4D ();
                        }
                        //matrix4
                        _current = new Matrix4 ();
                        _view = new Matrix4 ();
                        _projection = new Matrix4 ();
                        _view_project = new Matrix4 ();
                        _world_inv = new Matrix4 ();
                       
                       
                        //lighting
                        var count:int=getMaxLightAmount();
                        _lightDirs = new Vector.<Vector3D> (count,true);
                        _lightsPos = new Vector.<Vector3D> (count,true);
                        for (i = 0; i < count; i+=1)
                        {
                                _lightDirs[i]=new Vector3D();
                                _lightsPos[i]=new Vector3D();
                        }
                       
                        _oppcam_pos = new Vector3D ();
                        _cam_pos = new Vector3D ();
                       
                       
                        /*
                        generic plane clipping in homogenous coordinates
                        special case ndc frustum <-w,w>,<-w,w>,<-w,w>
                        can be rewritten with compares e.q near plane, a.z < -a.w and b.z < -b.w
                        */
                        _ndc_planes = new Vector.<Vector3D>(6,true);
                       
                        _ndc_planes[0]=new Vector3D (0.0, 0.0, -1.0, -1.0 ); // near
                        _ndc_planes[1]=new Vector3D (0.0, 0.0, 1.0, -1.0 ); // far
                        _ndc_planes[2]=new Vector3D (1.0, 0.0, 0.0, -1.0 ); // left
                        _ndc_planes[3]=new Vector3D (-1.0, 0.0, 0.0, -1.0); // right
                        _ndc_planes[4]=new Vector3D (0.0, 1.0, 0.0, -1.0 ); // bottom
                        _ndc_planes[5]=new Vector3D (0.0, -1.0, 0.0, -1.0); //top

                        // arrays for storing clipped vertices & indices
                        _clipped_indices = new Vector.<int>();
                       
                        _clipped_vertices   = new Vector.<Vertex4D> ();
                        _clipped_vertices0  = new Vector.<Vertex4D> ();
                        _unclipped_vertices = new Vector.<Vertex4D> ();
                        _clipped_vertices1  = new Vector.<Vertex4D> ();
                        _clipped_vertices2  = new Vector.<Vertex4D> ();
                        _clipped_vertices3  = new Vector.<Vertex4D> ();
                        _clipped_vertices4  = new Vector.<Vertex4D> ();

                        targetVector=new Vector.<uint>();
                        bufferVector=new Vector.<Number>();
                       
                        setVector(targetVector,bufferVector);

                        setScreenSize(size);
                }
                protected function reset():void
                {
                        //Todo 不知道有没有更好的方法了:)
                        targetVector.length=0;
                        bufferVector.length=0;
                        targetVector.length=int(screenSize.width)*int(screenSize.height);
                        bufferVector.length=targetVector.length;
                }
                private function getTRIndex () : int
                {
                        if(material.wireframe) return TRType.WIRE;

                        var gouraudShading : Boolean = material.gouraudShading;
                        var lighting:Boolean = material.lighting;
                       
                        if (material.transparenting)
                        {
                                        if (texture)
                                        {
                                                if(lighting)
                                                {
                                                        return TRType.TEXTURE_GOURAUD_ALPHA;
                                                }else
                                                {
                                                        return TRType.TEXTURE_FLAT_ALPHA;
                                                }
                                        } else
                                        {
                                                if (gouraudShading)
                                                {
                                                        return TRType.GOURAUD_ALPHA;
                                                } else
                                                {
                                                        return TRType.FLAT_ALPHA;
                                                }
                                        }
                        } else
                        {
                                        if (texture)
                                        {
                                                if(lighting)
                                                {
                                                        return TRType.TEXTURE_GOURAUD;
                                                }else
                                                {
                                                        return TRType.TEXTURE_FLAT;
                                                }
                                        } else
                                        {
                                                if (gouraudShading)
                                                {
                                                        return TRType.GOURAUD;
                                                } else
                                                {
                                                        return TRType.FLAT;
                                                }
                                        }
                        }
                }

                public function beginScene ():void
                {
                        primitivesDrawn = 0;
                        reset();
                }
                public function endScene():void
                {
                        target.bitmapData.lock();
                        target.bitmapData.setVector(rect,targetVector);
                        target.bitmapData.unlock();
                }
                public function setTransformViewProjection (mat : Matrix4) : void
                {
                        _view_project = mat;
                }
                public function setTransformProjection (mat : Matrix4) : void
                {
                        _projection = mat;
                }
                public function setCameraPosition (pos : Vector3D) : void
                {
                        if (pos)
                        {
                                _cam_pos.x = pos.x;
                                _cam_pos.y = pos.y;
                                _cam_pos.z = pos.z;
                        }      
                }
                public function setTransformWorld (mat : Matrix4) : void
                {
                        _world = mat;


                        _current.m00 = _view_project.m00;
                        _current.m01 = _view_project.m01;
                        _current.m02 = _view_project.m02;
                        _current.m03 = _view_project.m03;
                        _current.m10 = _view_project.m10;
                        _current.m11 = _view_project.m11;
                        _current.m12 = _view_project.m12;
                        _current.m13 = _view_project.m13;
                        _current.m20 = _view_project.m20;
                        _current.m21 = _view_project.m21;
                        _current.m22 = _view_project.m22;
                        _current.m23 = _view_project.m23;
                        _current.m30 = _view_project.m30;
                        _current.m31 = _view_project.m31;
                        _current.m32 = _view_project.m32;
                        _current.m33 = _view_project.m33;

                        var m00 : Number = _current.m00;
                        var m01 : Number = _current.m01;
                        var m02 : Number = _current.m02;
                        var m03 : Number = _current.m03;
                        var m10 : Number = _current.m10;
                        var m11 : Number = _current.m11;
                        var m12 : Number = _current.m12;
                        var m13 : Number = _current.m13;
                        var m20 : Number = _current.m20;
                        var m21 : Number = _current.m21;
                        var m22 : Number = _current.m22;
                        var m23 : Number = _current.m23;
                        var m30 : Number = _current.m30;
                        var m31 : Number = _current.m31;
                        var m32 : Number = _current.m32;
                        var m33 : Number = _current.m33;
                       
                        _current.m00 = m00 * _world.m00 + m10 * _world.m01 + m20 * _world.m02 ;
                        _current.m01 = m01 * _world.m00 + m11 * _world.m01 + m21 * _world.m02 ;
                        _current.m02 = m02 * _world.m00 + m12 * _world.m01 + m22 * _world.m02 ;
                        _current.m03 = m03 * _world.m00 + m13 * _world.m01 + m23 * _world.m02 ;
                        _current.m10 = m00 * _world.m10 + m10 * _world.m11 + m20 * _world.m12 ;
                        _current.m11 = m01 * _world.m10 + m11 * _world.m11 + m21 * _world.m12 ;
                        _current.m12 = m02 * _world.m10 + m12 * _world.m11 + m22 * _world.m12 ;
                        _current.m13 = m03 * _world.m10 + m13 * _world.m11 + m23 * _world.m12 ;
                        _current.m20 = m00 * _world.m20 + m10 * _world.m21 + m20 * _world.m22 ;
                        _current.m21 = m01 * _world.m20 + m11 * _world.m21 + m21 * _world.m22 ;
                        _current.m22 = m02 * _world.m20 + m12 * _world.m21 + m22 * _world.m22 ;
                        _current.m23 = m03 * _world.m20 + m13 * _world.m21 + m23 * _world.m22 ;
                        _current.m30 = m00 * _world.m30 + m10 * _world.m31 + m20 * _world.m32 + m30 ;
                        _current.m31 = m01 * _world.m30 + m11 * _world.m31 + m21 * _world.m32 + m31 ;
                        _current.m32 = m02 * _world.m30 + m12 * _world.m31 + m22 * _world.m32 + m32 ;
                        _current.m33 = m03 * _world.m30 + m13 * _world.m31 + m23 * _world.m32 + m33 ;
                       
                        //_world.getInverse (_world_inv);
                        m00 = _world.m00;
                        m01 = _world.m01;
                        m02 = _world.m02;

                        m10 = _world.m10;
                        m11 = _world.m11;
                        m12 = _world.m12;

                        m20 = _world.m20;
                        m21 = _world.m21;
                        m22 = _world.m22;

                        m30 = _world.m30;
                        m31 = _world.m31;
                        m32 = _world.m32;
                       
                        var d : Number = (m00 * m11 - m01 * m10) * m22 - (m00 * m12 - m02 * m10) * m21 + (m01 * m12 - m02 * m11) * m20;
                        if (d == 0) d=0 else d = 1.0 / d ;
                        _world_inv.m00 = d * (m11 * m22 - m12 * m21);
                        _world_inv.m01 = d * (m21 * m02 - m22 * m01);
                        _world_inv.m02 = d * (m01 * m12 - m02 * m11);
                        _world_inv.m03 = 0;
                        _world_inv.m10 = d * (m12 * m20 - m10 * m22 );
                        _world_inv.m11 = d * (m22 * m00 - m20 * m02 );
                        _world_inv.m12 = d * (m02 * m10 - m00 * m12 );
                        _world_inv.m13 = 0;
                        _world_inv.m20 = d * (m10 * m21  - m11 * m20);
                        _world_inv.m21 = d * (m20 * m01  - m21 * m00);
                        _world_inv.m22 = d * (m00 * m11  - m01 * m10);
                        _world_inv.m23 = 0;
                        _world_inv.m30 = d * (m10 * (m22 * m31 - m21 * m32) + m11 * (m20 * m32 - m22 * m30) + m12 * (m21 * m30 - m20 * m31));
                        _world_inv.m31 = d * (m20 * (m02 * m31 - m01 * m32) + m21 * (m00 * m32 - m02 * m30) + m22 * (m01 * m30 - m00 * m31));
                        _world_inv.m32 = d * (m30 * (m02 * m11 - m01 * m12) + m31 * (m00 * m12 - m02 * m10) + m32 * (m01 * m10 - m00 * m11));
                        _world_inv.m33 = 1;
                       
                        //_world_inv.transformVector2(_cam_pos,_oppcam_pos);
                        var x : Number = _cam_pos.x;
                        var y : Number = _cam_pos.y;
                        var z : Number = _cam_pos.z;
                       
                        _oppcam_pos.x = (_world_inv.m00 * x + _world_inv.m10 * y + _world_inv.m20 * z + _world_inv.m30);
                        _oppcam_pos.y = (_world_inv.m01 * x + _world_inv.m11 * y + _world_inv.m21 * z + _world_inv.m31);
                        _oppcam_pos.z = (_world_inv.m02 * x + _world_inv.m12 * y + _world_inv.m22 * z + _world_inv.m32);
                }

                public function setTransformView (mat : Matrix4) : void
                {
                        _view = mat;
                        _view_project.copy (_projection);
                        _view_project.multiplyE (_view);
                }

                override public function setMaterial (mat : Material) : void
                {
                        material = mat;
                        texture = material.texture1;
                       
                        var index:int=getTRIndex();
                        curRender = renderers[index];
                        curRender.setMaterial(material);
                }

                public function setScreenSize (size : Dimension2D) : void
                {
                        if(!size)
            {
                size=new Dimension2D(300,300);
            }
           
                        screenSize = size;
                       
                        rect=screenSize.toRect();
                       
                        if(target.bitmapData)
                        {
                                target.bitmapData.fillRect(rect,0x0);
                        }else
                        {
                                target.bitmapData = new BitmapData (screenSize.width, screenSize.height, false, 0);
                        }
                       
                        _clip_scale.buildNDCToDCMatrix(screenSize,1);
                       
                        var len:int=int(screenSize.width)*int(screenSize.height);
                        targetVector.length=len;
                        bufferVector.length=len;
                       
                        setHeight(screenSize.height);
                }
                public override function setRenderTarget (target : Sprite) : void
                {
                        if ( ! target) return;
                        if (renderTarget) renderTarget.removeChild (target);
                        renderTarget = target;
                        renderTarget.addChild (target);
                }
                //for light
                private var l : Vector3D = new Vector3D ();
                private var n : Vector3D = new Vector3D ();
                private var v : Vector3D = new Vector3D ();
                public function drawIndexedTriangleList (vertices : Vector.<Vertex>, vertexCount : int, indexList : Vector.<int>, triangleCount : int) : void
                {
                        var v0 : Vertex;
                        var v1 : Vertex;
                        var v2 : Vertex;
                        var tv0 : Vertex4D;
                        var tv1 : Vertex4D;
                        var tv2 : Vertex4D;
                        var tCount : int;
                        var iCount : int;
                        var vCount : int;
                        var vCount2 : int;
                       
                        //clipping
                        var a : Vertex4D;
                        var b : Vertex4D;
                        var out : Vertex4D;
                        var inCount : int;
                        var outCount : int;
                        var dest : Vector.<Vertex4D>;
                        var plane : Vector3D;
                        var source : Vector.<Vertex4D>;
                        var adot : Number;
                        var bdot : Number;
                        var t : Number;

                        var len : int = triangleCount * 2;
                        var _transformLen : int = _transformedVertexs.length;
                        var i : int;
                        if (_transformLen < len)
                        {
                                for (i = _transformLen; i < len; i+=1)
                                {
                                        _transformedVertexs [i] = new Vertex4D ();
                                }
                        }

                        tCount = 0;
                        iCount = 0;
                        vCount = 0;
                       
                        //material tmp var
                        var lighting : Boolean = material.lighting;
                        var backfaceCulling : Boolean = material.backfaceCulling;
                        var hasTexture : Boolean = (texture!=null);
                        var gouraudShading : Boolean = material.gouraudShading;
                       
                        if(lighting)
                        {
                            var light : Light;
                            var dir : Vector3D;
                            var pos : Vector3D;
                            // transfrom lights into object's world space
                            len = getLightCount();
                            for (i = 0; i < len; i+=1)
                            {
                                    dir = _lightDirs [i];
                                    pos = _lightsPos [i];
                                    light = _lights [i];
                                    if ((light.type == Light.SPOT) || (light.type == Light.DIRECTIONAL))
                                    {
                                        var x:Number = light.direction.x;
                                        var y:Number = light.direction.y;
                                        var z:Number = light.direction.z;
                                        dir.x = x * _world_inv.m00 + y * _world_inv.m10 + z * _world_inv.m20;
                                        dir.y = x * _world_inv.m01 + y * _world_inv.m11 + z * _world_inv.m21;
                                        dir.z = x * _world_inv.m02 + y * _world_inv.m12 + z * _world_inv.m22;
                                        dir.normalize ();
                                    }
                                    if ((light.type == Light.SPOT) || (light.type == Light.POINT))
                                    {
                                            x = light.position.x;
                                            y = light.position.y;
                                            z = light.position.z;
                                            pos.x = _world_inv.m00 * x + _world_inv.m10 * y + _world_inv.m20 * z + _world_inv.m30;
                                            pos.y = _world_inv.m01 * x + _world_inv.m11 * y + _world_inv.m21 * z + _world_inv.m31;
                                            pos.z = _world_inv.m02 * x + _world_inv.m12 * y + _world_inv.m22 * z + _world_inv.m32;
                                    }
                            }
                        }
                       
                        var m00 : Number = _current.m00;
                        var m10 : Number = _current.m10;
                        var m20 : Number = _current.m20;
                        var m30 : Number = _current.m30;
                        var m01 : Number = _current.m01;
                        var m11 : Number = _current.m11;
                        var m21 : Number = _current.m21;
                        var m31 : Number = _current.m31;
                        var m02 : Number = _current.m02;
                        var m12 : Number = _current.m12;
                        var m22 : Number = _current.m22;
                        var m32 : Number = _current.m32;
                        var m03 : Number = _current.m03;
                        var m13 : Number = _current.m13;
                        var m23 : Number = _current.m23;
                        var m33 : Number = _current.m33;
                        var csm00 : Number = _clip_scale.m00;
                        var csm30 : Number = _clip_scale.m30;
                        var csm11 : Number = _clip_scale.m11;
                        var csm31 : Number = _clip_scale.m31;
                        var memi : Color = material.emissiveColor;
                        var mamb : Color = material.ambientColor;
                        var mdif : Color = material.diffuseColor;
                        //太阳光与自发光相加，因为在下面计算时这个值不会改变，放在这里统一计算，加快速度.
                        var globalR : int = ambientColor.r + memi.r;
                        var globalG : int = ambientColor.g + memi.g;
                        var globalB : int = ambientColor.b + memi.b;
                       
                        var ii:int;
                        for (ii = 0; ii < triangleCount; ii += 3)
                        {
                                v0 = vertices [int (indexList [ii])];
                                v1 = vertices [int (indexList [int (ii + 1)])];
                                v2 = vertices [int (indexList [int (ii + 2)])];
                               
                                if (backfaceCulling)
                                {
                                        if (((v1.y - v0.y) * (v2.z - v0.z) - (v1.z - v0.z) * (v2.y - v0.y)) * (_oppcam_pos.x - v0.x) +
                                            ((v1.z - v0.z) * (v2.x - v0.x) - (v1.x - v0.x) * (v2.z - v0.z)) * (_oppcam_pos.y - v0.y) +
                                            ((v1.x - v0.x) * (v2.y - v0.y) - (v1.y - v0.y) * (v2.x - v0.x)) * (_oppcam_pos.z - v0.z) <= 0)
                                        {
                                                continue;
                                        }
                                }
                                tv0 = _transformedVertexs [int (tCount ++)];
                                tv1 = _transformedVertexs [int (tCount ++)];
                                tv2 = _transformedVertexs [int (tCount ++)];
                               
                                //      - transform Model * World * Camera * Projection matrix ,then after clip and light * NDCSpace matrix
                                tv0.x = m00 * v0.x + m10 * v0.y + m20 * v0.z + m30;
                                tv0.y = m01 * v0.x + m11 * v0.y + m21 * v0.z + m31;
                                tv0.z = m02 * v0.x + m12 * v0.y + m22 * v0.z + m32;
                                tv0.w = m03 * v0.x + m13 * v0.y + m23 * v0.z + m33;
                               
                                tv1.x = m00 * v1.x + m10 * v1.y + m20 * v1.z + m30;
                                tv1.y = m01 * v1.x + m11 * v1.y + m21 * v1.z + m31;
                                tv1.z = m02 * v1.x + m12 * v1.y + m22 * v1.z + m32;
                                tv1.w = m03 * v1.x + m13 * v1.y + m23 * v1.z + m33;
                               
                                tv2.x = m00 * v2.x + m10 * v2.y + m20 * v2.z + m30;
                                tv2.y = m01 * v2.x + m11 * v2.y + m21 * v2.z + m31;
                                tv2.z = m02 * v2.x + m12 * v2.y + m22 * v2.z + m32;
                                tv2.w = m03 * v2.x + m13 * v2.y + m23 * v2.z + m33;
                               
                               
                               
                                var inside : Boolean = true;
                                var clipcount : int = 0;
                                for (var p : int = 0; p < 6; p+=1)
                                {
                                        plane = _ndc_planes [p];
                                        if (((tv0.x * plane.x) + (tv0.y * plane.y) + (tv0.z * plane.z) + (tv0.w * plane.w)) > 0.0)
                                        {
                                                if (((tv1.x * plane.x) + (tv1.y * plane.y) + (tv1.z * plane.z) + (tv1.w * plane.w)) > 0.0)
                                                {
                                                        if (((tv2.x * plane.x) + (tv2.y * plane.y) + (tv2.z * plane.z) + (tv2.w * plane.w)) > 0.0)
                                                        {
                                                                inside = false;
                                                                break;
                                                        }
                                                }
                                                clipcount += (1 << p);
                                        }
                                        else
                                        {
                                                if (((tv1.x * plane.x) + (tv1.y * plane.y) + (tv1.z * plane.z) + (tv1.w * plane.w)) < 0.0)
                                                {
                                                        if (((tv2.x * plane.x) + (tv2.y * plane.y) + (tv2.z * plane.z) + (tv2.w * plane.w)) < 0.0)
                                                        {
                                                                // triangle is not clipped agianst this plane - check other planes
                                                               
                                                        }
                                                        else
                                                        {
                                                                clipcount += (1 << p);
                                                        }
                                                }
                                                else
                                                {
                                                        clipcount += (1 << p);
                                                }
                                        }
                                }
                                if ( ! inside)
                                {
                                        tCount -= 3;
                                        continue;
                                }
                                //lighting
                                if (lighting)
                                {
                                        //初始化总体环境光照颜色
                                        var amb_r_sum0 : Number = 0;
                                        var amb_r_sum1 : Number = 0;
                                        var amb_r_sum2 : Number = 0;
                                        var amb_g_sum0 : Number = 0;
                                        var amb_g_sum1 : Number = 0;
                                        var amb_g_sum2 : Number = 0;
                                        var amb_b_sum0 : Number = 0;
                                        var amb_b_sum1 : Number = 0;
                                        var amb_b_sum2 : Number = 0;
                                        //初始化总体反射光照颜色
                                        var dif_r_sum0 : Number = 0;
                                        var dif_g_sum0 : Number = 0;
                                        var dif_b_sum0 : Number = 0;
                                        var dif_r_sum1 : Number = 0;
                                        var dif_g_sum1 : Number = 0;
                                        var dif_b_sum1 : Number = 0;
                                        var dif_r_sum2 : Number = 0;
                                        var dif_g_sum2 : Number = 0;
                                        var dif_b_sum2 : Number = 0;
                                        //高光部分
                                        //var spe_r_sum0 : Number = 0;var spe_g_sum0 : Number = 0;var spe_b_sum0 : Number = 0;
                                        //var spe_r_sum1 : Number = 0;var spe_g_sum1 : Number = 0;var spe_b_sum1 : Number = 0;
                                        //var spe_r_sum2 : Number = 0;var spe_g_sum2 : Number = 0;var spe_b_sum2 : Number = 0;
                                        var diffuse : Color;
                                        var ambient : Color;
                                        var specular : Color;
                                        var kc : Number;
                                        var kl : Number;
                                        var kq : Number;
                                        var dist : Number;
                                        var dist2 : Number;
                                        var nlen : Number;
                                        var atten : Number;
                                        var dpsl : Number;
                                        var dp : Number;
                                        var radius : Number;
                                        var pf : int;
                                        var k : Number;
                                        var lightLen : int = this.getLightCount();
                                        if (lightLen > 0)
                                        {
                                                if ( ! gouraudShading) //flat Light
                                                {
                                                       
                                                        for (var j : int = 0; j < lightLen; j+=1)
                                                        {
                                                                light = _lights [j];
                                                                pos = _lightsPos [j];
                                                                dir = _lightDirs [j];
                                                                diffuse = light.diffuseColor;
                                                                ambient = light.ambientColor;
                                                                //specular = light.specularColor;
                                                                kc = light.kc;
                                                                kl = light.kl;

                                                                kq = light.kq;
                                                                pf = light.powerFactor;
                                                               
                                                                //l=v1.subtractE(v0);
                                                                l.x = v1.x - v0.x;
                                                                l.y = v1.y - v0.y;
                                                                l.z = v1.z - v0.z;
                                                                //v=v2.subtractE(v0);
                                                                v.x = v2.x - v0.x;
                                                                v.y = v2.y - v0.y;
                                                                v.z = v2.z - v0.z;
                                                                //三角形法线
                                                                //n=l.cross(v);
                                                                n.x = l.y * v.z - l.z * v.y;
                                                                n.y = l.z * v.x - l.x * v.z;
                                                                n.z = l.x * v.y - l.y * v.x;
                                                                //法线长度
                                                                nlen = Math.sqrt (n.x * n.x + n.y * n.y + n.z * n.z);
                                                               
                                                                if (light.type == 0) //DIRECTIONAL
                                                               
                                                                {
                                                                        dp = (n.x * dir.x + n.y * dir.y + n.z * dir.z) / nlen;
                                                                        if (dp > 0)
                                                                        {
                                                                                amb_r_sum0 += ambient.r / nlen;
                                                                                amb_g_sum0 += ambient.g / nlen;
                                                                                amb_b_sum0 += ambient.b / nlen;
                                                                                dif_r_sum0 += (diffuse.r * dp);
                                                                                dif_g_sum0 += (diffuse.g * dp);
                                                                                dif_b_sum0 += (diffuse.b * dp);
                                                                        }
                                                                } else if (light.type == 1) //POINT
                                                                {
                                                                        l.x = pos.x - v0.x;
                                                                        l.y = pos.y - v0.y;
                                                                        l.z = pos.z - v0.z;
                                                                        dp = (n.x * l.x + n.y * l.y + n.z * l.z);
                                                                        if (dp > 0)
                                                                        {
                                                                                dist2 = l.x * l.x + l.y * l.y + l.z * l.z;
                                                                                dist = Math.sqrt (dist2);
                                                                                atten = 1 / ((kc + kl * dist + kq * dist2) * nlen);
                                                                                k = dp * atten / dist;
                                                                                amb_r_sum0 += (ambient.r * atten);
                                                                                amb_g_sum0 += (ambient.g * atten);
                                                                                amb_b_sum0 += (ambient.b * atten);
                                                                                dif_r_sum0 += (diffuse.r * k);
                                                                                dif_g_sum0 += (diffuse.g * k);
                                                                                dif_b_sum0 += (diffuse.b * k);
                                                                        }
                                                                } //SPOT
                                                                {
                                                                        l.x = pos.x - v0.x;
                                                                        l.y = pos.y - v0.y;
                                                                        l.z = pos.z - v0.z;
                                                                        dp = (n.x * dir.x + n.y * dir.y + n.z * dir.z);
                                                                        if (dp > 0)
                                                                        {
                                                                                dist2 = l.x * l.x + l.y * l.y + l.z * l.z;
                                                                                dist = Math.sqrt(dist2);
                                                                                atten = 1 / ((kc + kl * dist + kq * dist2) * nlen);
                                                                                dpsl = (l.x * dir.x + l.y * dir.y + l.z * dir.z) / dist;
                                                                                if (dpsl > 0 )
                                                                                {
                                                                                        dpsl = Math.pow (dpsl, pf);
                                                                                        k = dp * dpsl * atten;
                                                                                        amb_r_sum0 += (ambient.r * atten);
                                                                                        amb_g_sum0 += (ambient.g * atten);
                                                                                        amb_b_sum0 += (ambient.b * atten);
                                                                                        dif_r_sum0 += (diffuse.r * k);
                                                                                        dif_g_sum0 += (diffuse.g * k);
                                                                                        dif_b_sum0 += (diffuse.b * k);
                                                                                }
                                                                        }
                                                                }
                                                        }
                                                        tv0.r = globalR + (int (amb_r_sum0 * mamb.r + dif_r_sum0 * mdif.r) >> 8);
                                                        tv0.g = globalG + (int (amb_g_sum0 * mamb.g + dif_g_sum0 * mdif.g) >> 8);
                                                        tv0.b = globalB + (int (amb_b_sum0 * mamb.b + dif_b_sum0 * mdif.b) >> 8);
                                                        tv1.r = tv0.r;
                                                        tv1.g = tv0.g;
                                                        tv1.b = tv0.b;
                                                        tv2.r = tv0.r;
                                                        tv2.g = tv0.g;
                                                        tv2.b = tv0.b;
                                                } else
                                                {
                                                        for (j = 0; j < lightLen; j+=1)
                                                        {
                                                                light = _lights [j];
                                                                pos = _lightsPos [j];
                                                                dir = _lightDirs [j];
                                                                diffuse = light.diffuseColor;
                                                                ambient = light.ambientColor;
                                                                //specular = light.specularColor;
                                                                kc = light.kc;
                                                                kl = light.kl;
                                                                kq = light.kq;
                                                                //radius = light.radius;
                                                                pf = light.powerFactor;
                                                                if (light.type == 0) //DIRECTIONAL
                                                               
                                                                {
                                                                        //tv0
                                                                        dp = (v0.nx * dir.x + v0.ny * dir.y + v0.nz * dir.z);
                                                                        if (dp > 0)
                                                                        {
                                                                                amb_r_sum0 += ambient.r;
                                                                                amb_g_sum0 += ambient.g;
                                                                                amb_b_sum0 += ambient.b;
                                                                                dif_r_sum0 += (diffuse.r * dp);
                                                                                dif_g_sum0 += (diffuse.g * dp);
                                                                                dif_b_sum0 += (diffuse.b * dp);
                                                                        }
                                                                        //tv1
                                                                        dp = (v1.nx * dir.x + v1.ny * dir.y + v1.nz * dir.z);
                                                                        if (dp > 0)
                                                                        {
                                                                                amb_r_sum1 += ambient.r ;
                                                                                amb_g_sum1 += ambient.g ;
                                                                                amb_b_sum1 += ambient.b ;
                                                                                dif_r_sum1 += (diffuse.r * dp);
                                                                                dif_g_sum1 += (diffuse.g * dp);
                                                                                dif_b_sum1 += (diffuse.b * dp);
                                                                        }
                                                                        //tv2
                                                                        dp = (v2.nx * dir.x + v2.ny * dir.y + v2.nz * dir.z);
                                                                        if (dp > 0)
                                                                        {
                                                                                amb_r_sum2 += ambient.r ;
                                                                                amb_g_sum2 += ambient.g ;
                                                                                amb_b_sum2 += ambient.b ;
                                                                                dif_r_sum2 += (diffuse.r * dp);
                                                                                dif_g_sum2 += (diffuse.g * dp);
                                                                                dif_b_sum2 += (diffuse.b * dp);
                                                                        }
                                                                } else
                                                                if (light.type == 1) //POINT
                                                               
                                                                {
                                                                        //              I0point * Clpoint
                                                                        //  I(d)point = ___________________
                                                                        //              kc +  kl*d + kq*d2
                                                                        //
                                                                        //  Where d = |p - s|
                                                                        l.x = - v0.x + pos.x;
                                                                        l.y = - v0.y + pos.y;
                                                                        l.z = - v0.z + pos.z;
                                                                        //tv0
                                                                        dp = (v0.nx * l.x + v0.ny * l.y + v0.nz * l.z);
                                                                        if (dp > 0)
                                                                        {
                                                                                dist2 = l.x * l.x + l.y * l.y + l.z * l.z;
                                                                                dist = Math.sqrt (dist2);
                                                                                atten = 1 / (kc + kl * dist + kq * dist2);
                                                                                k = dp * atten / dist;
                                                                                amb_r_sum0 += (ambient.r * atten);
                                                                                amb_g_sum0 += (ambient.g * atten);
                                                                                amb_b_sum0 += (ambient.b * atten);
                                                                                dif_r_sum0 += (diffuse.r * k);
                                                                                dif_g_sum0 += (diffuse.g * k);
                                                                                dif_b_sum0 += (diffuse.b * k);
                                                                        }
                                                                        //tv1
                                                                        l.x = - v1.x + pos.x;
                                                                        l.y = - v1.y + pos.y;
                                                                        l.z = - v1.z + pos.z;
                                                                        dp = (v1.nx * l.x + v1.ny * l.y + v1.nz * l.z);
                                                                        if (dp > 0)
                                                                        {
                                                                                dist2 = l.x * l.x + l.y * l.y + l.z * l.z;
                                                                                dist = Math.sqrt (dist2);
                                                                                atten = 1 / (kc + kl * dist + kq * dist2);
                                                                                k = dp * atten / dist;
                                                                                amb_r_sum1 += (ambient.r * atten);
                                                                                amb_g_sum1 += (ambient.g * atten);
                                                                                amb_b_sum1 += (ambient.b * atten);
                                                                                dif_r_sum1 += (diffuse.r * k);
                                                                                dif_g_sum1 += (diffuse.g * k);
                                                                                dif_b_sum1 += (diffuse.b * k);
                                                                        }
                                                                        //tv2
                                                                        l.x = - v2.x + pos.x;
                                                                        l.y = - v2.y + pos.y;
                                                                        l.z = - v2.z + pos.z;
                                                                        dp = (v2.nx * l.x + v2.ny * l.y + v2.nz * l.z);
                                                                        if (dp > 0)
                                                                        {
                                                                                dist2 = l.x * l.x + l.y * l.y + l.z * l.z;
                                                                                dist = Math.sqrt (dist2);
                                                                                atten = 1 / (kc + kl * dist + kq * dist2);
                                                                                k = dp * atten / dist;
                                                                                amb_r_sum2 += (ambient.r * atten);
                                                                                amb_g_sum2 += (ambient.g * atten);
                                                                                amb_b_sum2 += (ambient.b * atten);
                                                                                dif_r_sum2 += (diffuse.r * k);
                                                                                dif_g_sum2 += (diffuse.g * k);
                                                                                dif_b_sum2 += (diffuse.b * k);
                                                                        }
                                                                } //SPOT
                                                               
                                                                {
                                                                        //                   I0spotlight * Clspotlight * MAX( (l . s), 0)^pf
                                                                        // I(d)spotlight = __________________________________________
                                                                        //                               kc + kl*d + kq*d2
                                                                        // Where d = |p - s|, and pf = power factor
                                                                        //tv0
                                                                        l.x = - v0.x + pos.x;
                                                                        l.y = - v0.y + pos.y;
                                                                        l.z = - v0.z + pos.z;
                                                                        dp = (v0.nx * dir.x + v0.ny * dir.y + v0.nz * dir.z);
                                                                        if (dp > 0)
                                                                        {
                                                                                dist2 = l.x * l.x + l.y * l.y + l.z * l.z;
                                                                                dist = Math.sqrt (dist2);
                                                                                atten = 1 / (kc + kl * dist + kq * dist2);
                                                                                dpsl = (l.x * dir.x + l.y * dir.y + l.z * dir.z) / dist;
                                                                                if (dpsl > 0 )
                                                                                {
                                                                                        dpsl = Math.pow (dpsl, pf);
                                                                                        k = dp * dpsl * atten;
                                                                                        amb_r_sum0 += (ambient.r * atten);
                                                                                        amb_g_sum0 += (ambient.g * atten);
                                                                                        amb_b_sum0 += (ambient.b * atten);
                                                                                        dif_r_sum0 += (diffuse.r * k);
                                                                                        dif_g_sum0 += (diffuse.g * k);
                                                                                        dif_b_sum0 += (diffuse.b * k);
                                                                                }
                                                                        }
                                                                        //tv1
                                                                        l.x = - v1.x + pos.x;
                                                                        l.y = - v1.y + pos.y;
                                                                        l.z = - v1.z + pos.z;
                                                                        dp = (v1.nx * dir.x + v1.ny * dir.y + v1.nz * dir.z);
                                                                        if (dp > 0)
                                                                        {
                                                                                dist2 = l.x * l.x + l.y * l.y + l.z * l.z;
                                                                                dist = Math.sqrt (dist2);
                                                                                atten = 1 / (kc + kl * dist + kq * dist2);
                                                                                dpsl = (l.x * dir.x + l.y * dir.y + l.z * dir.z) / dist;
                                                                                if (dpsl > 0 )
                                                                                {
                                                                                        dpsl = Math.pow (dpsl, pf);
                                                                                        k = dp * dpsl * atten;
                                                                                        amb_r_sum1 += (ambient.r * atten);
                                                                                        amb_g_sum1 += (ambient.g * atten);
                                                                                        amb_b_sum1 += (ambient.b * atten);
                                                                                        dif_r_sum1 += (diffuse.r * k);
                                                                                        dif_g_sum1 += (diffuse.g * k);
                                                                                        dif_b_sum1 += (diffuse.b * k);
                                                                                }
                                                                        }
                                                                        //tv2
                                                                        l.x = - v2.x + pos.x;
                                                                        l.y = - v2.y + pos.y;
                                                                        l.z = - v2.z + pos.z;
                                                                        dp = (v2.nx * dir.x + v2.ny * dir.y + v2.nz * dir.z);
                                                                        if (dp > 0)
                                                                        {
                                                                                dist2 = l.x * l.x + l.y * l.y + l.z * l.z;
                                                                                dist = Math.sqrt (dist2);
                                                                                atten = 1 / (kc + kl * dist + kq * dist2);
                                                                                dpsl = (l.x * dir.x + l.y * dir.y + l.z * dir.z) / dist;
                                                                                if (dpsl > 0 )
                                                                                {
                                                                                        dpsl = Math.pow (dpsl, pf);
                                                                                        k = dp * dpsl * atten;
                                                                                        amb_r_sum2 += (ambient.r * atten);
                                                                                        amb_g_sum2 += (ambient.g * atten);
                                                                                        amb_b_sum2 += (ambient.b * atten);
                                                                                        dif_r_sum2 += (diffuse.r * k);
                                                                                        dif_g_sum2 += (diffuse.g * k);
                                                                                        dif_b_sum2 += (diffuse.b * k);
                                                                                }
                                                                        }
                                                                }
                                                        }
                                                        tv0.r = globalR + (int (amb_r_sum0 * mamb.r + dif_r_sum0 * mdif.r) >> 8);
                                                        tv0.g = globalG + (int (amb_g_sum0 * mamb.g + dif_g_sum0 * mdif.g) >> 8);
                                                        tv0.b = globalB + (int (amb_b_sum0 * mamb.b + dif_b_sum0 * mdif.b) >> 8);
                                                        tv1.r = globalR + (int (amb_r_sum1 * mamb.r + dif_r_sum1 * mdif.r) >> 8);
                                                        tv1.g = globalG + (int (amb_g_sum1 * mamb.g + dif_g_sum1 * mdif.g) >> 8);
                                                        tv1.b = globalB + (int (amb_b_sum1 * mamb.b + dif_b_sum1 * mdif.b) >> 8);
                                                        tv2.r = globalR + (int (amb_r_sum2 * mamb.r + dif_r_sum2 * mdif.r) >> 8);
                                                        tv2.g = globalG + (int (amb_g_sum2 * mamb.g + dif_g_sum2 * mdif.g) >> 8);
                                                        tv2.b = globalB + (int (amb_b_sum2 * mamb.b + dif_b_sum2 * mdif.b) >> 8);
                                                }
                                                tv0.r = tv0.r > 0xFF ? 0xFF : tv0.r;
                                                tv0.g = tv0.g > 0xFF ? 0xFF : tv0.g;
                                                tv0.b = tv0.b > 0xFF ? 0xFF : tv0.b;
                                                tv1.r = tv1.r > 0xFF ? 0xFF : tv1.r;
                                                tv1.g = tv1.g > 0xFF ? 0xFF : tv1.g;
                                                tv1.b = tv1.b > 0xFF ? 0xFF : tv1.b;
                                                tv2.r = tv2.r > 0xFF ? 0xFF : tv2.r;
                                                tv2.g = tv2.g > 0xFF ? 0xFF : tv2.g;
                                                tv2.b = tv2.b > 0xFF ? 0xFF : tv2.b;
                                               
                                        } else //没有灯光，但是接受灯光时，使用自发光
                                        {
                                                tv0.r = memi.r ;
                                                tv0.g = memi.g ;
                                                tv0.b = memi.b ;
                                                tv1.r = memi.r ;
                                                tv1.g = memi.g ;
                                                tv1.b = memi.b ;
                                                tv2.r = memi.r ;
                                                tv2.g = memi.g ;
                                                tv2.b = memi.b ;
                                        }
                                } else //no lighting
                                {
                                        if (gouraudShading)
                                        {
                                                tv0.r = v0.r, tv0.g = v0.g, tv0.b = v0.b;
                                                tv1.r = v1.r, tv1.g = v1.g, tv1.b = v1.b;
                                                tv2.r = v2.r, tv2.g = v2.g, tv2.b = v2.b;
                                        } else //flat
                                        {
                                                tv0.r = mdif.r, tv0.g = mdif.g, tv0.b = mdif.b;
                                                tv1.r = mdif.r, tv1.g = mdif.g, tv1.b = mdif.b;
                                                tv2.r = mdif.r, tv2.g = mdif.g, tv2.b = mdif.b;
                                        }
                                }
                               
                                // texture coords
                                if (hasTexture)
                                {
                                        tv0.u = v0.u ;
                                        tv0.v = v0.v ;
                                        tv1.u = v1.u ;
                                        tv1.v = v1.v ;
                                        tv2.u = v2.u ;
                                        tv2.v = v2.v ;
                                }
                               
                                if (clipcount == 0) // no clipping required
                                {
                                        //tv0
                                        var tmp : Number = 1 / tv0.w ;
                                        tv0.x = (tv0.x * csm00) * tmp + csm30;
                                        tv0.y = (tv0.y * csm11) * tmp + csm31;
                                        tv0.z = tmp;
                                        //tv1
                                        tmp = 1 / tv1.w ;
                                        tv1.x = (tv1.x * csm00) * tmp + csm30;
                                        tv1.y = (tv1.y * csm11) * tmp + csm31;
                                        tv1.z = tmp;
                                        //tv2
                                        tmp = 1 / tv2.w ;
                                        tv2.x = (tv2.x * csm00) * tmp + csm30;
                                        tv2.y = (tv2.y * csm11) * tmp + csm31;
                                        tv2.z = tmp;
                                        // add to _clipped_indices
                                        _clipped_indices [iCount] = vCount;
                                        iCount ++;
                                        _clipped_vertices [vCount] = tv0;
                                        vCount ++;
                                        _clipped_indices [iCount] = vCount;
                                        iCount ++;
                                        _clipped_vertices [vCount] = tv1;
                                        vCount ++;
                                        _clipped_indices [iCount] = vCount;
                                        iCount ++;
                                        _clipped_vertices [vCount] = tv2;
                                        vCount ++;
                                        continue;
                                }


                                // put into list for clipping
                                _unclipped_vertices [0] = tv0;
                                _unclipped_vertices [1] = tv1;
                                _unclipped_vertices [2] = tv2;
                                source = _unclipped_vertices;
                                outCount = 3;

                                // clip in NDC Space to Frustum
                                //new Vector3D (0.0, 0.0, - 1.0, - 1.0 ) , // near
                                if ((clipcount & 2) == 2)
                                {
                                        inCount = outCount;
                                        outCount = 0;
                                        dest = _clipped_vertices4;
                                        plane = _ndc_planes [1];
                                        b = source [0];
                                        bdot = (b.z * plane.z) + (b.w * plane.w);
                                        for (i = 1; i < inCount + 1; i+=1)
                                        {
                                                a = source [int(i % inCount)];
                                                adot = (a.z * plane.z) + (a.w * plane.w);
                                                // current point inside
                                                if (adot <= 0.0 )
                                                {
                                                        // last point outside
                                                        if (bdot > 0.0 )
                                                        {
                                                                // intersect line segment with plane
                                                                out = _transformedVertexs [int(tCount ++)];
                                                                dest [int(outCount ++)] = out;
                                                                // get t intersection
                                                                t = bdot / (((b.z - a.z) * plane.z) + ((b.w - a.w) * plane.w));
                                                                out.x = b.x + (a.x - b.x) * t ;
                                                                out.y = b.y + (a.y - b.y) * t ;
                                                                out.z = b.z + (a.z - b.z) * t ;
                                                                out.w = b.w + (a.w - b.w) * t ;
                                                                out.r = b.r + (a.r - b.r) * t ;
                                                                out.g = b.g + (a.g - b.g) * t ;
                                                                out.b = b.b + (a.b - b.b) * t ;
                                                                if(hasTexture)
                                                                {
                                                                        out.u = b.u + (a.u - b.u ) * t ;
                                                                        out.v = b.v + (a.v - b.v ) * t ;
                                                                }      
                                                        }
                                                        // add a to out
                                                        dest [int(outCount ++)] = a;
                                                }
                                                else
                                                {
                                                        if (bdot <= 0.0 )
                                                        {
                                                                out = _transformedVertexs [int(tCount ++)];
                                                                dest [int(outCount ++)] = out;
                                                                t = bdot / (((b.z - a.z) * plane.z) + ((b.w - a.w) * plane.w));
                                                                out.x = b.x + (a.x - b.x) * t ;
                                                                out.y = b.y + (a.y - b.y) * t ;
                                                                out.z = b.z + (a.z - b.z) * t ;
                                                                out.w = b.w + (a.w - b.w) * t ;
                                                                out.r = b.r + (a.r - b.r) * t ;
                                                                out.g = b.g + (a.g - b.g) * t ;
                                                                out.b = b.b + (a.b - b.b) * t ;
                                                                if(hasTexture)
                                                                {
                                                                        out.u = b.u + (a.u - b.u ) * t ;
                                                                        out.v = b.v + (a.v - b.v ) * t ;
                                                                }
                                                        }
                                                }
                                                b = a;
                                                bdot = adot;
                                        }
                                        // check we have 3 or more vertices
                                        if (outCount < 3)
                                        {
                                                continue;
                                        }
                                        source = _clipped_vertices4;
                                }

                                //new Vector3D (1.0, 0.0, 0.0, - 1.0 ) // left
                                if ((clipcount & 4) == 4)
                                {
                                        inCount = outCount;
                                        outCount = 0;
                                        dest = _clipped_vertices3;
                                        plane = _ndc_planes [2];
                                        b = source [0];
                                        bdot = (b.x * plane.x) + (b.w * plane.w);
                                        for (i = 1; i < inCount + 1; i+=1)
                                        {
                                                a = source [i % inCount];
                                                adot = (a.x * plane.x) + (a.w * plane.w);
                                                // current point inside
                                                if (adot <= 0.0 )
                                                {
                                                        // last point outside
                                                        if (bdot > 0.0 )
                                                        {
                                                                // intersect line segment with plane
                                                                out = _transformedVertexs [int(tCount ++)];
                                                                dest [int(outCount ++)] = out;
                                                                t = bdot / (((b.x - a.x) * plane.x) + ((b.w - a.w) * plane.w))
                                                                out.x = b.x + (a.x - b.x) * t ;
                                                                out.y = b.y + (a.y - b.y) * t ;
                                                                out.z = b.z + (a.z - b.z) * t ;
                                                                out.w = b.w + (a.w - b.w) * t ;
                                                                out.r = b.r + (a.r - b.r) * t ;
                                                                out.g = b.g + (a.g - b.g) * t ;
                                                                out.b = b.b + (a.b - b.b) * t ;
                                                                if(hasTexture)
                                                                {
                                                                        out.u = b.u + (a.u - b.u ) * t ;
                                                                        out.v = b.v + (a.v - b.v ) * t ;
                                                                }
                                                        }
                                                        // add a to out
                                                        dest [outCount ++] = a;
                                                }
                                                else
                                                {
                                                        // current point outside
                                                        if (bdot <= 0.0 )
                                                        {
                                                                out = _transformedVertexs [int(tCount ++)];
                                                                dest [int(outCount ++)] = out;
                                                                // get t intersection
                                                                t = bdot / (((b.x - a.x) * plane.x) + ((b.w - a.w) * plane.w))
                                                                out.x = b.x + (a.x - b.x) * t ;
                                                                out.y = b.y + (a.y - b.y) * t ;
                                                                out.z = b.z + (a.z - b.z) * t ;
                                                                out.w = b.w + (a.w - b.w) * t ;
                                                                out.r = b.r + (a.r - b.r) * t ;
                                                                out.g = b.g + (a.g - b.g) * t ;
                                                                out.b = b.b + (a.b - b.b) * t ;
                                                                if(hasTexture)
                                                                {
                                                                        out.u = b.u + (a.u - b.u ) * t ;
                                                                        out.v = b.v + (a.v - b.v ) * t ;
                                                                }
                                                        }
                                                }
                                                b = a;
                                                bdot = adot
                                        }
                                        // check we have 3 or more vertices
                                        if (outCount < 3)
                                        {
                                                continue;
                                        }
                                        source = _clipped_vertices3;
                                }
                                //new Vector3D ( - 1.0, 0.0, 0.0, - 1.0 ) , // right
                                if ((clipcount & 8) == 8)
                                {
                                        inCount = outCount;
                                        outCount = 0;
                                        dest = _clipped_vertices2;
                                        plane = _ndc_planes [3];
                                        b = source [0];
                                        bdot = (b.x * plane.x) + (b.w * plane.w);
                                        for (i = 1; i < inCount + 1; i+=1)
                                        {
                                                a = source [i % inCount];
                                                adot = (a.x * plane.x) + (a.w * plane.w);
                                                if (adot <= 0.0 )
                                                {
                                                        if (bdot > 0.0 )
                                                        {
                                                                out = _transformedVertexs [int(tCount ++)];
                                                                dest [int(outCount ++)] = out;

                                                                t = bdot / (((b.x - a.x) * plane.x) + ((b.w - a.w) * plane.w))
                                                                out.x = b.x + (a.x - b.x) * t ;
                                                                out.y = b.y + (a.y - b.y) * t ;
                                                                out.z = b.z + (a.z - b.z) * t ;
                                                                out.w = b.w + (a.w - b.w) * t ;
                                                                out.r = b.r + (a.r - b.r) * t ;
                                                                out.g = b.g + (a.g - b.g) * t ;
                                                                out.b = b.b + (a.b - b.b) * t ;
                                                                if(hasTexture)
                                                                {
                                                                        out.u = b.u + (a.u - b.u ) * t ;
                                                                        out.v = b.v + (a.v - b.v ) * t ;
                                                                }
                                                        }
                                                        dest [outCount ++] = a;
                                                }
                                                else
                                                {
                                                        if (bdot <= 0.0 )
                                                        {
                                                                out = _transformedVertexs [int(tCount ++)];
                                                                dest [int(outCount ++)] = out;

                                                                t = bdot / (((b.x - a.x) * plane.x) + ((b.w - a.w) * plane.w))
                                                                out.x = b.x + (a.x - b.x) * t ;
                                                                out.y = b.y + (a.y - b.y) * t ;
                                                                out.z = b.z + (a.z - b.z) * t ;
                                                                out.w = b.w + (a.w - b.w) * t ;
                                                                out.r = b.r + (a.r - b.r) * t ;
                                                                out.g = b.g + (a.g - b.g) * t ;
                                                                out.b = b.b + (a.b - b.b) * t ;
                                                                if(hasTexture)
                                                                {
                                                                        out.u = b.u + (a.u - b.u ) * t ;
                                                                        out.v = b.v + (a.v - b.v ) * t ;
                                                                }
                                                        }
                                                }
                                                b = a;
                                                bdot = adot;
                                        }
                                        // check we have 3 or more vertices
                                        if (outCount < 3)
                                        {
                                                continue;
                                        }
                                        source = _clipped_vertices2;
                                }
                                //new Vector3D (0.0, 1.0, 0.0, - 1.0 ) , // bottom
                                if ((clipcount & 16) == 16)
                                {
                                        inCount = outCount;
                                        outCount = 0;
                                        dest = _clipped_vertices1;
                                        plane = _ndc_planes [4];
                                        b = source [0];
                                        bdot = (b.y * plane.y) + (b.w * plane.w);
                                        for (i = 1; i < inCount + 1; i+=1)
                                        {
                                                a = source [i % inCount];
                                                adot = (a.y * plane.y) + (a.w * plane.w);
                                                if (adot <= 0.0 )
                                                {
                                                        if (bdot > 0.0 )
                                                        {
                                                                out = _transformedVertexs [int(tCount ++)];
                                                                dest [int(outCount ++)] = out;
                                                                t = bdot / (((b.y - a.y) * plane.y) + ((b.w - a.w) * plane.w))
                                                                out.x = b.x + (a.x - b.x) * t ;
                                                                out.y = b.y + (a.y - b.y) * t ;
                                                                out.z = b.z + (a.z - b.z) * t ;
                                                                out.w = b.w + (a.w - b.w) * t ;
                                                                out.r = b.r + (a.r - b.r) * t ;
                                                                out.g = b.g + (a.g - b.g) * t ;
                                                                out.b = b.b + (a.b - b.b) * t ;
                                                                if(hasTexture)
                                                                {
                                                                        out.u = b.u + (a.u - b.u ) * t ;
                                                                        out.v = b.v + (a.v - b.v ) * t ;
                                                                }
                                                        }
                                                        dest [outCount ++] = a;
                                                }
                                                else
                                                {
                                                        if (bdot <= 0.0 )
                                                        {
                                                                out = _transformedVertexs [int(tCount ++)];
                                                                dest [int(outCount ++)] = out;
                                                                t = bdot / (((b.y - a.y) * plane.y) + ((b.w - a.w) * plane.w))
                                                                out.x = b.x + (a.x - b.x) * t ;
                                                                out.y = b.y + (a.y - b.y) * t ;
                                                                out.z = b.z + (a.z - b.z) * t ;
                                                                out.w = b.w + (a.w - b.w) * t ;
                                                                out.r = b.r + (a.r - b.r) * t ;
                                                                out.g = b.g + (a.g - b.g) * t ;
                                                                out.b = b.b + (a.b - b.b) * t ;
                                                                if(hasTexture)
                                                                {
                                                                        out.u = b.u + (a.u - b.u ) * t ;
                                                                        out.v = b.v + (a.v - b.v ) * t ;
                                                                }
                                                        }
                                                }
                                                b = a;
                                                bdot = adot;
                                        }
                                        if (outCount < 3)
                                        {
                                                continue;
                                        }
                                        source = _clipped_vertices1;
                                }
                                //new Vector3D (0.0, - 1.0, 0.0, - 1.0 ) //top
                                if ((clipcount & 32) == 32)
                                {
                                        inCount = outCount;
                                        outCount = 0;
                                        dest = _clipped_vertices0;
                                        plane = _ndc_planes [5];
                                        b = source [0];
                                        bdot = (b.y * plane.y) + (b.w * plane.w);
                                        for (i = 1; i < inCount + 1; i+=1)
                                        {
                                                a = source [i % inCount];
                                                adot = (a.y * plane.y) + (a.w * plane.w);
                                                // current point inside
                                                if (adot <= 0.0 )
                                                {
                                                        // last point outside
                                                        if (bdot > 0.0 )
                                                        {
                                                                out = _transformedVertexs [int(tCount ++)];
                                                                dest [int(outCount ++)] = out;
                                                                t = bdot / (((b.y - a.y) * plane.y) + ((b.w - a.w) * plane.w))
                                                                out.x = b.x + (a.x - b.x) * t ;
                                                                out.y = b.y + (a.y - b.y) * t ;
                                                                out.z = b.z + (a.z - b.z) * t ;
                                                                out.w = b.w + (a.w - b.w) * t ;
                                                                out.r = b.r + (a.r - b.r) * t ;
                                                                out.g = b.g + (a.g - b.g) * t ;
                                                                out.b = b.b + (a.b - b.b) * t ;
                                                                if(hasTexture)
                                                                {
                                                                        out.u = b.u + (a.u - b.u) * t ;
                                                                        out.v = b.v + (a.v - b.v) * t ;
                                                                }
                                                        }
                                                        dest [outCount ++] = a;
                                                }
                                                else
                                                {
                                                        if (bdot <= 0.0 )
                                                        {
                                                                out = _transformedVertexs [int(tCount ++)];
                                                                dest [int(outCount ++)] = out;
                                                                t = bdot / (((b.y - a.y) * plane.y) + ((b.w - a.w) * plane.w));
                                                                out.x = b.x + (a.x - b.x) * t ;
                                                                out.y = b.y + (a.y - b.y) * t ;
                                                                out.z = b.z + (a.z - b.z) * t ;
                                                                out.w = b.w + (a.w - b.w) * t ;
                                                                out.r = b.r + (a.r - b.r) * t ;
                                                                out.g = b.g + (a.g - b.g) * t ;
                                                                out.b = b.b + (a.b - b.b) * t ;
                                                                if(hasTexture)
                                                                {
                                                                        out.u = b.u + (a.u - b.u) * t ;
                                                                        out.v = b.v + (a.v - b.v) * t ;
                                                                }
                                                        }
                                                }
                                                b = a;
                                                bdot = adot;
                                        }
                                        if (outCount < 3)
                                        {
                                                continue;
                                        }
                                        source = _clipped_vertices0;
                                }
                               
                                // put back into screen space.
                                vCount2 = vCount;
                                for (var g : int = 0; g < outCount; g+=1)
                                {
                                        tv0 = source [g];
                                        tmp = 1 / tv0.w ;
                                        tv0.x = (tv0.x * csm00) * tmp + csm30;
                                        tv0.y = (tv0.y * csm11) * tmp + csm31;
                                        tv0.z = tmp;
                                        _clipped_vertices [int(vCount ++)] = tv0;
                                }
                                // re-tesselate ( triangle-fan, 0-1-2,0-2-3.. )
                                for (g = 0; g <= outCount - 3; g+=1)
                                {
                                        _clipped_indices [int(iCount++)] = (vCount2);
                                        _clipped_indices [int(iCount++)] = (vCount2 + g + 1);
                                        _clipped_indices [int(iCount++)] = (vCount2 + g + 2);
                                }
                        }
                        primitivesDrawn += int (iCount / 3);
                        curRender.drawIndexedTriangleList (_clipped_vertices, vCount, _clipped_indices, iCount);
                }
                public function drawMeshBuffer(mesh:MeshBuffer):void
                {
                        drawIndexedTriangleList(mesh.vertices,mesh.vertices.length,mesh.indices,mesh.indices.length);
                }
                /**
                *用来渲染由线段组成的物体 ,此类物体不需要进行光照，贴图，和贴图坐标计算等
                * @vertices  Array 点的集合
                * @vertexCount int vertices的长度
                * @indexList 点与点之间的顺序(2点组成一条直线)
                * @indexCount int indexList.length
                */
                //Todo 这个方法有误,删除,以后添加
                override public function drawIndexedLineList (vertices : Vector.<Vertex>, vertexCount : int, indexList : Vector.<int>, indexCount : int) : void
                {
                }
                public function drawStencilShadowVolume (vertices : Vector.<Vertex>, vertexCount : int, useZFailMethod : Boolean) : void
                {
                }
                public function getDriverType () : String
                {
                        return VideoType.PIXEL;
                }
                public function createScreenShot () : BitmapData
                {

                        return target.bitmapData.clone ();
                }
                public function setPerspectiveCorrectDistance (distance : Number = 400) : void
                {
                        persDistance = (distance < 10) ? 10 : distance;

                        for (var i : int = 0; i < TRType.COUNT; i+=1)
                        {
                                var render : ITriangleRenderer = renderers [i];
                                render.setPerspectiveCorrectDistance (distance);
                        }
                }
                public function setMipMapDistance (distance : Number = 500) : void
                {
                        mipMapDistance = (distance < 10) ? 10 : distance;
                       
                        for (var i : int = 0; i < TRType.COUNT; i+=1)
                        {
                                var render : ITriangleRenderer = renderers [i];
                                render.setMipMapDistance (distance);
                        }
                }
                public function setHeight(height:int) : void
                {
                        for (var i : int = 0; i < TRType.COUNT; i+=1)
                        {
                                var render : ITriangleRenderer = renderers [i];
                                render.setHeight(height);
                        }
                }
                public function setVector(tv : Vector.<uint>, bv : Vector.<Number>) : void
                {
                        for (var i : int = 0; i < TRType.COUNT; i+=1)
                        {
                                var render : ITriangleRenderer = renderers[i];
                                render.setVector(tv,bv);
                        }
                }
        }
}

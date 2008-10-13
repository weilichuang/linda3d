package linda.scene.camera
{
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	import linda.math.Matrix4;
	import linda.math.Vector2D;
	import linda.utils.InputControl;
	import linda.utils.InputMap;
	public final class CameraFPSSceneNode extends CameraSceneNode 
	{
		private var _key_map:InputMap;
		private var _input_control:InputControl;	

		private var _first_update:Boolean;
		private var _last_animation_time:int;
		private var _tmp_matrix:Matrix4;
		private var _tmp_vector:Vector3D;

		private var _move_speed:Number;
		private var _rotate_speed:Number;
		private var _target_vector:Vector3D;
		public var allowVerticalMovement:Boolean;

		private static const MAX_VERTICAL_ANGLE:Number = 88.0;

		public function CameraFPSSceneNode(	inputControl:InputControl, 
											rotateSpeed:Number = 0.2,
											moveSpeed:Number = 200.0,
											verticalMovement:Boolean = false)
		{
			super();
			
			if(inputControl == null)
			{
				return;
			}

			_input_control = inputControl;

			_move_speed = moveSpeed;
			_rotate_speed = rotateSpeed;
			allowVerticalMovement = verticalMovement;
			
			_move_speed /= 1000.0;
			
			_target_vector  = new Vector3D();
			
			// create key map
			_key_map = new InputMap();
			
			// create tmp variables
			_tmp_matrix = new Matrix4();
			_tmp_vector = new Vector3D();
			
			_first_update = true;

		}
		override public function destroy():void
		{
			super.destroy();
			_tmp_matrix=null;
			_tmp_vector=null;
			_input_control=null;
			_key_map=null;
		}				
		override public function onAnimate(timeMs:int):void 
		{
			// animate the camera
			animate();
			
			super.onAnimate(timeMs);
		}
		private function animate():void
		{
			// check this camera is active view
			if (sceneManager.getActiveCamera() != this)
			{
				return;
			}
		
			// check for first update
			if (_first_update)
			{
				//_input_control.setRelativePositionXY(0.5, 0.5);
						
				_last_animation_time = getTimer();
		
				_first_update = false;
				return;
			}
		
			// get time
			var now:Number = getTimer();
			var time_difference:Number = now - _last_animation_time;
			_last_animation_time = now;
		
			// Update rotation
			target.x=0;
			target.y=0;
			target.z=1;
		
			_relativeRotation.x *= -1.0;
			_relativeRotation.y *= -1.0;
		
			// get cursor pos on screen
			var cursorpos:Vector2D = _input_control.getRelativePosition();
			
			// clamp pos
			if (!(cursorpos.x < 0.55 && cursorpos.x > 0.45) || !(cursorpos.y < 0.55 && cursorpos.y > 0.45))
			{
				_relativeRotation.y += (0.5 - cursorpos.x) * _rotate_speed;
				_relativeRotation.x += (0.5 - cursorpos.y) * _rotate_speed;
				//_input_control.setRelativePositionXY(0.5, 0.5);
	
				if (_relativeRotation.x > MAX_VERTICAL_ANGLE) _relativeRotation.y = MAX_VERTICAL_ANGLE;
				if (_relativeRotation.x < -MAX_VERTICAL_ANGLE) _relativeRotation.y = -MAX_VERTICAL_ANGLE;
			}		
		
			// set target
			_tmp_vector.x = -_relativeRotation.x;
			_tmp_vector.y = -_relativeRotation.y;
			_tmp_vector.z = 0;
			
			_tmp_matrix.setRotation(_tmp_vector);
			_tmp_matrix.transformVector(target);
		
			// position
			var posX:Number=0;
			var posY:Number=0;
			var posZ:Number=0;
			
			var move_dirX:Number = target.x;
			var move_dirY:Number = target.y;
			var move_dirZ:Number = target.z;
			
			// check vertical movement allowed
			if (!allowVerticalMovement)
			{
				move_dirY = 0.0;
			}
			
			// movedir.normalize();
			var l:Number = Math.sqrt((move_dirX*move_dirX) + (move_dirY*move_dirY) + (move_dirZ*move_dirZ));
			if (l != 0) 
			{
				l = 1.0 / l;
				move_dirX *= l;
				move_dirY *= l;
				move_dirZ *= l;
			}
			
			// key down - forward
			if (_input_control.keyDown[_key_map.moveForward])
			{
				posX = (move_dirX * (time_difference * _move_speed));
				posY = (move_dirY * (time_difference * _move_speed));
				posZ = (move_dirZ * (time_difference * _move_speed));
			}
		
			// key down - back
			if (_input_control.keyDown[_key_map.moveBack])
			{
				posX = -(move_dirX * (time_difference * _move_speed));
				posY = -(move_dirY * (time_difference * _move_speed));
				posZ = -(move_dirZ * (time_difference * _move_speed));
			}
		
			// strafing
			var strafe_vectX:Number = (target.y*upVector.z) - (target.z*upVector.y);
			var strafe_vectY:Number = (target.z*upVector.x) - (target.x*upVector.z);
			var strafe_vectZ:Number = (target.x*upVector.y) - (target.y*upVector.x);

			if (!allowVerticalMovement)
			{
				strafe_vectY = 0.0;
			}
		
			//strafevect.normalize();
			l = Math.sqrt((strafe_vectX*strafe_vectX) + (strafe_vectY*strafe_vectY) + (strafe_vectZ*strafe_vectZ));
			if (l != 0) 
			{
				l = 1.0 / l;
				strafe_vectX *= l;
				strafe_vectY *= l;
				strafe_vectZ *= l;
			}
		
			// key down - right
			if (_input_control.keyDown[_key_map.moveStrafeLeft])
			{
				posX = (strafe_vectX * (time_difference * _move_speed));
				posY = (strafe_vectY * (time_difference * _move_speed));
				posZ = (strafe_vectZ * (time_difference * _move_speed));
			}
		
			// key down - left
			if (_input_control.keyDown[_key_map.moveStrafeRight])
			{
				posX = -(strafe_vectX * (time_difference * _move_speed));
				posY = -(strafe_vectY * (time_difference * _move_speed));
				posZ = -(strafe_vectZ * (time_difference * _move_speed));
			}
					
			{
				// update position
				_relativeTranslation.x += posX;
				_relativeTranslation.y += posY;
				_relativeTranslation.z += posZ;
				
				// write right target
				//_target_vector.copy(target);
				_target_vector.x=target.x;
				_target_vector.y=target.y;
				_target_vector.z=target.z;
				target.x += _relativeTranslation.x;
				target.y += _relativeTranslation.y;
				target.z += _relativeTranslation.z;
			}
			
			_relativeRotation.x *= -1.0;
			_relativeRotation.y *= -1.0;
			
		}

		/** function: setTarget
		 *  Sets the look at target of the camera
		 * 
		 *  parameters:
		 *   lookAt - <Vector3D> look at target of the camera. Vector is dropped once set
		 */
		override public function setTarget(lookAt:Vector3D):void
		{
			updateAbsoluteMatrix();
			
			var vect:Vector3D = lookAt.subtract(getAbsolutePosition());
			//vect=vect.getHorizontalAngle();
			
			_relativeRotation.x = vect.x;
			_relativeRotation.y = vect.y;
		
			if (_relativeRotation.x > MAX_VERTICAL_ANGLE)
			{
				 _relativeRotation.x -= Math.PI*2;
			}
		}

	}
}
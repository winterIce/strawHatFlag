package 
{
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Collision.b2AABB;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.Joints.b2DistanceJoint;
	import Box2D.Dynamics.Joints.b2DistanceJointDef;
	import Box2D.Dynamics.Joints.b2MouseJoint;
	import Box2D.Dynamics.Joints.b2MouseJointDef;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;
 
    import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author winterIce
	 */
	public class cell extends MovieClip
	{
		private var world:b2World;
		private var pixelsPerMeter;
		private var mainscene:strawHatMainScene;
		private var property:Object;
		private var _circle:b2Body;
		public function cell(config) {
			this.world = config.mainscene.getWorld;
			this.pixelsPerMeter = config.mainscene.getPixelsPerMeter;
			this.mainscene = config.mainscene;
			this.property = new Object();
			this.property.x = config.x||100;
			this.property.y = config.y||20;
			this.property.r = config.r || 10;
			this.property.type = config.type;
		    createCell();
		}
		public function createCell() {
			var bodyDef:b2BodyDef = new b2BodyDef();
			bodyDef.type = (this.property.type==0)?b2Body.b2_staticBody:b2Body.b2_dynamicBody;
			bodyDef.position.Set(this.property.x/pixelsPerMeter,this.property.y/pixelsPerMeter);
			var circleShape:b2CircleShape = new b2CircleShape();
			circleShape.SetRadius(this.property.r/pixelsPerMeter);
			var fixtureDef:b2FixtureDef = new b2FixtureDef();
			fixtureDef.shape = circleShape;
			fixtureDef.density = 0.0;
			fixtureDef.friction = 0.4;
			fixtureDef.restitution = 0.3;
			this._circle = this.world.CreateBody(bodyDef);
			this._circle.CreateFixture(fixtureDef);
		}
		
		public function get circle():b2Body {
			return this._circle;
		}
		
	}
	
}
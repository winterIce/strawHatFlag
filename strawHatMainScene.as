package 
{
	/**
	 * ...
	 * @author winterIce
	 */
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
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.geom.Vector3D;
 
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.*;
    import flash.net.URLRequest;

	public class strawHatMainScene extends Sprite
	{
		private var world:b2World;
		private var timeStep:Number;
		private var iterations:uint;
		private var pixelsPerMeter:Number = 30;
		private var mouseJoint:b2MouseJoint;
		private var mousePVec:b2Vec2 = new b2Vec2();
		
		private var cellArr:Array;
		private var _vertices:Vector.<Number>=new Vector.<Number>();
		private var _indices:Vector.<int>=new Vector.<int>();
		private var _uvtData:Vector.<Number>=new Vector.<Number>();
		private var _bitmapData:BitmapData;
		
		private var imgLoader:Loader = new Loader();
		private var opFlag:Sprite = new Sprite();
		
		private var mouseUpFlag:Boolean;
		public function strawHatMainScene():void {
			createWorld();
			makeDebugDraw();
			createWall();
			createJoint();
			loadImg();
			addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			addEventListener(Event.ENTER_FRAME,onEnterframe);
		}
		
		private function createWorld():void{
			var gravity:b2Vec2 = new b2Vec2(0.0,0.0);
			var doSleep:Boolean = true;
			this.world = new b2World(gravity,doSleep);
			this.world.SetWarmStarting(true);
			timeStep = 1.0/30.0;
			iterations = 10;
		}
 
		private function makeDebugDraw():void{
			var debugDraw:b2DebugDraw = new b2DebugDraw();
			var debugSprite:Sprite = new Sprite();
			addChild(debugSprite);
			debugDraw.SetSprite(debugSprite);
			debugDraw.SetDrawScale(30.0);
			debugDraw.SetFillAlpha(0.5);
			debugDraw.SetLineThickness(1.0);
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			this.world.SetDebugDraw(debugDraw);
		}
 
		private function createWall():void{
			var bodyDef:b2BodyDef = new b2BodyDef();
			// Body的中心点
			bodyDef.position.Set(400/pixelsPerMeter,500/pixelsPerMeter);
			var body:b2Body = this.world.CreateBody(bodyDef);
			var shape:b2PolygonShape = new b2PolygonShape();
			// 几何体的半宽和半高
			shape.SetAsBox(400/pixelsPerMeter,15/pixelsPerMeter);
			body.CreateFixture2(shape);
		}
 
		private function createJoint():void {
			
			var config:Object = new Object();
			this.cellArr = [];
			var obj1:b2Body;
			var obj2:b2Body;
			config.mainscene = this;
			for (var j:uint = 0; j < 11; j++ ) {
			    for (var i:uint = 0; i < 5; i++ ) {
				    config.type = 1;
				    if (i == 0) config.type = 0;//type=0为static,type=1为dynamic
			        config.x = 150+50*j;
			        config.y = 20+80*i;
			        config.r = 25;
			        var cellP:cell = new cell(config);
			        this.addChild(cellP);
			        this.cellArr.push(cellP);
				
				    //和前一个关联
					if ((i != 0 || j != 0)&&i!=0) {
				        obj1 = cellP.circle;
					    obj2 = cellArr[cellArr.length - 2].circle;
					    createDistanceJoint(obj1, obj2);
					}
					//和上一列关联
					if (j * 5 + i >= 5) {
					    obj1 = cellP.circle;
					    obj2 = cellArr[cellArr.length - 6].circle;
					    createDistanceJoint(obj1, obj2);
					}
			    }//for
			}//for	
		}
 
		private function createDistanceJoint(obj1,obj2):void {
		    var jointDef:b2DistanceJointDef = new b2DistanceJointDef();
			jointDef.Initialize(obj1,obj2,obj1.GetWorldCenter(),obj2.GetWorldCenter());
			jointDef.collideConnected = true;
			jointDef.dampingRatio=0;//0--1
			jointDef.frequencyHz=1;
			this.world.CreateJoint(jointDef);
		}
		
		private function onMouseDown(e:MouseEvent):void{
			var body:b2Body = getBodyAtMouse();
			if(body){
				var mouseJointDef:b2MouseJointDef = new b2MouseJointDef();
				mouseJointDef.bodyA = this.world.GetGroundBody();
				mouseJointDef.bodyB = body;
				mouseJointDef.target.Set(mouseX/pixelsPerMeter,mouseY/pixelsPerMeter);
				mouseJointDef.maxForce = 30000;
				mouseJoint = this.world.CreateJoint(mouseJointDef) as b2MouseJoint;
			}
			mouseUpFlag = false;
		}
 
		private function onMouseUp(e:MouseEvent):void{
			if(mouseJoint){
				this.world.DestroyJoint(mouseJoint);
				mouseJoint = null;
			}
			mouseUpFlag = true;
		}
 
		private function getBodyAtMouse(includeStatic:Boolean = false):b2Body{
			var mouseXWorldPhys:Number = mouseX/pixelsPerMeter;
			var mouseYWorldPhys:Number = mouseY/pixelsPerMeter;
			mousePVec.Set(mouseXWorldPhys,mouseYWorldPhys);
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(mouseXWorldPhys-0.001,mouseYWorldPhys-0.001);
			aabb.upperBound.Set(mouseXWorldPhys-0.001,mouseYWorldPhys+0.001);
			var body:b2Body = null;
			var fixture:b2Fixture;
			function GetBodyCallBack(fixture:b2Fixture):Boolean{
				var shape:b2Shape = fixture.GetShape();
				if(fixture.GetBody().GetType() != b2Body.b2_staticBody || includeStatic){
					var inside:Boolean = shape.TestPoint(fixture.GetBody().GetTransform(),mousePVec);
					if(inside){
						body = fixture.GetBody();
						return false;
					}
				}
				return true;
			}
			this.world.QueryAABB(GetBodyCallBack,aabb);
			return body;
		}
 
		private function onEnterframe(e:Event):void{
			this.world.Step(timeStep,iterations,iterations);
			this.world.ClearForces();
			this.world.DrawDebugData();
			if(mouseJoint){
				var xpos:Number = mouseX/pixelsPerMeter;
				var ypos:Number = mouseY/pixelsPerMeter;
				var v2:b2Vec2 = new b2Vec2(xpos,ypos);
				mouseJoint.SetTarget(v2);
			}
			
			if (this._bitmapData) {
				opFlag.graphics.clear();
                opFlag.graphics.beginBitmapFill(this._bitmapData);
				opFlag.graphics.drawTriangles(this.vertices,this.indices,this.uvtData);
                opFlag.graphics.endFill();
                addChild(opFlag);
			}
			
			if(mouseUpFlag&&mouseJoint){
			    this.world.DestroyJoint(mouseJoint);
		    }
		}
		
		public function loadImg() {
			var picPath:String = "op_strawHat.jpg";
			var urlRec:URLRequest = new URLRequest(picPath);	 
			imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,onComplete);
			imgLoader.load(urlRec);
		}
		
		
		
		public function onComplete(e:Event):void {
            var bmp = Bitmap(imgLoader.content);
			this._bitmapData = bmp.bitmapData;
		}
		
		
		public function get vertices() {
			this._vertices = new Vector.<Number>();
			for (var i:uint = 0, len:uint = this.cellArr.length; i < len; i++) {
			    this._vertices.push(this.cellArr[i].circle.GetPosition().x*this.getPixelsPerMeter, this.cellArr[i].circle.GetPosition().y*this.getPixelsPerMeter);
			}
			return this._vertices;
		}
		public function get indices() {
			this._indices = new Vector.<int>();
			var t1, t2, t3, t4;
			for (var i:uint = 0; i < 10; i++ ) {
				for (var j:uint = 0; j < 4; j++ ) {
					t1 = i * 5 + j;
					t2 = t1 + 5;
					t3 = t1 + 1;
					t4 = t1 + 6;
					this._indices.push(t1, t2, t3);
					this._indices.push(t2, t3, t4);
				}
			}
			return this._indices;
		}
		
		public function get uvtData() {
			this._uvtData = new Vector.<Number>();
			for (var i:uint = 0; i <= 10; i++ ) {
				for (var j:uint = 0; j <= 4; j++ ) {
				    this._uvtData.push(i * 0.1, j * 0.25);	
				}
			}
			return this._uvtData;
		}
		public function get getWorld() {
			return world;
		}
		
		public function get getPixelsPerMeter() {
			return pixelsPerMeter;
		}
		
	}
}
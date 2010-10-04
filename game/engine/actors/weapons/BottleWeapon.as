package engine.actors.weapons {
    
    import engine.IObserver;
    import engine.actors.player.Hero;
    import engine.actors.enemies.Enemy;
    import engine.actors.geoms.*;
    import flash.events.Event;
    import engine.actors.Animatable;
    
    public class BottleWeapon extends Weapon implements IObserver {
        
        private var throwDistance:int = 30;
        private var velX:Number = 0;
        
        public function BottleWeapon(owner) {
            super(owner);
        }
        
		override public function setup() {
		    flySpeed = 4;
		    damage = 1;
		    
		    myName = "BottleWeapon";
            mySkin = "BottleWeaponSkin";
		    
		    tilesWide = 1;
    		tilesTall = 1;
		    collide_left = 2; // what pixel do we collide on on the left
    		collide_right = 14; // what pixel do we collide on on the right
    		
    		startFrame = 0; // the first frame to loop on
            endFrame = 7; // the final frame in the row
            nowFrame = 0; // current frame in row
            loopFrame = 0; // frame at which to loop
            loopType = 1; // 0 loops, 1 bounces
            loopRow = 0; // which row are we on
            loopDir = 1; // loop forward (to the right) by default
            speed = 2; // how many frames should go by before we advance
    		
		}
		
		override public function notify(subject):void {
		    if(subject is Hero) {
		        if(checkCollision(subject)) {
    	            subject.receiveDamage(damage);
    	            frameCount = frameDelay;
                }
		    }
		}
		
		public function throwBottle(goingLeft) {
		    frameCount = 0;
		    frameDelay = throwDistance;
		    if(goingLeft) {
    		    velX = -flySpeed;
    		} else {
    		    velX = flySpeed;
    		}
		}
		
		override public function update():void {
		    animate();		    
		    if(frameCount >= frameDelay) {
		        frameCount = 0;
		        owner.catchBottle(this);
		    } else {
		        frameCount++;
		    }
		    this.x += velX;
		    notifyObservers();
		}
		
    }
}
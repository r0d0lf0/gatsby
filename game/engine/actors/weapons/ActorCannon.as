package engine.actors.weapons {
    
    import engine.IObserver;
    import engine.actors.Actor;
	import engine.Scoreboard;
    import engine.actors.player.Hero;
	import flash.utils.getDefinitionByName;
	import engine.actors.weapons.Projectile;
	
	import flash.utils.Timer;
    import flash.events.TimerEvent;
    
    public class ActorCannon extends Actor implements IObserver {
        
        private var owner;
        protected var ammoType:String = "Projectile";
        public var shotsArray = new Array();
        public var shotsMax = 1;
        public var shotAvailable = true;
        public var shotDelay = 100;
        
        public var vecx = 1;
        public var vecy = 0;
        
        private var shotTimer:Timer;
        
        public function ActorCannon() {
            super();
            shotTimer = new Timer(shotDelay,1);
			shotTimer.addEventListener(TimerEvent.TIMER, this.shotReset);
        }
        
        public function shotReset(e) {
            shotAvailable = true;
        }        
        
        public function fire() {
            if(shotsArray.length < shotsMax && shotAvailable) {
                trace("fire!");
                var newProjectile = getProjectile();
                shotsArray.push(newProjectile);
                myMap.spawnActor(newProjectile, this.x, this.y);
                shotAvailable = false;
                shotTimer.reset();
                shotTimer.start();
            }
        }
        
        private function getProjectile() {
            var tempProjectile = new HatProjectile(this);
            tempProjectile.vecx = vecx;
            tempProjectile.vecy = vecy;
            tempProjectile.lifeSpan = 300;
            return tempProjectile;
        }
        
        protected function cleanupAmmo() {
            for(var i = 0; i < shotsArray.length; i++) {
                if(shotsArray[i].isDead) {
                    myMap.removeFromMap(shotsArray[i])
                    removeAmmo(shotsArray[i]);
                }
            }
        }
        
        protected function removeAmmo(ammo) {
            if(shotsArray.length > 0) {
                for (var i:int=0; i<shotsArray.length; i++) {
                    if(shotsArray[i] == ammo) {
                        shotsArray.splice (i,1);
                        break;
                    }
                }
            }
        }
        
        override public function notify(subject:*):void {
		    if(subject is Hero) {
		        this.x = subject.x;
		        this.y = subject.y;
		    }
		}
        
        override public function update():void {
            cleanupAmmo();
        }
        
        
        
    }
    
}
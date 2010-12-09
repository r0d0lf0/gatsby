package engine {
	
	import engine.actors.ActorScore;
	import engine.actors.specials.ScorePowerup;
	import flash.media.Sound;
	import flash.media.SoundChannel;
    
    public class Scoreboard implements ISubject {
        
        private static var _instance:Scoreboard;
        public static var score:int = 0;
        public static var lives:int = 3;
        public static var HP:int = 3;
        private static var observers:Array = new Array();
		public static var multiplier = 1;
		private static var effectsChannel;
		private static var extraLivesCounter = 0;
		private static const extraLivesPoints = 10000;

        
        public function Scoreboard(pvt:PrivateClass) {
            
        }
        
        public static function getInstance():Scoreboard {
            if(Scoreboard._instance == null) {
                Scoreboard._instance = new Scoreboard(new PrivateClass());
                trace("Scoreboard instantiated.");
            }
            return Scoreboard._instance;
        }
        
        public function setHP(HP) {
			if(HP < 0) {
				HP = 0;
			}
            Scoreboard.HP = HP;
            notifyObservers();
        }        
        
        public function getHP():Number {
            return Scoreboard.HP;
        }

		public function setMultiplier(newMultiplier) {
			Scoreboard.multiplier = newMultiplier;
		}
        
        public function addToScore(giver, amount:Number) {
			var additionalAmount = amount * Scoreboard.multiplier;
            Scoreboard.score += additionalAmount;
			var myScore = new ActorScore(additionalAmount, giver.x, giver.y);
			var myMap = giver.getMap();
			myMap.addChild(myScore);
			if(checkExtraLife()) {
			    var myHero = myMap.getHero();
			    var xtra = new ActorScore('1UP', myHero.x, myHero.y);
			    myMap.addChild(xtra);
			}
            notifyObservers();
        }
        
        private function checkExtraLife() {
            if(Math.floor(Scoreboard.score / extraLivesPoints) > extraLivesCounter) {
                extraLivesCounter++;
                addLife();
                var xtraLifeSound = new extra_life_sound();
                effectsChannel = xtraLifeSound.play(0);
                trace(Math.floor(Scoreboard.score / Scoreboard.extraLivesPoints));
                return true;
            } else {
                return false;
            }
        }
        
        public function setScore(newScore:Number) {
            Scoreboard.score = newScore;
            notifyObservers();
        }
        
        public function getScore() {
            return Scoreboard.score;
        }
        
        public function removeLife() {
            Scoreboard.lives--;
            notifyObservers();
        }
        
        public function addLife() {
            Scoreboard.lives++;
            notifyObservers();
        }
        
        public function getLives() {
            return Scoreboard.lives;
        }
        
        public function setLives(newLives) {
            Scoreboard.lives = newLives;
        }
        
		public function addObserver(observer):void {
		    if(!isObserver(observer)) {
		        observers.push(observer);
		    }
		}
		
		public function isObserver(observer):Boolean {
		    for(var ob:int=0; ob<observers.length; ob++) {
		        if(observers[ob] == observer) {
		            return true;
		        }
		    }
		    return false;
		}
		
		public function removeObserver(observer):void {
		    for (var ob:int=0; ob<observers.length; ob++) {
                if(observers[ob] == observer) {
                    observers.splice (ob,1);
                    break;
                }
            }
		}
		
		public function notifyObservers():void {
		    for(var ob=0; ob<observers.length; ob++) {
		        observers[ob].notify(this);
		    }
		}
        
    }
    
}

class PrivateClass {
    public function PrivateClass() {
        trace("Private class is up.");
    }
}
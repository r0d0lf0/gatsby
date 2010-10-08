﻿package engine.actors.player {
    
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.ui.Keyboard;
	import engine.IKeyboard;
	import flash.geom.Rectangle;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import flash.events.Event;
	import engine.actors.Actor;
	import engine.actors.Walker;
	import engine.actors.geoms.*;
	import engine.actors.specials.*;
	import controls.KeyMap;
	import engine.actors.weapons.Weapon;
	import engine.actors.weapons.HatWeapon;
	import flash.media.Sound;
	import flash.media.SoundChannel;

	dynamic public class Hero extends Walker implements IKeyboard {
	    
	    // set our variables for different input
        private static var BUTTON_DOWN = false;
        private static var BUTTON_LEFT = false;
        private static var BUTTON_RIGHT = false;
        private static var BUTTON_SPACE = false;
        private static var BUTTON_SHIFT = false;
	    
	    // these hold what things we can currently do
	    private var shootEnabled = true;
	    private var hatAvailable = true;		
		
		public var hat;  // holder for our weapon object
		
		private var keys:KeyMap = KeyMap.getInstance();
						
		private var keyboardStatus:Array = new Array();
				
		private var jumpSound = new hero_jump();
		private var hurtSound = new hero_hurt();
		private var powerupSound = new powerup_sound();
		private var healthPowerupSound = new martini_sound();
		private var throwSound = new hero_throw();
		private var effectsChannel;
		
		private var damageFlag = false; // flag for if the hero has been damaged
		private var damageCounter = 0; // counter variable to see how long we've been damaged
		private var damageDuration = 60; // number of frames to be invincible after damage
		
		private var maxHP = 3; // max number of health point
		
		// constructor, geesh
		public function Hero():void {    
			if (stage != null) {
				buildHero();
			} else {
				addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			}
		}
		
		private function addedToStage(evt) {
			buildHero();
		}
		
		private function buildHero():void{
			keys.addEventListener(KeyMap.KEY_UP, onKeyRelease);
			hat = new HatWeapon(this);
			HP = scoreboard.getHP();
		}
		
		override public function update():void {
		    if(scoreboard.getHP()) { // if we're alive
		        if(damageFlag) {  // if we're being damaged
    		        if(damageCounter < damageDuration) { // flicker our alpha
    		            this.alpha = damageCounter % 2; // every other frame
    		            damageCounter++; // and count how long we've been damaged
    		        } else { // if there's a damage flag, and duration is up
    		            damageCounter = 0; // reset the damage counter
    		            damageFlag = false; // and remove damage flag
    		        }
    		    }
    		    moveMe(); // move me around
    		    readInput(); // and read the input for the next frame
		    } else { // otherwise, if i have no HP
                killMe(); // kill me
		    }
		}
		
		// keeps anim going if it needs to
		private function onKeyRelease(evt:Event):void{
		    
		}
		
		public function keyDownHandler(evt):void {
		    // here's where we handle keyboard changes
		    if(evt.keyCode == Keyboard.SPACE) {
		        BUTTON_SPACE = true;
		    } else if(evt.keyCode == Keyboard.LEFT) {
		        BUTTON_LEFT = true;
		    } else if(evt.keyCode == Keyboard.RIGHT) {
		        BUTTON_RIGHT = true;
		    } else if(evt.keyCode == Keyboard.SHIFT) {
		        BUTTON_SHIFT = true;
		    }
		}
		
		public function keyUpHandler(evt):void {
		    // here's where we handle keyboard changes
		    if(evt.keyCode == Keyboard.SPACE) {
		        BUTTON_SPACE = false;
		    } else if(evt.keyCode == Keyboard.LEFT) {
		        BUTTON_LEFT = false;
		    } else if(evt.keyCode == Keyboard.RIGHT) {
		        BUTTON_RIGHT = false;
		    } else if(evt.keyCode == Keyboard.SHIFT) {
		        BUTTON_SHIFT = false;
		    }
		}
		
		override public function setup() {
		    collide_left = 10; // what pixel do we collide on on the left
    		collide_right = 22; // what pixel do we collide on on the right
		    
		    myName = "Hero"; // the generic name of our enemy
            mySkin = "HeroSkin"; // the name of the skin for this enemy
		}	
		
		override public function receiveDamage(attacker):void {
		    if(!damageFlag) {
		        trace("hit " + attacker.damage);
		        HP -= attacker.damage;
		        scoreboard.setHP(HP);
    		    damageFlag = true;
    		    effectsChannel = hurtSound.play(0);  // play it
		    }
		}
		
		public function receivePowerup(powerup):void {
		    if(powerup is HealthPowerup) {
		        HP += powerup.health;
		        if(HP > maxHP) {
		            HP = maxHP;
		        }
    		    scoreboard.setHP(HP);
    		    effectsChannel = healthPowerupSound.play(0);
		    } else if(powerup is ScorePowerup) {
		        scoreboard.addToScore(powerup.points);
		        effectsChannel = powerupSound.play(0);
		    }
		}
		
		public function getHP():Number {
		    return HP;
		}
		
		private function readInput():void {
		    if(walkEnabled) {
		        if(BUTTON_RIGHT) {
		            this.velx += this.Xspeed;
		            goingLeft = 0;
		            if(this.velx > MAX_VEL_X) {
		                this.velx = MAX_VEL_X;
		            }
		        } else if(BUTTON_LEFT) {
		            this.velx -= this.Xspeed;
					goingLeft = 1;
					if(this.velx < -MAX_VEL_X) {
					    this.velx = -MAX_VEL_X;
					}
		        }
		    }
		    
		    if(jumpEnabled == true && jumpCount == 0 && jumpPressed == false) { // if we're allowed to jump
	            if (BUTTON_SPACE) {
					// -speed breaks the moving platform buffer s well as still platforms.
					effectsChannel = jumpSound.play(0);  // play it, looping 100 times
					this.y -= gravity;
					this.vely = -jumpVelocity;
					jumpCount++;
					jumpPressed = true;
				}
	        }
	        
	        if(shootEnabled && hatAvailable) {
	            if(BUTTON_SHIFT) {
	                if(hatAvailable) {
	                   throwHat(); 
	                }
	            }
	        }
	        
	        if(BUTTON_SPACE) {
	            jumpPressed = true;
	        } else {
	            jumpPressed = false;
	        }
		}

	    private function throwHat() {
	        throwSound.play(0);
	        myMap.spawnActor(hat, this.x, this.y + 5);
	        hat.throwHat(goingLeft);
            hatAvailable = false;
	    }
	    
	    public function catchMe(object) {
	        if(!hatAvailable) {
	            myMap.removeFromMap(object);
    	        hatAvailable = true;
	        }
	    }
	    
	    override public function notify(subject:*):void {
	        if(subject is KeyMap) {
	            
	        } else if(checkCollision(subject)) {
		        if(subject is Actor)
		            subject.collide(this);
		    }
		}
		
		override public function collide(observer, ...args) {
		    if(observer is Cloud || observer is FountainPlatform) {  // if we're a cloud or a fountain
		        if(checkTop(observer) || observer == stuckTo) { // if we just collided with the top of it
		            land(observer); // land on it
		        }
		    } else if(observer is Block) {
                if(checkRight(observer)) {  // if we hit the right edge of the block
	                this.x = (observer.x + observer.width) - collide_left; // set us to there
	            } else if(checkLeft(observer)) { // if we hit the left edge of the block
	                this.x = observer.x - collide_right; // stop us there
	            } else if(myAction == FALL) { // if we just fell and collided
    	             land(observer); // land us on the top
	            } else if(observer == stuckTo) { // otherwise, if we're colliding with the thing we're stuck to
	                land(observer); // continue to follow it
	            }
		    } else if(observer is KillBlock) { // otherwise, if we're hitting a KillBlock
		        scoreboard.setHP(0); // ... kill us
		        trace("killblock collision!");
		    }
		} 
		
		override public function setAnimation(status) {
			switch(myAction) {
		        case WALK:
		            setLoop(0, 1, 4, 1, 1, 5);
		            break;
		        case JUMP:
		            setLoop(2, 1, 1, 1, 0, 5);
		            break;
		        case STAND:
		            setLoop(0, 5, 5, 5, 0, 5);
		            break;
		        case FALL:
		            setLoop(2, 1, 1, 1, 0, 5);
		            break;
		        case DUCK:
		            setLoop(4, 0, 1, 1, 1, 5);
		            break;
		        case THROW:
		            setLoop(6, 0, 1, 1, 1, 5);
		            break;
		        case DIE:
		            setLoop(8, 1, 0, 0, 0, 5);
		            trace("Death animation!");
		            break;
		    }
		}
		
		override public function killMe():void {
		    if(myStatus != 'DYING') { // if killMe's been issued, and i'm not yet dying
		        setLoop(8, 0, 0, 0, 0, 5); // set my dying animation
	            myStatus = 'DYING'; // set my status to dying
	            this.vely = -10; // and begin my death jump
	        }
		    if(frameCount >= frameDelay) { // if we're good on framecount
		        applyPhysics(); // apply physics for my fall
		        this.y += vely; // move me
		        animate(); // animate me
		        if(this.y > 240) { // and if i'm off the screen
		            myStatus = 'DEAD'; // i'm dead
		        }
		    } else { // otherwise
		        frameCount++; // increase the framecount
		    }
		}
		
	}
}
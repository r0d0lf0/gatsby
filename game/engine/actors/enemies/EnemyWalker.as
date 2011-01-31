﻿package engine.actors.enemies {        import engine.actors.geoms.*;    import engine.actors.player.Hero;    import engine.actors.Walker;    import engine.ISubject;    import engine.Scoreboard;	import engine.actors.ActorScore;        public class EnemyWalker extends Walker {                public var damage:Number = 1;                protected var walkDir:int = -1;        protected var groundCollide:Boolean;	protected var deathFrame:Number = 2;                protected var dieSound = new enemy_die();                protected var platformJump = false;                public function EnemyWalker() {		    trace("enemyWalker");		    points = 100;		    frameDelay = 1;        }                override public function collide(observer, ...args) {		    if(observer is Cloud || observer is FountainPlatform) {  // if we're a cloud or a fountain		        if(checkTop(observer) || observer == stuckTo) { // if we just collided with the top of it		            land(observer); // land on it		        }		    } else if(observer is Block) {				if(observer == stuckTo) { // otherwise, if we're colliding with the thing we're stuck to	                land(observer); // continue to follow it	            } else if(checkRight(observer)) {  // if we hit the right edge of the block	                this.x = (observer.x + observer.width) - collide_left_ground; // set us to there	                reverseDirection();	            } else if(checkLeft(observer)) { // if we hit the left edge of the block	                this.x = observer.x - collide_right_ground; // stop us there	                reverseDirection();	            } else if(myAction == FALL) { // if we just fell and collided    	             land(observer); // land us on the top	            }		    } else if(observer is Hero && !deadFlag) {		        observer.receiveDamage(this); // otherwise, if we've hit the hero, make him regret it		    }		}				public function reverseDirection() {		    velx *= -1;  // invert our velocity		    goingLeft = goingLeft == 0; // invert our going left flag		    //animate();		}                override public function update():void {            if(HP) {                moveMe();                checkDeath();    		    if(deadFlag) {				   notifyObservers();    		       if(this.y > 240) {                       myMap.removeFromMap(this);    		       } else {    		           setLoop(0, deathFrame, deathFrame, deathFrame, 0);    		       }                }            } else {                killMe();            }		}				override public function updateStatus():void {	        newAction = STAND; // by default, we're standing	        	        if(standFlag) { // if we're standing on something	            if(!stuckTo.checkGroundCollision(this)) { // and we're not colliding with it anymore	                if(platformJump) { // if we're allowed to leave platforms	                    depart(stuckTo); // depart whatever platform we were on	                } else {	                    reverseDirection();	                    land(stuckTo); // reland on the previous platform					}	            } else if(velx == 0) { // otherwise, if we're not moving	                newAction = STAND; // we're standing	            } else { // otherwise, we're walking	                newAction = WALK;	            }	        } else if(vely < 0) { // if we're going up	            newAction = JUMP; // we're jumping	        } else if(vely > 0) { // if we're going down	            newAction = FALL; // we're falling	        } else { // otherwise, we just peaked in a jump	            newAction = FALL; // now we're falling	        }	                    if(newAction != prevAction) {                setAction(newAction);                setAnimation(newAction);            }            prevAction = newAction;	    }				override public function applyPhysics():void {		    // velocitize y (gravity)			if (this.vely < MAX_VEL_Y) {			    this.vely += this.gravity;            }						// check map bounds			if(this.x < 0) {			    this.x = 0;			}		}				public function checkDeath():Boolean {            if(HP <= 0 && !deadFlag) { // if we have no health, and aren't already dead		        deadFlag = true; // then we're dead		        dieSound.play(0); // play our death sound		        scoreboard.addToScore(this, points); // and give the hero our points		        return true;		    }		    return false; // otherwise return false        }    }    }
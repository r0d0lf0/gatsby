﻿package engine{
    
    import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import engine.*;
	import engine.actors.*;
	//import engine.assetPrototypes.*;
    
    // this is the new Game class i'm proposing, developing separately from Game for
    // now for testing purposes
    public class NewGame extends MovieClip {
        
        private var current_level = 0;
        private var hero:Hero;
        private var game_sequence:Array = new Array('StartScreen', 'Level1');
        private var ldr;
        private var assets:Array = new Array();
       // private var asset_factory:AssetFactory;
        private var game_engine:GameEngine;
        private var scoreboard:Scoreboard;

        public function NewGame(ldr:*=null) {
			this.ldr = ldr;  // this is a reference back to the root class
			//find where in flash spacetime are we
			if (stage != null) {
				buildEnviron();
			} else {
				addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			}
          
        }
        
        private function addedToStage(evt) {
            removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
            buildEnviron();
        }
        
        private function buildEnviron() {
          // set our globals
          // create our tools
          hero = new Hero();
          //asset_factory = new AssetFactory(this, hero);
          scoreboard = new Scoreboard();

          
          // have the asset factory instantiate everything we need
          // NOTE: this could be optimized later, no reason we need these all
          // instantiated now, these could just get built on the fly
          for(var i=0;i<game_sequence.length;i++) {
            //assets.push(asset_factory.createAsset(game_sequence[i]));
          }
          
          // create a game engine with all our new assets and our new hero
          game_engine = new GameEngine(hero, assets, this);
          addChild(game_engine); // add our game engine to the stage*/
          start();
        }
        
        public function start() {
            // let your foot off the clutch and let onEnterFrame update() the GameEngine
            addEventListener(Event.ENTER_FRAME, game_engine.update);  // pass onEnterFrame messages to the engine
            trace("Here we go.");
        }
        
        public function update() {
            
        }
        
        public function reset() {
            buildEnviron();
        }
        
    }
    
}
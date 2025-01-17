package;

import flixel.graphics.FlxGraphic;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.MEMORY;
import openfl.display.COINS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import lime.app.Application;
import states.TitleState;
//import objects.FPSBG;
//crash handler stuff
#if CRASH_HANDLER
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end

import flixel.FlxSprite;
import flixel.FlxObject;

class Main extends Sprite
{
	var game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: TitleState, // initial game state
		zoom: -1.0, // game state bounds
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var fpsVar:FPS;
	public static var memoryVar:MEMORY;
	public static var coinVar:COINS;
	public static var fpsBG:Sprite;
	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

    SUtil.gameCrashCheck();
		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0)
		{
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}
	    SUtil.doTheCheck();

		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call)); #end
		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();
	
		#if mobile
		addChild(new FlxGame(1280, 720, TitleState, 60, 60, true, false));
		#else
		addChild(new FlxGame(game.width, game.height, game.initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
		#end

	
		//{x: ClientPrefs.data.fpsX, y: ClientPrefs.data.fpsY}
		if (ClientPrefs.data.noneAnimations) {
			coinVar = new COINS(ClientPrefs.data.fpsX, ClientPrefs.data.fpsY, 0xFFFFFF);
			addChild(coinVar);
			memoryVar = new MEMORY(ClientPrefs.data.fpsX, ClientPrefs.data.fpsY, 0xFFFFFF);
			addChild(memoryVar);
			fpsVar = new FPS(ClientPrefs.data.fpsX, ClientPrefs.data.fpsY, 0xFFFFFF);
			addChild(fpsVar);
			Lib.current.stage.align = "tl";
			Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
			} else {
			coinVar = new COINS(-60, ClientPrefs.data.fpsY, 0xFFFFFF);
			coinVar.alpha = 0;
			addChild(coinVar);
			memoryVar = new MEMORY(-60, ClientPrefs.data.fpsY, 0xFFFFFF);
			memoryVar.alpha = 0;
			addChild(memoryVar);
			fpsVar = new FPS(-60, ClientPrefs.data.fpsY, 0xFFFFFF);
			fpsVar.alpha = 0;
			addChild(fpsVar);
			Lib.current.stage.align = "tl";
			Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
			}
		/*
		fpsBG = new FPSBG(10, 3, 'test');
		addChild(fpsBG);
		if(fpsBG != null) {
			fpsBG.visible = ClientPrefs.data.showFPS;
		}
		
        var myOtherClass = new FPSBG(10, 3, 'test');
        myOtherClass.addImage(fpsBG);
        addChild(fpsBG);
		*/
		
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
		
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end

		#if desktop
		DiscordClient.start();
		#end

		// shader coords fix
		FlxG.signals.gameResized.add(function (w, h) {
		     if (FlxG.cameras != null) {
			   for (cam in FlxG.cameras.list) {
				@:privateAccess
				if (cam != null && cam._filters != null)
					resetSpriteCache(cam.flashSprite);
			   }
		     }

		     if (FlxG.game != null)
			 resetSpriteCache(FlxG.game);
		});
	}

	static function resetSpriteCache(sprite:Sprite):Void {
		@:privateAccess {
		        sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "EndingAndroid_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nReport this bug on Discord\n\n> Your Token: Your device cannot be added to the server";

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		#if desktop
		DiscordClient.shutdown();
		#end
		Sys.exit(1);
	}
	#end
}
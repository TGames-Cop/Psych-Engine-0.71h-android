package states;

import backend.WeekData;
import backend.Highscore;


import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import tjson.TJSON as Json;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

import flixel.effects.FlxFlicker;

import shaders.ColorSwap;

import states.StoryMenuState;
import states.OutdatedState;
import states.MainMenuState;

#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end

typedef TitleData =
{
	titlex:Float,
	titley:Float,
	backgroundSprite:String,
	bpm:Int
}

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;
	public var ignoreWarnings:Bool = false;

	var selected:Bool = false;

	public var notSkip:Bool = false;

	public static var urlUpdate:String = '';

	var textTitle:String;

	//var timetran:Int = ClientPrefs.data.timeTransaction;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var phantomSr:FlxSprite;

	var saturated:ColorSwap;
	//var complit:GlitchEffect;

	var titleTxt:FlxText;
	var titleTxt2:FlxText;

	var TextMove:FlxTimer;
	
	var textShow:String;
	
	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var curWacky:Array<String> = [];

	var curThonny:Array<String> = [];

	public static var editorresult:Bool;

	var wackyImage:FlxSprite;

	#if TITLE_SCREEN_EASTER_EGG
	var easterEggKeys:Array<String> = [
		'SHADOW', 'RIVER', 'SHUBS', 'BBPANZU'
	];
	var allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	var easterEggKeysBuffer:String = '';
	#end

	//var mustUpdate:Bool = false;
	public static var UpdateEC:Bool = false;

	//public static var fpsalpha:Float = 0;

	var TitleTxt:String;
	var coolText:FlxText;

	var titleJSON:TitleData;
	var Bit:Bool;

	var indexCurret:Int = 0;

	public static var updateVersion:String = '';
	public static var updateVersionEC:String = '';
	public static var editorverification:String = 'disabled';
	public static var editorpermiss:String = '';
	public static var releasevideolink:String = '';
	public static var pathVersionOnline:String = '';
	public static var pathVersionOnlineM:Bool = false;

	public function onAlpha(Timer:FlxTimer):Void {
		FlxTween.tween(logoBl, {"scale.x": 1, "scale.y": 1}, 0.1, {
			onComplete: function (twn:FlxTween) {
				FlxTween.tween(logoBl, {"scale.x": 0.9, "scale.y": 0.9}, 0.1);
		}});
	}

	public function onText(Timer:FlxTimer):Void {
		FlxTween.tween(titleTxt, {alpha: 0}, 2, {
			onComplete: function (twn:FlxTween) {
				FlxTween.tween(titleTxt, {alpha: 1}, 2);
			}
		});
	}

	function onGenerate(Timer:FlxTimer):Void {
        if (indexCurret < textShow.length) {
            titleTxt.text += textShow.charAt(indexCurret);
            indexCurret++;
        }

		titleTxt.text = textShow;
    }

	override public function create():Void
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();
		
		//https://github.com/beihu235/AndroidDialogs
		#if android
		var lang:String = '';
		if (DeviceLanguage.getLang() == 'zh') 
		lang = 'psych0.71h 安卓端口测试\nb站-北狐丶逐梦移植\n禁止上传到任何资源网站';
		else
		lang = 'Ending Corruption V2.0\nPort by ThonnyDev - TGames | CamelyGamer';
		AndroidDialogsExtend.OpenToast(lang, 1);
		#end
		
		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		removeVirtualPad();
		noCheckPress();
		#end

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		curWacky = FlxG.random.getObject(getIntroTextShit());

		super.create();

		FlxG.save.bind('funkin', CoolUtil.getSavePath());

		ClientPrefs.loadPrefs();

		#if CHECK_FOR_UPDATES
		if (ClientPrefs.data.Welcome == true && !ClientPrefs.data.noneNet) {
			trace('cheking for release video');
			var htss = new haxe.Http("https://raw.githubusercontent.com/ThonnyDevYT/FNFVersion/main/Link_video.txt");

			htss.onData = function (data:String)
				{
					releasevideolink = data.split("*")[0].trim();
					trace("Video Saved: [" + releasevideolink + "]");
				}

				htss.onError = function (error) {
					trace('error: $error');
					trace('Release Video. Cargara el Guardado en El juego');
					releasevideolink = "https://www.youtube.com/watch?v=M67O8wIE-2U";
				}

				htss.request();
		}

		if (ClientPrefs.data.Welcome && !ClientPrefs.data.noneNet) {
			trace('cheking for Path Version');
			var hpss = new haxe.Http("https://raw.githubusercontent.com/ThonnyDevYT/FNFVersion/main/pathVersion.txt");

			hpss.onData = function (data:String)
				{
					pathVersionOnline = data.split("*")[0].trim();
					trace("Path Version: [" + pathVersionOnline + "]");

					if (pathVersionOnline != ClientPrefs.data.pathVersion) {
						pathVersionOnlineM = true;
					}
				}

				hpss.onError = function (error) {
					trace('error: $error');
					trace('Paths Version Error. No cargara el parche');
					pathVersionOnlineM = false;
				}

				hpss.request();
		}

		if (ClientPrefs.data.Welcome == true && !ClientPrefs.data.noneNet) {
			trace('cheking for editors permiss');
			var htsp = new haxe.Http("https://raw.githubusercontent.com/ThonnyDevYT/FNFVersion/main/Editor-Permiss.txt");

			htsp.onData = function (data:String)
				{
					editorpermiss = data.split("!")[0].trim();
					var curVerificator:String = editorverification.trim();
					trace('Editor Permiss Online is in  [' + editorpermiss + "]");
					if (editorpermiss != curVerificator) {
						trace('enabled!!');
						editorresult = true;
					}
					if (editorpermiss == curVerificator) {
						trace('disabled!!');
						editorresult = false;
					}
				}

				htsp.onError = function (error) {
					trace('error: $error');
					trace('Editor Permiss. Desabilitado por seguridad');
					editorresult = false;
				}

				htsp.request();
		}
		if (ClientPrefs.data.noneNet) {
			editorresult = false;
			releasevideolink = "https://www.youtube.com/watch?v=M67O8wIE-2U";

			trace('Sin permisos para conexion a Internet');
		}

		if(ClientPrefs.data.Welcome == true && !ClientPrefs.data.noneNet) {
			trace('checking for update');
			var htps = new haxe.Http("https://raw.githubusercontent.com/ThonnyDevYT/FNFVersion/main/GitVersion.txt");

			htps.onData = function (data:String)
			{
				updateVersionEC = data.split('\n')[0].trim();
				var curVersionEC:String = ClientPrefs.data.endingCorruprion.trim();
				trace('version online: ' + updateVersionEC + ', your version: ' + curVersionEC);
				if(updateVersionEC != curVersionEC) {
					trace('versions arebt matching!');
					UpdateEC = true;
				}
			}

			htps.onError = function (error) {
				trace('error: $error');
			}

			htps.request();
		}
		#end

		Highscore.load();

		// IGNORE THIS!!!
		titleJSON = Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			if (initialized)
				startIntro();
			else
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					startIntro();
				});
			}
		}
		#end
	}

	var logoBl:FlxSprite;
	var swagShader:ColorSwap = null;
	var FadeTimer:FlxTimer;
	var TextTime:FlxTimer;
	var errorTimer:FlxTimer;

	function startIntro()
	{
		if (!initialized)
		{
			if(FlxG.sound.music == null) {
				if (ClientPrefs.data.music == 'Disabled') FlxG.sound.playMusic(Paths.music('none'), 1.2);

				if (ClientPrefs.data.music == 'Hallucination') FlxG.sound.playMusic(Paths.music('Hallucination'), 1.2);

				if (ClientPrefs.data.music == 'TerminalMusic') FlxG.sound.playMusic(Paths.music('TerminalMusic'), 1.2);
		}
			if(Main.memoryVar != null && !ClientPrefs.data.noneAnimations) {
				FlxTween.tween(Main.memoryVar, {x: 10}, 3);
				FlxTween.tween(Main.memoryVar, {alpha: 1}, 2.5);
			}
			if(Main.coinVar != null && !ClientPrefs.data.noneAnimations) {
				FlxTween.tween(Main.coinVar, {x: 10}, 3);
				FlxTween.tween(Main.coinVar, {alpha: 1}, 2.5);
			}
			if(Main.fpsVar != null && !ClientPrefs.data.noneAnimations) {
				FlxTween.tween(Main.fpsVar, {x: 10}, 3);
				FlxTween.tween(Main.fpsVar, {alpha: 1}, 2.5);
			}
			Main.memoryVar.visible = ClientPrefs.data.showFPS;
			Main.fpsVar.visible = ClientPrefs.data.showFPS;
			Main.coinVar.visible = ClientPrefs.data.showFPS;
		}

		if (ClientPrefs.data.username == 'User') {
			ClientPrefs.data.username = 'User' + FlxG.random.int(0, 100) + FlxG.random.int(0, 100) + FlxG.random.int(0, 100);
			ClientPrefs.saveSettings();
			ClientPrefs.loadPrefs();
		}

		Conductor.bpm = titleJSON.bpm;
		persistentUpdate = true;

		var bg:FlxSprite;
		//bg.antialiasing = ClientPrefs.data.antialiasing; //Esto es inecesario ya que creo una imagen de Color Negro no veo que tengo que suavizar
		bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		logoBl = new FlxSprite().loadGraphic(Paths.image('corruption-logo'));
		logoBl.antialiasing = ClientPrefs.data.antialiasing;
		logoBl.updateHitbox();
		logoBl.screenCenter();
		logoBl.alpha = 1;
		logoBl.scale.x = 0.9;
		logoBl.scale.y = 0.9;

		if (ClientPrefs.data.language == 'Spanish') {
			titleTxt = new FlxText(0, 650, FlxG.width, 48);
			textShow = "Presiona la Pantalla para Continuar";
		}
		if (ClientPrefs.data.language == 'Inglish') {
			titleTxt = new FlxText(0, 650, FlxG.width, 48);
			textShow = "Press the Screen to Continue";
		}
		if (ClientPrefs.data.language == 'Portuguese') {
			titleTxt = new FlxText(0, 650, FlxG.width, 48);
			textShow = "Pressione 'Enter' para Continuar";
		}
		titleTxt.setFormat(Paths.font("vnd.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleTxt.visible = true;
		titleTxt.screenCenter(X);


		titleTxt2 = new FlxText(0, 650, FlxG.width, "", 48);
		titleTxt2.setFormat(Paths.font("vnd.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		titleTxt2.visible = false;
		titleTxt2.screenCenter(X);

		if (ClientPrefs.data.language == 'Spanish') titleTxt2.text = "Iniciando";

		if (ClientPrefs.data.language == 'Inglish') titleTxt2.text = "Starting";

		if (ClientPrefs.data.language == 'Portuguese') titleTxt2.text = "Iniciando";

		//add(gfDance);
		add(logoBl);
		add(titleTxt);
		add(titleTxt2);

		if(swagShader != null)
			{
				logoBl.shader = swagShader.shader;
			}

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.antialiasing = ClientPrefs.data.antialiasing;
		logo.screenCenter();
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		phantomSr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('phantom_fear_logo'));
		add(phantomSr);
		phantomSr.visible = false;
		phantomSr.setGraphicSize(Std.int(phantomSr.width * 0.8));
		phantomSr.updateHitbox();
		phantomSr.screenCenter(X);
		phantomSr.antialiasing = ClientPrefs.data.antialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		if (!ClientPrefs.data.noneAnimations) {
			FadeTimer = new FlxTimer();
			FadeTimer.start(0.8, onAlpha, 0);
		}

		if (!ClientPrefs.data.noneAnimations) {
			TextTime = new FlxTimer();
			TextTime.start(4, onText, 0);
		}
		if (ClientPrefs.data.noneAnimations) {
			titleTxt.alpha = 1;
		}

		#if android
			AndroidDialogsExtend.OpenToast("No pudimos comprobar si tienes pantallas curvas\nSe activaran las opciones de Ajuste por Emergencia", 3);
		#end

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;
	
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if(pressedEnter)
			{
				titleTxt.visible = false;
				titleTxt2.visible = true;
				selected = true;

					FlxG.sound.play(Paths.sound('confirmMenu'), 0.2);

					transitioning = true;

					FlxG.cameras.fade(FlxColor.BLACK, ClientPrefs.data.timetrans + 2, false);
					FlxTween.tween(titleTxt2, {alpha: 0}, ClientPrefs.data.timetrans + 3);
					FlxFlicker.flicker(titleTxt2, ClientPrefs.data.timetrans + 3, 0.2, true, true);
					if (FlxG.sound.music != null) FlxG.sound.music.fadeOut(ClientPrefs.data.timetrans, 1);
					FlxTween.tween(logoBl, {alpha: 0}, ClientPrefs.data.timetrans + 2, {
						onComplete: function (twn:FlxTween) {
	
							new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									//if (UpdateEC == true) {
									//	MainMenuState.outdate = false;
									//}
										MusicBeatState.switchState(new MainMenuState());
										//MusicBeatState.switchState(new ActAvailableState());
									closedState = true;
								});
						}
					});
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0, ?Color:FlxColor = FlxColor.BLACK)
	{
		if(textGroup != null && credGroup != null) {
			coolText = new FlxText(0, 0, 0, text, 64);
			coolText.screenCenter(X);
			coolText.setFormat("vcx.ttf", 64, Color, CENTER, OUTLINE_FAST, FlxColor.WHITE);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
				if (ClientPrefs.data.music == 'Disabled') FlxG.sound.playMusic(Paths.music('none'), 0);

				if (ClientPrefs.data.music == 'Hallucination')	FlxG.sound.playMusic(Paths.music('Hallucination'), 0);

				if (ClientPrefs.data.music == 'TerminalMusic') FlxG.sound.playMusic(Paths.music('TerminalMusic'), 0);
				
				if (ClientPrefs.data.musicState != 'disabled')	FlxG.sound.music.fadeIn(2, 0, 1.2);
				case 2:
					addMoreText('Ending');
				case 3:
					addMoreText('Corruption');
				case 4:
					addMoreText(ClientPrefs.data.endingCorruprion, 0, FlxColor.RED);
				case 5:
					deleteCoolText();
				case 6:
					FlxG.cameras.fade(FlxColor.BLACK, 0.4, true);
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
		{
			if (!skippedIntro)
			{
				FlxG.cameras.flash(FlxColor.BLACK, 2.5);
					remove(phantomSr);
					remove(credGroup);
				if (ClientPrefs.data.recordoptimization == 'enabled') add(new Notification('Optimizacion de Grabacion..', "la optimizacio de Grabacion se encuentra Activada Actualmente", 0, null, 1));
				skippedIntro = true;
				notSkip = true;
	
				TextMove = new FlxTimer();
				TextMove.start(0.09, onGenerate, 0);
			}
		}
}

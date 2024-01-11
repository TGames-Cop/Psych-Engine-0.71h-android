package objects;

import cpp.Function;
import flixel.FlxG;

class Notification extends FlxSpriteGroup {
	public var onFinish:Void->Void = null;

	public static var finishMode:String;

	//Files
	var achievementIcon:FlxSprite;
	var achievementBG:FlxSprite;
	var notiBG:FlxSprite;

	//Texts
	var notiName:FlxText;
	var notiText:FlxText;

	private function convText(text:String) {

		//Dividir el texto en palabras
		var palabras:Array<String> = text.split(" ");

		//Convertir cada palabra a mayúsculas
		for (i in 0...palabras.length) {
			palabras[i] = palabras[i].toUpperCase();
		}

		//Unir las palabras de nuevo en un solo texto
		var textEnMayusculas:String = palabras.join(" ");

		return textEnMayusculas;
	}

	public function new(Title:String, description:String, ?type:Int, ?camera:FlxCamera, ?Duration:Float, ?aumentwidth:Float = 0, ?aumentheight:Float = 0)
	{
		super(x, y);
		ClientPrefs.saveSettings();

		achievementBG = new FlxSprite(-990, 0).makeGraphic(420, 120, FlxColor.BLACK);
		achievementBG.scrollFactor.set();

		description = convText(description);

		if (PlayState.stageUI != "pixel") {
		notiBG = new FlxSprite(-1000, -20).loadGraphic(Paths.image('notification_box'));
		notiBG.antialiasing = ClientPrefs.data.antialiasing;
		if (aumentheight != 0) notiBG.y += aumentheight;
		notiBG.scrollFactor.set();
		

		var Gx:Float = achievementBG.x + 10;
		var Gy:Float = achievementBG.y + 10;

		achievementIcon = new FlxSprite(Gx, Gy);
		achievementIcon.setGraphicSize(Std.int(achievementIcon.width * (2 / 3)));
		achievementIcon.updateHitbox();

		notiName = new FlxText(achievementIcon.x + achievementIcon.width + 10, achievementIcon.y + 20, 280, Title + "", 10);
		notiName.setFormat(Paths.font("Paintlinear"), 10, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		notiName.scrollFactor.set();
		notiName.antialiasing = ClientPrefs.data.antialiasing;
		notiName.setGraphicSize(Std.int(notiBG.width * (2 / 3)));

		notiText = new FlxText(notiName.x, notiName.y + 32, 280, "" + description, 16);
		notiText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE);
		notiText.scrollFactor.set();
		notiText.antialiasing = ClientPrefs.data.antialiasing;
		notiText.setGraphicSize(Std.int(notiBG.width * (2 / 3)));
		}


		/////////////////////////



		if (PlayState.stageUI == "pixel") {
			notiBG = new FlxSprite(-1000, -20).loadGraphic(Paths.image('pixelUI/notification_box_Pixel'));
			//notiBG.setGraphicSize(420 + aumentwidth, 130 + aumentheight);
			notiBG.antialiasing = false;
			if (aumentheight != 0) notiBG.y += aumentheight;
			notiBG.scrollFactor.set();

			var Gx:Float = achievementBG.x + 10;
			var Gy:Float = achievementBG.y + 10;
	
			achievementIcon = new FlxSprite(Gx, Gy);
			achievementIcon.setGraphicSize(Std.int(achievementIcon.width * (2 / 3)));
			achievementIcon.updateHitbox();
	
			notiName = new FlxText(achievementIcon.x + achievementIcon.width + 10, achievementIcon.y + 20, 280, Title + "", 5);
			notiName.setFormat(Paths.font("pixel.otf"), 5, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
			notiName.scrollFactor.set();
			notiName.antialiasing = false;
			notiName.setGraphicSize(Std.int(notiBG.width * (2 / 3)));
	
			notiText = new FlxText(notiName.x, notiName.y + 32, 280, "" + description, 11);
			notiText.setFormat(Paths.font("pixel.otf"), 11, FlxColor.WHITE, LEFT, OUTLINE);
			notiText.scrollFactor.set();
			notiText.antialiasing = false;
			notiText.setGraphicSize(Std.int(notiBG.width * (2 / 3)));
		}

		add(achievementBG);
		add(notiBG);
		add(notiName);
		add(notiText);
		this.visible = ClientPrefs.data.notivisible;

		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if(camera != null) {
			cam = [camera];
		}
		alpha = 0;
		this.cameras = cam;

		animNoti();
	}

	public function animNoti() {
		finishMode = "";

		FlxTween.tween(notiName, {alpha: 1}, 0.1, {onComplete: function (twn:FlxTween) {
			FlxTween.tween(notiName, {x: 40, y: 30}, 1);
		}});
		FlxTween.tween(notiBG, {alpha: 1}, 0.1, {onComplete: function (twn:FlxTween) {
			FlxTween.tween(notiBG, {x: -50, y: -20}, 1);
		}});
		FlxTween.tween(achievementBG, {alpha: 1}, 0.1, {onComplete: function (twn:FlxTween) {
			FlxTween.tween(achievementBG, {x: -50, y: -210}, 1);
		}});

		FlxTween.tween(notiText, {alpha: 1}, 0.1, {onComplete: function (twn:FlxTween) {
			if (ClientPrefs.data.notivisible == true) {
				FlxG.sound.play(Paths.sound('notificacion-1'));
			}
			FlxTween.tween(notiText, {x: 40, y: 50}, 1, {
				onComplete: function(twn:FlxTween) {
					new FlxTimer().start(3.5, function(tmr:FlxTimer) {
						fadeOut();
					});
				}
			});
		}});
	}

	public function fadeOut() {
		FlxTween.tween(notiName, {alpha: 0}, 1.4, {
			type: ONESHOT
		});
		FlxTween.tween(notiBG, {alpha: 0}, 1.4, {
			type: ONESHOT
		});
		FlxTween.tween(achievementBG, {alpha: 0}, 1.4, {
			type: ONESHOT
		});
		FlxTween.tween(notiText, {alpha: 0}, 1.5, {
			type: ONESHOT,
			onComplete: function (twn:FlxTween) {
				finishMode = null;
				this.destroy();
			}
		});
	}
}
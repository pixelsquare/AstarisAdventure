package astarisAdventure;

import astarisAdventure.utils.AssetName;
import flambe.asset.AssetPack;
import flambe.asset.Manifest;
import flambe.display.FillSprite;
import flambe.display.Font;
import flambe.display.TextSprite;
import flambe.Entity;
import flambe.input.PointerEvent;
import flambe.System;
import flambe.util.SignalConnection;


class Main
{
	private static var assetPack: AssetPack;
	private static var titleFont: Font;
		
	private static var titleScreenEntity: Entity;
	private static var mainGameScreenEntity: Entity;
	
	private static var headerBG: FillSprite;
	private static var headerText: TextSprite;
	
	private static var adventureEngine: AdventureEngine;
	
	private static var titleScreenSignalConnection: SignalConnection;
	
	private static inline var DEFAULT_BACKGROUND_TITLE_HEIGHT = 100;
	
	private static inline var DEFAULT_BACKGROUND_HEIGHT = 50;
	
    private static function main ()
    {
        // Wind up all platform-specific stuff
        System.init();

        // Load up the compiled pack in the assets directory named "bootstrap"
        var manifest = Manifest.fromAssets("bootstrap");
        var loader = System.loadAssetPack(manifest);
        loader.get(onSuccess);
    }

    private static function onSuccess (pack :AssetPack)
    {
        // Add a solid color background
        var background = new FillSprite(0x202020, System.stage.width, System.stage.height);
        System.root.addChild(new Entity().add(background));

        // Add a plane that moves along the screen
        //var plane = new ImageSprite(pack.getTexture("plane"));
        //plane.x._ = 30;
        //plane.y.animateTo(200, 6);
        //System.root.addChild(new Entity().add(plane));
		
		assetPack = pack;
		titleFont = new Font(assetPack, AssetName.FONT_HAZEL_GRACE_80);
		
		createTitleScreen();
		createMainGameScreen();
		
		showTitleScreen();
    }
	
	private static function createTitleScreen() {
		titleScreenEntity = new Entity();
		
		var titleEntity: Entity = new Entity();
		var titleBG: FillSprite = new FillSprite(0xFFFFFF, System.stage.width, DEFAULT_BACKGROUND_TITLE_HEIGHT);
		titleBG.y._ = System.stage.height / 2 - (titleBG.height._ / 2);
		titleEntity.add(titleBG);
		
		var astarisText: TextSprite = new TextSprite(titleFont, "Astaris");
		astarisText.centerAnchor();
		astarisText.x._ = System.stage.width / 2 - (astarisText.getNaturalWidth() * 0.25);
		astarisText.y._ = titleBG.height._ / 2;
		astarisText.setLetterSpacing(15);
		titleEntity.addChild(new Entity().add(astarisText));		
		
		var adventureText: TextSprite = new TextSprite(new Font(assetPack, AssetName.FONT_BETTY_20), "Choose your own Adventure");
		adventureText.centerAnchor();
		adventureText.x._ = System.stage.width / 2;
		adventureText.y._ = titleBG.height._ * 0.8;
		titleEntity.addChild(new Entity().add(adventureText));
		
		var clickAnywhereText: TextSprite = new TextSprite(new Font(assetPack, AssetName.FONT_BETTY_32), "Click anywhere to Start!");
		clickAnywhereText.centerAnchor();
		clickAnywhereText.x._ = System.stage.width / 2;
		clickAnywhereText.y._ = System.stage.height * 0.7;
		titleScreenEntity.addChild(new Entity().add(clickAnywhereText));
		
		titleScreenEntity.addChild(titleEntity);
	}
	
	private static function createMainGameScreen() {
		mainGameScreenEntity = new Entity();
		
		var astarisFooterEntity: Entity = new Entity();
		var astarisFooterBG: FillSprite = new FillSprite(0xFFFFFF, System.stage.width, 30);
		astarisFooterBG.y._ = System.stage.height * 0.95 - (astarisFooterBG.height._ / 2);
		astarisFooterEntity.add(astarisFooterBG);
		
		var astarisText: TextSprite = new TextSprite(new Font(assetPack, AssetName.FONT_BETTY_20), "Astaris");
		astarisText.x._ = System.stage.width / 2;
		astarisText.y._ = astarisFooterBG.height._ / 2 - (astarisText.getNaturalHeight() / 2);
		astarisFooterEntity.addChild(new Entity().add(astarisText));
		
		mainGameScreenEntity.addChild(astarisFooterEntity);
		
		adventureEngine = new AdventureEngine();
		adventureEngine.Init(
			new Font(assetPack, AssetName.FONT_APPLE_GARAMOND_32), 
			new Font(assetPack, AssetName.FONT_APPLE_GARMOND_ITALIC_32),
			new Font(assetPack, AssetName.FONT_ARIAL_NARROW_20),
			assetPack.getFile(AssetName.XML_ATARIS_ADVENTURE)
		);
		
		adventureEngine.goToMenuBG.pointerUp.connect(function(event: PointerEvent) {
			showTitleScreen();
		});
		
		mainGameScreenEntity.add(adventureEngine);
	}
	
	private static function showTitleScreen() {			
		System.root.removeChild(mainGameScreenEntity);
		System.root.addChild(titleScreenEntity);
		
		titleScreenSignalConnection = System.pointer.down.connect(
		function(event: PointerEvent) {
			showMainGameScreen();
		}).once();
	}
	
	private static function showMainGameScreen() {
		adventureEngine.ResetStage();
		adventureEngine.SetupStage();
		
		System.root.removeChild(titleScreenEntity);
		System.root.addChild(mainGameScreenEntity);
	}
}

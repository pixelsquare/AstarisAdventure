package astarisAdventure;

import flambe.input.PointerEvent;
import flambe.script.Repeat;
import flambe.System;
import flambe.Component;
import flambe.display.FillSprite;
import flambe.display.Font;
import flambe.display.TextSprite;
import flambe.Entity;
import flambe.asset.File;
import flambe.math.FMath;
import haxe.xml.Fast;
import hxsl.PicoShaderInstance;

import flambe.script.Script;
import flambe.script.Sequence;
import flambe.script.CallFunction;
import flambe.script.AnimateBy;
import flambe.script.AnimateTo;
import flambe.script.MoveBy;
import flambe.script.MoveTo;
import flambe.script.Delay;

import astarisAdventure.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class AdventureEngine extends Component
{
	private var adventureEntity: Entity;
	private var textOptionsEntity: Entity;
	private var choicesEntity: Entity;
	
	private var xmlHeaderInfoEntity: Entity;
	private var xmlButtonInfoEntity: Entity;
	
	private var nextTextEntity: Entity;
	private var backTextEntity: Entity;
	
	private var nextTextBG: FillSprite;
	private var backTextBG: FillSprite;
	
	private var goToMenuEntity: Entity;
	
	private var xmlData: Xml;
	private var xmlFast: Fast;
	
	private var headerText: TextSprite;
	private var headerNameText: TextSprite;
	
	public var goToMenuBG(default, null): FillSprite;
	
	private var gameFont: Font;
	private var gameFontItalic: Font;
	private var gameFont_20: Font;
	
	private var mainNode: Fast;
	private var curNode: Fast;
	
	private var nodeTexts = [];
	private var nodeChoices = [];
	
	private var curTextIndx: Int;
	
	public function new() 
	{
		adventureEntity = new Entity();
		textOptionsEntity = new Entity();
		choicesEntity = new Entity();
		xmlHeaderInfoEntity = new Entity();
		xmlButtonInfoEntity = new Entity();
	}
	
	override public function onAdded() 
	{
		super.onAdded();
		owner.addChild(adventureEntity);
	}
	
	public function Init(font: Font, fontItalic: Font, font_20: Font, file: File): Void {
		gameFont = font;
		gameFontItalic = fontItalic;
		gameFont_20 = font_20;
		
		xmlData = Xml.parse(file.toString());
		xmlFast = new Fast(xmlData.firstElement());
		
		mainNode = xmlFast;
		curNode = Utils.GetNodeFrom(mainNode, "start");
		
		var headerEntity: Entity = new Entity();
		var headerBG: FillSprite = new FillSprite(0xFFFFFF, System.stage.width * 0.8, 200);
		headerBG.x._ = System.stage.width / 2 - (headerBG.width._ / 2);
		headerBG.y._ = System.stage.height * 0.3 - (headerBG.height._ / 2);
		headerEntity.add(headerBG);
		
		headerText = new TextSprite(gameFont, "");
		headerText.setXY(10, 10);
		headerText.setWrapWidth(500);
		headerEntity.addChild(new Entity().add(headerText));
		
		adventureEntity.addChild(headerEntity);
		
		nextTextEntity = new Entity();
		nextTextBG = new FillSprite(0xFFFFFF, System.stage.width * 0.1, 50);
		nextTextEntity.add(nextTextBG);
		
		var headerInfoEntity: Entity = new Entity();
		var headerInfoBG: FillSprite = new FillSprite(0xFFFF00, System.stage.width * 0.8, 20);
		
		var infoEntity: Entity = new Entity();
		var infoBG: FillSprite = new FillSprite(0xFFFF00, System.stage.width * 0.15, 20);
		infoBG.centerAnchor();
		infoBG.x._ = headerBG.x._ + (headerBG.getNaturalWidth() / 2);
		infoBG.y._ = headerBG.y._ + (headerBG.getNaturalHeight());
		infoEntity.add(infoBG);
			
		headerNameText = new TextSprite(gameFont_20, "Node: ");
		headerNameText.centerAnchor();
		headerNameText.x._ = infoBG.getNaturalWidth() / 2 - (headerNameText.getNaturalWidth() / 2);
		headerNameText.y._ += infoBG.getNaturalHeight() / 2;
		infoEntity.addChild(new Entity().add(headerNameText));
		
		xmlHeaderInfoEntity.addChild(infoEntity);
		
		var nextTextButton: TextSprite = new TextSprite(gameFontItalic, "Next");
		nextTextBG.width._ = nextTextButton.getNaturalWidth() + 15;
		nextTextBG.height._ = nextTextButton.getNaturalHeight() + 5;
		nextTextBG.x._ = System.stage.width * 0.9 - (nextTextBG.width._ / 2);
		nextTextBG.y._ = System.stage.height * 0.85 - (nextTextBG.height._ / 2);
		
		nextTextButton.x._ = nextTextBG.width._ / 2 - (nextTextButton.getNaturalWidth() / 2);
		nextTextButton.y._ = nextTextBG.height._ / 2 - (nextTextButton.getNaturalHeight() / 2);
		nextTextEntity.addChild(new Entity().add(nextTextButton));
		
		textOptionsEntity.addChild(nextTextEntity);
		
		backTextEntity = new Entity();
		backTextBG = new FillSprite(0xFFFFFF, System.stage.width * 0.1, 50);
		backTextEntity.add(backTextBG);
		
		var backTextButton: TextSprite = new TextSprite(gameFontItalic, "Back");
		backTextBG.width._ = backTextButton.getNaturalWidth() + 15;
		backTextBG.height._ = backTextButton.getNaturalHeight() + 5;
		backTextBG.x._ = System.stage.width * 0.1 - (backTextBG.width._ / 2);
		backTextBG.y._ = System.stage.height * 0.85 - (backTextBG.height._ / 2);
		
		backTextButton.x._ = backTextBG.width._ / 2 - (backTextButton.getNaturalWidth() / 2);
		backTextButton.y._ = backTextBG.height._ / 2 - (backTextButton.getNaturalHeight() / 2);
		backTextEntity.addChild(new Entity().add(backTextButton));
		
		textOptionsEntity.addChild(backTextEntity);
		
		adventureEntity.addChild(textOptionsEntity);
		
		goToMenuEntity = new Entity();
		goToMenuBG = new FillSprite(0xFFFFFF, System.stage.width * 0.1, 50);

		goToMenuEntity.add(goToMenuBG);
		
		var goToMenuText: TextSprite = new TextSprite(gameFontItalic, "Go To Menu");
		goToMenuBG.width._ = goToMenuText.getNaturalWidth() + 15;
		goToMenuBG.height._ = goToMenuText.getNaturalHeight() + 15;
		goToMenuBG.x._ = System.stage.width / 2 - (goToMenuBG.width._ / 2);
		goToMenuBG.y._ = System.stage.height * 0.7 - (goToMenuBG.height._ / 2);
		
		goToMenuText.x._ = goToMenuBG.width._ / 2 - (goToMenuText.getNaturalWidth() / 2);
		goToMenuText.y._ = goToMenuBG.height._ / 2 - (goToMenuText.getNaturalHeight() / 2);
		goToMenuEntity.addChild(new Entity().add(goToMenuText));
		
		
		SetupStage();
		
		headerBG.pointerUp.connect(function(event: PointerEvent) {
			if (curTextIndx == nodeTexts.length - 1) {
				ShowXmlInfo();
			}
			else {
				HideXmlInfo();
				adventureEntity.addChild(xmlHeaderInfoEntity);
			}
		});

		nextTextBG.pointerUp.connect(function(event: PointerEvent) {
			ShowNextText();
		});
		
		backTextBG.pointerUp.connect(function(event: PointerEvent) {
			ShowBackText();
		});
		
		goToMenuBG.pointerUp.connect(function(event: PointerEvent) {
			Utils.ConsoleLog("Go Back to Menu!");
		});
	}
	
	public function SetupStage(): Void {
		nodeTexts = [];
		nodeChoices = [];
		
		for (text in curNode.nodes.text) {
			nodeTexts.push( { nodeName: text.name, attName: "", value: text.innerData } );
		}
		
		for (choices in curNode.nodes.choices) {
			nodeChoices.push( { nodeName: choices.name, attName: choices.att.name, value: choices.innerData } );

		}
		
		curTextIndx = 0;
		SetHeaderTextDirty();
		ShowTextOptionsEntity();
		UpdateTextOptionsEntity();
		UpdateChoices();
		HideChoices();
		HideGoToMenu();
		HideXmlInfo();
	}
	
	public function ShowNextText(): Void {
		curTextIndx++;
		curTextIndx = FMath.clamp(curTextIndx, 0, nodeTexts.length - 1);
		//Utils.ConsoleLog(curTextIndx + "");
		
		// Show choices on last node if available
		if (curTextIndx == nodeTexts.length - 1) {
			HideTextOptionsEntity();
			ShowChoices();
			
			if (nodeChoices.length == 1 && nodeChoices[0].attName == "end") {
				Utils.ConsoleLog("Game End!");
				HideChoices();
				ShowGoToMenu();
				HideTextOptionsEntity();
			}
			
		}
		
		UpdateTextOptionsEntity();
		SetHeaderTextDirty();
		HideXmlInfo();
	}
	
	public function ShowBackText(): Void {
		curTextIndx--;
		curTextIndx = FMath.clamp(curTextIndx, 0, nodeTexts.length - 1);
		Utils.ConsoleLog(curTextIndx + "");
		
		if (curTextIndx != nodeTexts.length - 1) {
			HideChoices();
			HideGoToMenu();
		}
		
		UpdateTextOptionsEntity();
		SetHeaderTextDirty();
		HideXmlInfo();
	}
	
	public function HideNextButton(): Void {
		textOptionsEntity.removeChild(nextTextEntity);
		textOptionsEntity.addChild(backTextEntity);
	}
	
	public function HideBackButton(): Void {
		textOptionsEntity.removeChild(backTextEntity);
		textOptionsEntity.addChild(nextTextEntity);
	}
	
	public function HideTextOptionsEntity(): Void {
		adventureEntity.removeChild(textOptionsEntity);
	}
	
	public function ShowTextOptionsEntity(): Void {
		textOptionsEntity.addChild(nextTextEntity);
		textOptionsEntity.addChild(backTextEntity);
		adventureEntity.addChild(textOptionsEntity);
	}
	
	public function HideGoToMenu(): Void {
		adventureEntity.removeChild(goToMenuEntity);
	}
	
	public function ShowGoToMenu(): Void {
		adventureEntity.addChild(goToMenuEntity);
	}
	
	public function HideChoices(): Void {
		adventureEntity.removeChild(choicesEntity);
	}
	
	public function ShowChoices(): Void {
		adventureEntity.addChild(choicesEntity);
	}
	
	public function ShowXmlInfo(): Void {
		adventureEntity.addChild(xmlHeaderInfoEntity);
		adventureEntity.addChild(xmlButtonInfoEntity);
	}
	
	public function HideXmlInfo(): Void {
		adventureEntity.removeChild(xmlHeaderInfoEntity);
		adventureEntity.removeChild(xmlButtonInfoEntity);
	}
	
	public function UpdateTextOptionsEntity(): Void {
		if (curTextIndx == 0) {
			HideBackButton();
		}
		else if (curTextIndx == nodeTexts.length - 1) {
			HideNextButton();
		}
		else {
			ShowTextOptionsEntity();
		}
	}
	
	public function UpdateChoices(): Void {
		choicesEntity.disposeChildren();
		xmlButtonInfoEntity.disposeChildren();
		
		var choiceIndx: Int = 0;
		for (choices in nodeChoices) {
			var buttonEntity: Entity = new Entity();
			var buttonBG: FillSprite = new FillSprite(0xFFFFFF, System.stage.width * 0.3, 50);

			buttonEntity.add(buttonBG);
			
			var buttonText: TextSprite = new TextSprite(gameFont, choices.value);
			buttonBG.width._ = buttonText.getNaturalWidth() + 15;
			buttonBG.height._ = buttonText.getNaturalHeight() + 5;
			buttonBG.x._ = System.stage.width / 2 - (buttonBG.width._ / 2);
			buttonBG.y._ = System.stage.height * 0.6 - (buttonBG.height._ / 2) + (choiceIndx * 60);
			
			buttonText.x._ = buttonBG.width._ / 2 - (buttonText.getNaturalWidth() / 2);
			buttonText.y._ = buttonBG.height._ / 2 - (buttonText.getNaturalHeight() / 2);
			buttonEntity.addChild(new Entity().add(buttonText));
			
			buttonBG.pointerUp.connect(function(event: PointerEvent) {
				//Utils.ConsoleLog(choices.name + " " + choices.att.name + " " + choices.innerData);
				curNode = Utils.GetNodeFrom(mainNode, choices.attName);
				SetupStage();
				mainNode = curNode;
			}).once();
			
			choicesEntity.addChild(buttonEntity);
			
			// Button Information ---
			
			var infoEntity: Entity = new Entity();
			var infoBG: FillSprite = new FillSprite(0xFFFF00, System.stage.width * 0.35, 20);
			infoBG.centerAnchor();
			infoBG.x._ = buttonBG.x._ + (buttonBG.getNaturalWidth() / 2);
			infoBG.y._ = buttonBG.y._ + (buttonBG.getNaturalHeight() * 1.2);
			infoEntity.add(infoBG);
			
			var nodeNameText: TextSprite = new TextSprite(gameFont_20, "Node: " + choices.nodeName);
			nodeNameText.centerAnchor();
			nodeNameText.x._ = infoBG.getNaturalWidth() / 2 - (infoBG.getNaturalWidth() * 0.25);
			nodeNameText.y._ += infoBG.getNaturalHeight() / 2;
			infoEntity.addChild(new Entity().add(nodeNameText));
			
			var nodeAttText: TextSprite = new TextSprite(gameFont_20, "Attribute: " + choices.attName);
			nodeAttText.centerAnchor();
			nodeAttText.x._ = infoBG.getNaturalWidth() / 2 + (infoBG.getNaturalWidth() * 0.25);
			nodeAttText.y._ += infoBG.getNaturalHeight() / 2;
			infoEntity.addChild(new Entity().add(nodeAttText));
			
			xmlButtonInfoEntity.addChild(infoEntity, false);
			
			choiceIndx++;
		}
	}
	
	public function ResetStage(): Void {
		mainNode = xmlFast;
		curNode = Utils.GetNodeFrom(mainNode, "start");
	}
	
	public function SetHeaderTextDirty(): Void {
		if (headerText == null) {
			return;
		}
		
		headerText.text = nodeTexts[curTextIndx].value;
		headerNameText.text = "Node: " + nodeTexts[curTextIndx].nodeName;
	}
}
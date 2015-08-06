package atarisAdventure;

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

import flambe.script.Script;
import flambe.script.Sequence;
import flambe.script.CallFunction;
import flambe.script.AnimateBy;
import flambe.script.AnimateTo;
import flambe.script.MoveBy;
import flambe.script.MoveTo;
import flambe.script.Delay;

import atarisAdventure.pxlSq.Utils;

/**
 * ...
 * @author Anthony Ganzon
 */
class AdventureEngine extends Component
{
	private var adventureEntity: Entity;
	private var textOptionsEntity: Entity;
	private var choicesEntity: Entity;
	
	private var nextTextEntity: Entity;
	private var backTextEntity: Entity;
	
	private var xmlData: Xml;
	private var xmlFast: Fast;
	
	private var headerText: TextSprite;
	
	private var gameFont: Font;
	
	private var mainNode: Fast;
	private var nodeTexts = [];
	private var nodeChoices = [];
	
	private var curTextIndx: Int;
	
	public function new() 
	{
		adventureEntity = new Entity();
		textOptionsEntity = new Entity();
		choicesEntity = new Entity();
	}
	
	override public function onAdded() 
	{
		super.onAdded();
		owner.addChild(adventureEntity);
	}
	
	public function Init(font: Font, file: File): Void {
		gameFont = font;
		xmlData = Xml.parse(file.toString());
		xmlFast = new Fast(xmlData.firstElement());
		
		mainNode = GetNode("start");
		SetupNode();
		
		//var node1: Fast = GetNode("node1");
		//for (n in node1.nodes.node) {
			//Utils.ConsoleLog(n.att.name);
		//}
		//
		//var node1_1: Fast = GetNode("node1_1");
		//for (n in node1_1.nodes.node) {
			//Utils.ConsoleLog(n.att.name);
		//}
		
		var headerEntity: Entity = new Entity();
		var headerBG: FillSprite = new FillSprite(0xFFFFFF, System.stage.width * 0.8, 200);
		headerBG.x._ = System.stage.width / 2 - (headerBG.width._ / 2);
		headerBG.y._ = System.stage.height * 0.3 - (headerBG.height._ / 2);
		headerEntity.add(headerBG);
		
		headerText = new TextSprite(gameFont, nodeTexts[curTextIndx].innerData);
		headerText.setXY(10, 10);
		headerText.setWrapWidth(500);
		headerEntity.addChild(new Entity().add(headerText));
		
		adventureEntity.addChild(headerEntity);
		
		nextTextEntity = new Entity();
		var nextTextBG: FillSprite = new FillSprite(0xFFFFFF, System.stage.width * 0.1, 50);
		nextTextBG.x._ = System.stage.width * 0.9 - (nextTextBG.width._ / 2);
		nextTextBG.y._ = System.stage.height * 0.8 - (nextTextBG.height._ / 2);
		nextTextEntity.add(nextTextBG);
		
		var nextTextButton: TextSprite = new TextSprite(gameFont, "Next");
		nextTextButton.x._ = nextTextBG.width._ / 2 - (nextTextButton.getNaturalWidth() / 2);
		nextTextButton.y._ = nextTextBG.height._ / 2 - (nextTextButton.getNaturalHeight() / 2);
		nextTextEntity.addChild(new Entity().add(nextTextButton));
		
		nextTextBG.pointerDown.connect(function(event: PointerEvent) {
			NextText();
		});
		
		textOptionsEntity.addChild(nextTextEntity);
		
		backTextEntity = new Entity();
		var backTextBG: FillSprite = new FillSprite(0xFFFFFF, System.stage.width * 0.1, 50);
		backTextBG.x._ = System.stage.width * 0.1 - (backTextBG.width._ / 2);
		backTextBG.y._ = System.stage.height * 0.8 - (backTextBG.height._ / 2);
		backTextEntity.add(backTextBG);
		
		var backTextButton: TextSprite = new TextSprite(gameFont, "Back");
		backTextButton.x._ = backTextBG.width._ / 2 - (backTextButton.getNaturalWidth() / 2);
		backTextButton.y._ = backTextBG.height._ / 2 - (backTextButton.getNaturalHeight() / 2);
		backTextEntity.addChild(new Entity().add(backTextButton));
		
		backTextBG.pointerDown.connect(function(event: PointerEvent) {
			BackText();
		});
		
		textOptionsEntity.addChild(backTextEntity);
		
		adventureEntity.addChild(textOptionsEntity);
	}
	
	public function SetupNode(): Void {
		nodeTexts = [];
		nodeChoices = [];
		//Utils.ConsoleLog(nodeChoices.length + "");
		
		for (t in mainNode.nodes.text) {
			nodeTexts.push(t);
		}
		
		for (c in mainNode.nodes.choices) {
			nodeChoices.push(c);
		}
		
		UpdateChoices();
	}
	
	public function CleanStage(): Void {
		curTextIndx = 0;
		SetHeaderTextDirty();
		
		adventureEntity.removeChild(choicesEntity);
		textOptionsEntity.removeChild(backTextEntity);
		textOptionsEntity.addChild(nextTextEntity);
	}
	
	public function BackText(): Void {
		curTextIndx--;
		curTextIndx = FMath.clamp(curTextIndx, 0, nodeTexts.length - 1);
		
		if (curTextIndx == 0) {
			textOptionsEntity.removeChild(backTextEntity);
		}
		
		textOptionsEntity.addChild(nextTextEntity);
		
		// Always remove choices buttons when going back
		adventureEntity.removeChild(choicesEntity);
		
		SetHeaderTextDirty();
	}
	
	public function NextText(): Void {
		curTextIndx++;
		curTextIndx = FMath.clamp(curTextIndx, 0, nodeTexts.length - 1);
		
		if (curTextIndx == nodeTexts.length -1 ) {
			ShowChoices();
			textOptionsEntity.removeChild(nextTextEntity);
		}
		
		textOptionsEntity.addChild(backTextEntity);
		
		SetHeaderTextDirty();
	}
	
	public function SetHeaderTextDirty(): Void {
		if (headerText == null) {
			return;
		}
		
		headerText.text = nodeTexts[curTextIndx].innerData;
	}
	
	public function ShowChoices(): Void {
		adventureEntity.addChild(choicesEntity);
	}
	
	public function HideChoices(): Void {
		adventureEntity.removeChild(choicesEntity);
	}
	
	public function GetNode(name: String): Fast {
		for (n in xmlFast.nodes.node) {
			if (n.att.name == name) {
				return n;
			}
		}
		
		return null;
	}
	
	public function GetNodeFrom(xmlNode: Fast, name: String): Fast {
		for (n in xmlNode.nodes.node) {
			if (n.att.name == name) {
				return n;
			}
		}
		
		return null;
	}
	
	public function UpdateChoices(): Void {
		choicesEntity.disposeChildren();
		
		var choiceIndx: Int = 0;
		for (choices in nodeChoices) {
			var buttonEntity: Entity = new Entity();
			var buttonBG: FillSprite = new FillSprite(0xFFFFFF, System.stage.width * 0.3, 50);

			buttonEntity.add(buttonBG);
			
			var buttonText: TextSprite = new TextSprite(gameFont, choices.innerData);
			buttonBG.width._ = buttonText.getNaturalWidth() + 20;
			buttonBG.height._ = buttonText.getNaturalHeight() + 10;
			buttonBG.x._ = System.stage.width / 2 - (buttonBG.width._ / 2);
			buttonBG.y._ = System.stage.height * 0.6 - (buttonBG.height._ / 2) + (choiceIndx * 50);
			
			buttonText.x._ = buttonBG.width._ / 2 - (buttonText.getNaturalWidth() / 2);
			buttonText.y._ = buttonBG.height._ / 2 - (buttonText.getNaturalHeight() / 2);
			buttonEntity.addChild(new Entity().add(buttonText));
			
			buttonBG.pointerDown.connect(function(event: PointerEvent) {
				Utils.ConsoleLog(choices.name + " " + choices.att.name + " " + choices.innerData);
				mainNode = GetNodeFrom(mainNode, choices.att.name);
				SetupNode();
				CleanStage();
			});
			
			choicesEntity.addChild(buttonEntity);
			choiceIndx++;
		}
	}
}
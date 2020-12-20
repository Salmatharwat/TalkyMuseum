//
//  ViewController.swift
//  museum
//
//  Created by Salma Tharwat on 4/13/20.
//  Copyright © 2020 Salma Tharwat. All rights reserved.
//
/// Copyright (c) 2018 Razeware LLC
///
import UIKit
import SceneKit
import ARKit
import CoreMedia
import AVFoundation
@available(iOS 12.0, *)
class ViewController: UIViewController {
  var isPlaying = false
  var audioPlayer = AVAudioPlayer()
  var effect: UIVisualEffect!
  var textLabel : String!
  var TextData : String!
  var Name : String!
  var MultiText : String?
   var NameOfDesiredStatue : String?
  var langApp : String?
  var flag: String!
  var statueName : String?
  // Add configuration variables here:
  private var worldConfiguration: ARWorldTrackingConfiguration?
  let urlPath = "https://nairouzmahmoud.000webhostapp.com/testt.php"
  let font: UIFont = UIFont.systemFont(ofSize: 17)
  @objc var btn_choose_language: String!
  
  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet weak var instructionLabel: UILabel!
  @IBOutlet weak var reset: UIButton!
  @IBOutlet weak var VoicePP: UIButton!
  @IBOutlet var TransparentView: UIView!
  @IBOutlet weak var TextLabelV: UITextView!
  @IBOutlet weak var VisualEffect: UIVisualEffectView!
  
  @IBOutlet weak var statueOfName: UILabel!
  
  //When the Exit Text button is pressed
  @IBAction func Xtext(_ sender: Any) {
    
    animateOut()
    
  }
  
  @IBOutlet weak var Text: UIButton!
  //When the Text button is pressed
  @IBAction func Text(_ sender: Any) {
    
    animateIn()
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
      self.TextLabelV.text = self.MultiText
      self.TextLabelV.font = self.font
      self.statueOfName.text = self.NameOfDesiredStatue
    }) }
  
  //When the Settings button is pressed to change the language or allow some settings
  @IBAction func Settings(_ sender: Any) {
    
    let url = URL(string: UIApplication.openSettingsURLString)!
    UIApplication.shared.open(url)
    print(btn_choose_language)
    // flag = Locale.current.languageCode
    
  }
  //When the Voice button is pressed
  @IBAction func VoicePP(_ sender: Any) {
      flag = Locale.current.languageCode
      if (flag == "en"){
           let pianoSound = URL(fileURLWithPath: Bundle.main.path(forResource: "Serapispart1", ofType:"mp3")!)
             do {
               audioPlayer = try AVAudioPlayer(contentsOf: pianoSound)
             }
             catch{
               
             }}
      else {
          instructionLabel.isHidden = true
      let pianoSound = URL(fileURLWithPath: Bundle.main.path(forResource: "SerapisArabic", ofType:"mp3")!)
        do {
          audioPlayer = try AVAudioPlayer(contentsOf: pianoSound)
        }
        catch{
          
        }
      }
    if self.isPlaying {
      print("pause")
      self.audioPlayer.pause()
      self.isPlaying = false
      self.VoicePP.setBackgroundImage(UIImage(systemName: "playpause.fill"), for: UIControl.State.normal)
    } else {
      print("continue")
      self.audioPlayer.play()
      self.isPlaying = true
      self.VoicePP.setBackgroundImage(UIImage(systemName:"pause.fill"), for: UIControl.State.normal)}
    
  }
  //When the reset button is pressed for the voice
  @IBAction func reset(_ sender: Any) {
    
    audioPlayer.stop()
    audioPlayer.currentTime = 0
    isPlaying = false
    audioPlayer.play()
    isPlaying = true
    
    
  }
  
  
  
  //Main function
  override func viewDidLoad() {
    super.viewDidLoad()
    sceneView.delegate = self
    setupObjectDetection()
    let scene = SCNScene()
    sceneView.scene = scene
    VoicePP.isHidden = true
    reset.isHidden = true
    Text.isHidden = true
    effect = VisualEffect.effect
    VisualEffect.effect = nil
    TransparentView.layer.cornerRadius = 5
    
  }
  
  // Pop message handling function and some features added
  func animateIn(){
    self.view.addSubview(TransparentView)
    self.navigationController?.setNavigationBarHidden(true, animated: true )
    TransparentView.center = self.view.center
    TransparentView.transform = CGAffineTransform.init(scaleX: 21, y: 21)
    TransparentView.alpha = 0
    UIView.animate(withDuration: 0.4){
      self.VisualEffect.effect = self.effect
      self.TransparentView.alpha = 1
      self.TransparentView.transform = CGAffineTransform.identity
      
    }}
  
  //Pop message hiding function and adding some features
  func animateOut(){
    UIView.animate(withDuration: 0.3, animations:{
      self.navigationController?.setNavigationBarHidden(false, animated: true )
      self.TransparentView.transform = CGAffineTransform.init(scaleX: 21, y: 21)
      self.TransparentView.alpha = 0
      self.VisualEffect.effect = nil
      
    })  {(success:Bool)in
      self.TransparentView.removeFromSuperview()
    }
  }
  
  
  // add 3d model
  private func addModel(to node: SCNNode,referenceImage: ARReferenceImage? ,referenceObject: ARReferenceObject?  ) {
    
    if statueName == "Horus" as String  {
      let ModelScene = SCNScene(named: "horus.dae")!
      let baseNode = ModelScene.rootNode.childNode(withName: "baseNode", recursively: true)!
      node.addChildNode(baseNode)
      self.sceneView.scene.rootNode.addChildNode(baseNode)
      
    }
    else if statueName == "Serapis" as String  {
      let ModelScene = SCNScene(named: "serapis copy.dae")!
      let baseNode = ModelScene.rootNode.childNode(withName: "baseNode", recursively: true)!
      node.addChildNode(baseNode)
      self.sceneView.scene.rootNode.addChildNode(baseNode)
      
    }
    
    
  }
  
  //It's called when the view is about to appear as a result of the user tapping the back button.
  override func viewWillAppear(_ animated: Bool) {
    
    super.viewWillAppear(animated)
    if let configuration = worldConfiguration {
      sceneView.session.run(configuration)
    }
    
  }
  //This method is called before the view is actually removed and before any animations are configured.
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    sceneView.session.pause()
    
  }
  
  // to set up 2d & 3d objects in detection process
  private func setupObjectDetection() {
    worldConfiguration = ARWorldTrackingConfiguration()
    guard let referenceImages = ARReferenceImage.referenceImages(
      inGroupNamed: "AR Images", bundle: nil) else {
        fatalError("Missing expected asset catalog resources.")
    }
    worldConfiguration?.detectionImages = referenceImages
    guard let referenceObjects = ARReferenceObject.referenceObjects(
      inGroupNamed: "AR Objects", bundle: nil) else {
        fatalError("Missing expected asset catalog resources.")
    }
    
    worldConfiguration?.detectionObjects = referenceObjects
  }
  
}

// MARK: -
extension ViewController: ARSessionDelegate {
  
       
  func session(_ session: ARSession, didFailWithError error: Error) {
    if (Locale.current.languageCode == "en"){
    guard
      let error = error as? ARError,
      let code = ARError.Code(rawValue: error.errorCode)
      else { return }
    instructionLabel.isHidden = false
    switch code {
    case .cameraUnauthorized:
      instructionLabel.text = "Camera tracking is not available. Please check your camera permissions."
    default:
      instructionLabel.text = "Error starting ARKit. Please fix the app and relaunch."
    }
    }else{
      guard
          let error = error as? ARError,
          let code = ARError.Code(rawValue: error.errorCode)
          else { return }
        instructionLabel.isHidden = false
        switch code {
        case .cameraUnauthorized:
          instructionLabel.text = "تتبع الكاميرا غير متاح. يرجى التحقق من أذونات الكاميرا."
        default:
          instructionLabel.text = "خطأ في بدء ARKit. يرجى إصلاح التطبيق وإعادة التشغيل."
        }
      }}
  
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    if (Locale.current.languageCode == "en"){
    switch camera.trackingState {
    case .limited(let reason):
      instructionLabel.isHidden = false
      switch reason {
      case .excessiveMotion:
        instructionLabel.text = "Too much motion! Slow down."
      case .initializing, .relocalizing:
        instructionLabel.text = "ARKit is doing it's thing. Move around slowly for a bit while it warms up."
      case .insufficientFeatures:
        instructionLabel.text = "Not enough features detected, try moving around a bit more or turning on the lights."
        
      }
    case .normal:
      instructionLabel.text = "Point the camera at a statue."
    case .notAvailable:
      instructionLabel.isHidden = false
      instructionLabel.text = "Camera tracking is not available."
    }
    } else{
      switch camera.trackingState {
         case .limited(let reason):
           instructionLabel.isHidden = false
           switch reason {
           case .excessiveMotion:
             instructionLabel.text = "الكثير من الحركة! ابطئ."
           case .initializing, .relocalizing:
             instructionLabel.text = "ARKit يفعل ذلك. تحرك ببطء لبعض الوقت بينما يسخن."
           case .insufficientFeatures:
             instructionLabel.text = "لم يتم اكتشاف ميزات كافية ، جرّب التحرك قليلاً أو تشغيل الأضواء."
             
           }
         case .normal:
           instructionLabel.text = "وجِّه الكاميرا إلى تمثال."
         case .notAvailable:
           instructionLabel.isHidden = false
           instructionLabel.text = "تتبع الكاميرا غير متاح."
         }
  
  }
  }}

// MARK: -
extension ViewController: ARSCNViewDelegate {
  // When detecting a statue
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    DispatchQueue.main.async { self.instructionLabel.isHidden = true
      self.VoicePP.isHidden = false
      self.reset.isHidden = false
      self.Text.isHidden = false
      
    }
    if let imageAnchor = anchor as? ARImageAnchor {
      statueName = handleFoundImage(imageAnchor, node)
      let refImage = imageAnchor.referenceImage
      addModel(to: node, referenceImage: refImage, referenceObject: nil )
      
      
    } else if let objectAnchor = anchor as? ARObjectAnchor {
      statueName = handleFoundObject(objectAnchor, node)
      let refobj = objectAnchor.referenceObject
      addModel(to: node, referenceImage: nil, referenceObject: refobj )
      
    }
  }
  
  private func handleFoundImage(_ imageAnchor: ARImageAnchor, _ node: SCNNode) -> String {
    let name = imageAnchor.referenceImage.name!
    print("you found a \(name) image")
  
    sendJson(name,langApp)
    return name
    
  }
  
  
  private func handleFoundObject(_ objectAnchor: ARObjectAnchor, _ node: SCNNode) -> String {
    let name = objectAnchor.referenceObject.name!
    print("You found a \(name) object")
    sendJson(name,langApp)
    return name
  }
  
  // database
  struct RouterData: Decodable {
    
    let vartype: String?
    let varid: String?
  }
  
  func parseJSON(_ data:Data , _ textlang : String ) {
    
    var jsonResult = NSArray()
    
    do{
      
      jsonResult = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSArray
      
      
    } catch let error as NSError {
      print(error)
      
      
    }
    
    var jsonElement = NSDictionary()
    let locations = NSMutableArray()
    
    for i in 0 ..< jsonResult.count
    {
      
      jsonElement = jsonResult[i] as! NSDictionary
      
      let location = LocationModel()
      
      //the following insures none of the JsonElement values are nil through optional binding
      if
        let Texts = jsonElement[textlang] as? String
       
      {
        
        let Texts = jsonElement[textlang] as? String
        let Name = jsonElement["Name"] as? String
        let Names = jsonElement["Namee"] as? String
         location.Texts = Texts
        if (Locale.current.languageCode == "en"){
         location.Name = Names
         NameOfDesiredStatue = location.Name
          print(NameOfDesiredStatue) }
        else{
          location.Name = Name
          NameOfDesiredStatue = location.Name
           print(NameOfDesiredStatue)
        }
        MultiText = location.Texts
        print(MultiText)
        locations.add(location)
        
      }
      
    }
    
  }
  func sendJson( _ statueName : String! , _ langApp : String!){
    flag = Locale.current.languageCode
    var textLang = "EngText"
    var arabicText = "ArText"
    if let Name = statueName {
      
      print(Name)
      
      print(Name)
      if (flag == "en"){
        textLang = "EngText" }
      else {
        textLang = "ArText"
      }
      
      let request = NSMutableURLRequest(url: NSURL(string: "https://nairouzmahmoud.000webhostapp.com/getinfo.php")! as URL)
      request.httpMethod = "POST"
      let postString = "Name=\(Name)&textLang=\(textLang)"
      request.httpBody = postString.data(using: String.Encoding.utf8)
      let task = URLSession.shared.dataTask(with: request as URLRequest) {
        data, response, error in
        
        if error != nil {
          print("error=\(error)")
          return
        }
        
        print("response = \(response)")
        let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        self.parseJSON(data! , textLang )
        print("responseString = \(responseString)")
        if let TextData = responseString{
          print(TextData)
        }
      }
      task.resume()
    }
  }
  
}

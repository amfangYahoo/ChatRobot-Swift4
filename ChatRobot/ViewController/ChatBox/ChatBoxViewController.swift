//
//  ViewController.swift
//  ChatRobot
//
//  Created by Jacky Fang on 2019/1/12.
//  Copyright © 2019 Jacky Fang. All rights reserved.
//
//  From 测试成功的ViewController

import UIKit
import SocketIO
import SwiftyJSON
import AVFoundation
import RxSwift
import Moya

class ChatBoxViewController: UIViewController, UITextFieldDelegate, AVAudioPlayerDelegate, IFlySpeechRecognizerDelegate, IFlySpeechSynthesizerDelegate, STKAudioPlayerDelegate {
    
    @IBOutlet var backgroundView: UIView!
    var manager:SocketManager!
    var socket:SocketIOClient!
    
    var me:UserInfo!
    var you:UserInfo!
    var sendView:UIView!
    var txtMsg:UITextField!
    var keyboardMovement:CGFloat = 0
    
    var iconWidth:CGFloat = 100
    var ripWidth:CGFloat = 200
    var ripView:CVLayerViewRip!
    var iconBtn:UIButton!
    var ripAnimating: Bool = false
    
    var audioPlayer:AVAudioPlayer!
    
    //ScrollView
    var chatScrollView: UIScrollView!
    var messageHeight:CGFloat = 0
    var scrollViewMoveLenght:CGFloat = 10
    var scrollViewOffLenght:CGFloat = 0
    
    //Anim
    var voiceAnimImage: UIImage?
    var micAnimImage: UIImage?
    
    //Xunfei
    var _iflyRecognizerView : IFlySpeechRecognizer!
    var _iFlySpeechSynthesizer : IFlySpeechSynthesizer!
    var recorder : AVAudioRecorder?
    var speechResult : NSString?
    var finalCommand : NSString!
    var timerRec: Timer!
    var inRecording: Bool = false
    
    //onResult:false
    var currentSpeechResult : NSString!
    
    //musicGetRequest
    var requestingMusic : Bool = false
    var inMusicSearching : Bool = false
    
    //Moya+SwiftyJSON+RxSwift
    private let provider = MoyaProvider<APIManager>()
    let disposeBag = DisposeBag()
    
    //StreamingKit
    var audioStreamPlayer: STKAudioPlayer!
    
    //micbtn & speakerBtn
    var micBtn: UIButton!
    var speakerBtn: UIButton!
    var micEnabled: Bool = true
    var speakerEnabled: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /*
         * self.socket.connect() -> timer, 10, once -> logintTest() //临时方案 ->
         * -> self.socket.emit("login", myJSON) ;; 完成登录会话
         * addSocketHandlers() -> self.socket.on("message") -> handleReturnMessageObj(objRun) -> addChatMessageItem(message: currentMsg) ->
         * -> audioPlayer.play() -> AVAudioPlayerDelegate -> audioPlayerDidFinishPlaying() -> startRec() -> IFlySpeechRecognizerDelegate -> onError() -> startRec() -> onResults() -> stopRec() -> showMessage(showMsg: speechResult!) -> self.socket.emit("private_message", "bob", showStrJSON) & addChatMessageItem(message: thisChat) -> self.socket.on("message")
         *
         */
        
        //Xseries判断
        let isPhoneX = isIPhoneXSeries()
        let isPhoneX1 = isIPhoneXType()
        print("Xseries: \(isPhoneX)")
        print("Xseries1: \(isPhoneX1)")
        if isPhoneX {
            print("Xseries1: \(isPhoneX)")
        }
        
        //全局变量获取滞后，暂时不使用AppDelegate里获取
        print("全局变量测试: \(Constant.Variables.urlAWS)")
        
        //获取AWS ipAddress
        //let provider = MoyaProvider<APIManager>()
        provider.request(.getAWSServerIPAddress(url: "http://amfang.applinzi.com/appData/apkAWSServerIP.php")) { result in
            if case let .success(response) = result {
                //解析数据
                //let data = try? response.data.description
                let urlStr = String(data:response.data, encoding: String.Encoding.utf8)
                print("data: \(urlStr)")
                let urlStr1 = urlStr!.trimmingCharacters(in: .newlines)
                print("data: \(urlStr1)")
                Constant.Variables.urlAWS = urlStr1
                print("全局变量测试: \(Constant.Variables.urlAWS)")
                let urlStr2 = urlStr1.appending(":3000")
                print("data: \(urlStr2)")
                self.socketConnection(awsUrl: urlStr2)
                //self.socketConnection(awsUrl: "http://192.168.1.102:3800")
            }
        }
        
        //转换中文字符串位数字字符串，中文用户名发送会出错，没有返回???
        let localUserName = UserDefaults.standard.object(forKey: "localUserName")
//        let intString = localUserName as! NSString
//        let localUserNameToInt = intString.integerValue
//        let newLoaclUserName = String(localUserNameToInt)
        
        me = UserInfo(name:localUserName as! String ,logo:("ertong.png"))
        you  = UserInfo(name:"小添", logo:("xiaotian.png"))
        
        //设置界面
        setupScrollView()
        setupSendPanel()
        
        //监听键盘
        //监听键盘弹出通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_ :)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        //监听键盘隐藏通知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_ :)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        //初始化xunfei
        speechResult = ""
        intRecognizer()
        setRecorder()
        
        //初始化网络链接播放
        audioStreamPlayer = STKAudioPlayer()
        audioStreamPlayer.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initSynthesizer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        _iFlySpeechSynthesizer.stopSpeaking();
        _iFlySpeechSynthesizer.delegate = nil
        super.viewWillDisappear(animated)
    }
    
    
    
    func initSynthesizer(){
        let instance = TTSConfig.sharedInstance()
        if instance == nil {
            return
        }
        if _iFlySpeechSynthesizer == nil {
            _iFlySpeechSynthesizer = IFlySpeechSynthesizer.sharedInstance()
        }
        _iFlySpeechSynthesizer.delegate = self
        _iFlySpeechSynthesizer.setParameter(instance?.speed, forKey: IFlySpeechConstant.speed())
        _iFlySpeechSynthesizer.setParameter(instance?.volume, forKey: IFlySpeechConstant.volume())
        _iFlySpeechSynthesizer.setParameter(instance?.pitch, forKey: IFlySpeechConstant.pitch())
        _iFlySpeechSynthesizer.setParameter(instance?.sampleRate, forKey: IFlySpeechConstant.sample_RATE())
        _iFlySpeechSynthesizer.setParameter(instance?.vcnName, forKey: IFlySpeechConstant.voice_NAME())
        _iFlySpeechSynthesizer.setParameter("unicode", forKey: IFlySpeechConstant.text_ENCODING())
    }
    
    func iFlySoundPlay(soundString: NSString){
        _iFlySpeechSynthesizer.startSpeaking(soundString as String);
    }
    
    func socketConnection(awsUrl: String){
        //定义
        self.manager = SocketManager(socketURL: URL(string: awsUrl)!, config: [.log(false), .compress])
        self.socket = manager.defaultSocket
        
        addSocketHandlers()
        
        self.socket.connect()
        
        //self.socket.emit("login", ["userid":"this.userid", "username":"this.username"])
        //self.socket.emit("login", myJSON)
//        var timer : Timer!
//        timer=Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.logintTest), userInfo: nil, repeats: false)
    }
    
    func intRecognizer(){
        _iflyRecognizerView = IFlySpeechRecognizer.sharedInstance()
        _iflyRecognizerView.delegate = self
        _iflyRecognizerView.setParameter("", forKey: IFlySpeechConstant.params())
    }
    func setRecorder(){
        let url:NSURL = NSURL.fileURL(withPath: "/dev/null") as NSURL
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        do {
            recorder = try AVAudioRecorder(url: url as URL, settings: settings)
            recorder?.prepareToRecord()
            recorder?.isMeteringEnabled = true
            //recorder?.delegate = self
        } catch {
            finishRecording(success: false)
        }
    }
    
    //Xseries判断函数
    func isIPhoneXSeries() -> Bool{
        var iPhoneXseries:Bool = false
        if UIDevice.current.userInterfaceIdiom != UIUserInterfaceIdiom.phone {
            print("isIPhoneXSeries: \(iPhoneXseries)")
            return iPhoneXseries
        }
        if #available(iOS 11.0, *) {
            print("isIPhoneXSeries:#available: \(iPhoneXseries)")
            if UIApplication.shared.windows[0].safeAreaInsets.bottom > 0.0{
                print("isIPhoneXSeries:#available:safeAreaInsets: \(iPhoneXseries)")
                iPhoneXseries = true
            }
        }
        return iPhoneXseries
    }
    
    func isIPhoneXType() -> Bool {
        guard #available(iOS 11.0, *) else {
            return false
            
        }
        print("UIApplication.shared.windows[0].safeAreaInsets.bottom: \(UIApplication.shared.windows[0].safeAreaInsets.bottom)")
        return UIApplication.shared.windows[0].safeAreaInsets.bottom != 0.0
        
    }
    
    // 键盘显示
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if keyboardMovement != 0 {
            return
        }
        DispatchQueue.main.async {
            
            let user_info = notification.userInfo
            let keyboardRect = (user_info?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            let y = keyboardRect.size.height
            let movement:CGFloat = -y + 49 + 34
            //let movement:CGFloat = -y + 49
            self.keyboardMovement = movement
            
            UIView.animate(withDuration: 0.3, animations: {
                //self.view.center = CGPoint.init(x: Width/2, y: self.view.center.y - offset_y)
                self.sendView.frame = self.sendView.frame.offsetBy(dx: 0,  dy: movement)
            })
        }
        
    }
    
    // 键盘隐藏
    @objc func keyboardWillHide(_ notification: Notification) {
        
        DispatchQueue.main.async {
            
            let movement = -self.keyboardMovement
            
            UIView.animate(withDuration: 0.3, animations: {
                //self.view.center = CGPoint.init(x: Width/2, y: self.view.center.y - offset_y)
                self.sendView.frame = self.sendView.frame.offsetBy(dx: 0,  dy: movement)
            })
            self.keyboardMovement = 0
        }
    }
    
    @objc func logintScocket(){
        let username = me.username
        print("me.username: \(username)")
    
        //userid不能用中文?
        let myJSON = [
            "userid": username,
            "username": username
        ]
        self.socket.emit("login", myJSON)
        //
        micBtn.isEnabled = true
        speakerBtn.isEnabled = true
    }
    
    func addSocketHandlers() {
        
        //connect完成后才能emit
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            //直接执行如果是中文内容会无法发送，不知道原因，如果使用延时或者暂停，执行没有问题
            //sleep(1)
            //self.logintTest()
            var timer : Timer!
            timer=Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.logintScocket), userInfo: nil, repeats: false)
        }
        
        self.socket.on("message") {[weak self] data, ack in
            print("message: data - \(data)")
            if let name = data[0] as? String {
                print("From: \(name)")
            }
            
            //SwiftyJSON解析模型
            print("data[1]: \(type(of: data[1]))")
            let jsonData = JSON.init(data[1] as! NSDictionary)
            let objRun = ContentObjModel(jsonData: jsonData)
            self? .handleReturnMessageObj(objRun)
            
            return
        }
        
        self.socket.on("gameOver") {data, ack in
            exit(0)
        }
        
        //self.socket.onAny {print("Got event: \($0.event), with items: \($0.items!)")}
    }
    
    //使用模型解析返回content
    func handleReturnMessageObj(_ objRun: ContentObjModel) {
        
        //musicGetRequest
        if let musicGetRequest = objRun.musicGetRequest {
            if musicGetRequest {
                print("开始音乐搜索")
                requestingMusic = true
            }
        }
        
        print("func handleReturnMessageObj: \(objRun.content)")
        if let content = objRun.content{
            print("Typeof: \(type(of: content))")
            print("SwiftyJSON获取content: \(content)")
            
            if content.count < 300 {
                //添加信息条目
                let currentMsg =  MessageItem(body:content as NSString, user:you,  date:Date(timeIntervalSinceNow:-90096400), mtype:.someone)
                addChatMessageItem(message: currentMsg)
            }else{
                //声音字符串处理
                // 将base64字符串转换成Data, 使用AvAudioPlayer播放
                //https://stackoverflow.com/questions/39206139/how-to-convert-base64-into-nsdata-in-swift
                do {
                    let audioData = Data(base64Encoded: content, options: .ignoreUnknownCharacters)
                    // 将数据写入file
                    let fullPath = NSHomeDirectory().appending("/Documents/").appending("test.mp3")
                    let writeData = audioData as! NSData
                    writeData.write(toFile: fullPath, atomically: true)
                    print("Path: \(fullPath)")
                    
                    let documentPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
                    //获得并输出文档目录，应该将所有的数据文件写入到该目录下，这个目录通常用来保存用户数据
                    print("documentPath：\(documentPath[0])")
                    
                    //AVAudioPlayer不能作为局部变量，否则没声音
                    if audioData != nil && speakerEnabled {
                        
                        //voice动画
                        iconBtn.setImage(voiceAnimImage, for: .normal)
                        
                        ripView.starAnimation()  // 开始动画
                        audioPlayer = try AVAudioPlayer(data: audioData!)
                        audioPlayer.delegate = self
                        audioPlayer.prepareToPlay()
                        audioPlayer.play()
                        print("audioPlayer done")
                    }else{
                        if micEnabled {
                            iconBtn.setImage(UIImage(named: "mic.png"), for: .normal)
                            //开始录音
                            startRec()
                        }else{
                            iconBtn.setImage(UIImage(named: "mic-muted.png"), for: .normal)
                        }
                    }
                    
                }catch let error as NSError {
                    print(error.description)
                }
            }
        }
    }
    
    func setupSendPanel()
    {
        let screenWidth = self.backgroundView.bounds.width
        sendView = UIView(frame:CGRect(x: 0,y: self.backgroundView.bounds.height - 56 - 49 - 34,width: screenWidth,height: 56))
        //sendView = UIView(frame:CGRect(x: 0,y: self.view.bounds.height - 56 - 49,width: screenWidth,height: 56))
        
        sendView.backgroundColor=UIColor.lightGray
        sendView.alpha=0.9
        
        txtMsg = UITextField(frame:CGRect(x: 10,y: 10,width: screenWidth - 95,height: 36))
        txtMsg.backgroundColor = UIColor.white
        txtMsg.layer.cornerRadius = 5.0
        txtMsg.textColor = UIColor.black
        txtMsg.font = UIFont.boldSystemFont(ofSize: 12)
        txtMsg.returnKeyType = UIReturnKeyType.send
        //文本框对应的键盘样式，枚举类型，其他类型大家可以自行尝试
        //txtMsg.keyboardType = UIKeyboardType.URL
        
        //Set the delegate so you can respond to user input
        txtMsg.delegate = self
        sendView.addSubview(txtMsg)
        self.backgroundView.addSubview(sendView)
        
        let sendButton = UIButton(frame:CGRect(x: screenWidth - 80,y: 10,width: 72,height: 36))
        sendButton.backgroundColor = UIColor(red: 0x37/255, green: 0xba/255, blue: 0x46/255, alpha: 1)
        sendButton.addTarget(self, action:#selector(self.sendMessage) ,
                             for:UIControl.Event.touchUpInside)
        sendButton.layer.cornerRadius = 5.0
        sendButton.setTitle("发送", for:UIControl.State())
        sendView.addSubview(sendButton)
        
        //Button图片动画
        voiceAnimImage = UIImage.animatedImageNamed("voice_anim", duration: 2.0)!
        micAnimImage = UIImage.animatedImageNamed("mic_anim", duration: 2.0)!
    }
    
    // TextFieldDelegate 点击Return按钮注销第一响应，键盘回落
    func textFieldShouldReturn(_ textField:UITextField) -> Bool
    {
        textField.resignFirstResponder()
        sendMessage()
        return true
    }
    // 点击空白处注销第一响应，键盘回落
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func sendMessage()
    {
        if inRecording {
            stopRec()
        }
        //composing=false
        let sender = txtMsg
        if let sendMsg = sender!.text {
            print("sender.text: \(sendMsg)")
            showMessage(showMsg: sendMsg as NSString)
            
            //self.showTableView()
            sender?.resignFirstResponder()
            sender?.text = ""
        }
    }
    
    func showMessage(showMsg: NSString){
        let thisChat = MessageItem(body:showMsg as NSString, user:me, date:Date(), mtype:.mine)
        
        let showStrJSON = [
            "userid": me.username,
            "username": me.username,
            "content": showMsg
            ] as [String : Any]
        
        addChatMessageItem(message: thisChat)
        //Button图片动画
        let thinkAnimImage = UIImage.animatedImageNamed("thinking", duration: 2.0)
        iconBtn.setImage(thinkAnimImage, for: .normal)
        
        //musicGetRequest
        if requestingMusic {
            print("search music: \(showMsg)")
            searchMusic(musicName: showMsg)
        }else{
            self.socket.emit("private_message", me.username, showStrJSON)
            print("socket.emitted")
        }
        
    }
    
    func searchMusic(musicName: NSString){
        //唱歌
        let urlString = "http://tingapi.ting.baidu.com"
        //处理多余的字符
        let musicName1 = musicName.trimmingCharacters(in: .whitespaces)
        print("musicName: \(musicName1)")
        let musicName2 = musicName1.replacingOccurrences(of: ".", with: "")
        print("musicName1: \(musicName2)")
        let musicName3 = musicName2.replacingOccurrences(of: "。", with: "")
        print("musicName2: \(musicName3)")
        let musicName4 = musicName3.replacingOccurrences(of: "？", with: "")
        print("musicName3: \(musicName4)")
        var queryParameter = ["from":"webapp_music","method":"baidu.ting.search.catalogSug","format":"json"] as [String: String]
        queryParameter["query"] = musicName4 as String?
        print("queryParameter: \(queryParameter)")
        self.searchMusicFromBaidu(url: urlString, queryParameter: queryParameter)
        print("music.artistname: ")
    }
    
    //网络请求-- HandyJSON
    func searchMusicFromBaidu(url: String, queryParameter: [String:String]) {
        //MoyaProvider针对APIManager的searchMusicFromBaidu提交网络请求
        //返回结果使用MusicObjModel进行HandyJSON封装
        //当前使用第一条记录
        //["from":"webapp_music" ,"method":"baidu.ting.search.catalogSug","format":"json","query":"天亮了"]
        provider.rx.request(.searchMusicFromBaidu(url: url, queryParameter: queryParameter))
            .asObservable()
            .mapHandyJsonModel(MusicObjModel.self)
            .subscribe({ [unowned self] (event) in
                //print("event: \(event)")
                switch event {
                case let .next(classModel):
                    
                    //需要添加classModel如果为空，没找到歌曲是提示并进入下一轮
                    guard let order = classModel.order else {
                        print("inRecording-searchMusic:\(self.inRecording)")
                        let chatMsg = "您一定是说了假的歌曲名，俺没找到哦，您可以再说一个"
                        let thisChat = MessageItem(body:chatMsg as NSString, user:self.you, date:Date(), mtype:.someone)
                        self.addChatMessageItem(message: thisChat)
                        self.ripView.stopAnimation()
                        if self.speakerEnabled {
                            //voice动画
                            self.iconBtn.setImage(self.voiceAnimImage, for: .normal)
                            
                            self.ripView.starAnimation()
                            self.inMusicSearching = true
                            self.iFlySoundPlay(soundString: chatMsg as NSString)
                        }
                        
                        return
                    }
                    print("HandyJSON -- 加载网络成功")
                    //网络请求结果使用classModel封装
                    print("classModel.data: \(classModel.order)")
                    let musicInfoList: [MusicObjModel_sub] = classModel.song
                    let musicSelected = musicInfoList[0]
                    print("musicSelected: \(musicSelected.songid)")
                    
                    //xufei说话
                    let chatMsg = "给您播放\(musicSelected.artistname as! String)的\(musicSelected.songname as! String)，敬请欣赏"
                    let thisChat = MessageItem(body:chatMsg as NSString, user:self.you, date:Date(), mtype:.someone)
                    self.addChatMessageItem(message: thisChat)
                    self.ripView.stopAnimation()
                    self.inMusicSearching = false
                    self.iFlySoundPlay(soundString: chatMsg as NSString)
                    
                    self.getMusicDownloadLinkFromBaidu(url: url, songid: musicSelected.songid!)
                    
                case let .error( error):
                    print("error:", error)
                    //self.networkError.accept(error as! Error.Protocol)
                case .completed: break
                }
            }).disposed(by: self.disposeBag)
    }
    
    //网络请求-- HandyJSON
    func getMusicDownloadLinkFromBaidu(url: String, songid: String) {
        //MoyaProvider针对APIManager的searchMusicFromBaidu提交网络请求
        //返回结果使用MusicLinkObjModel进行HandyJSON封装
        //当前使用第一条记录
        //["method":"baidu.ting.song.play","songid":"73957736"]
        var queryParameter = ["method":"baidu.ting.song.play"] as [String: String]
        queryParameter["songid"] = songid as String?
        print("queryParameter: \(queryParameter)")
        provider.rx.request(.getMusicDownloadLinkFromBaidu(url: url, queryParameter: queryParameter))
            .asObservable()
            .mapHandyJsonModel(MusicInfoObjModel.self)
            .subscribe({ [unowned self] (event) in
                //print("event: \(event)")
                switch event {
                case let .next(classModel):
                    
                    print("HandyJSON -- 加载网络成功 - download")
                    //网络请求结果使用classModel封装
                    print("classModel.data: \(classModel.bitrate)")
                    let musicDetail: MusicInfoObjModel_sub = classModel.bitrate
                    var musicFileLink: String = musicDetail.file_link!
                    print("musicSelected: \(musicFileLink)")
                    if !musicFileLink.isEmpty {
                        
                        //更新音乐请求标示
                        self.requestingMusic = false
                        //播放音乐link
                        self.playMusicLinkOnline(musicLink: musicFileLink)
                    }
                    
                case let .error( error):
                    print("error:", error)
                //self.networkError.accept(error as! Error.Protocol)
                case .completed: break
                }
            }).disposed(by: self.disposeBag)
    }
    
    func playMusicLinkOnline(musicLink: String) {
        //voice动画
        iconBtn.setImage(voiceAnimImage, for: .normal)
        
        ripView.starAnimation()  // 开始动画
        audioStreamPlayer.play(musicLink)
        print("playMusicLinkOnline done")
    }
    
    //View
    func setupScrollView() {
        print("setupScrollView")
        //设置scrollview开始的高度
        messageHeight = messgeGap
        
        let screenWidth = self.backgroundView.bounds.width
        let screenHeight = self.backgroundView.bounds.height
        
        chatScrollView = UIScrollView(frame: CGRect(x: 0, y: 44, width: screenWidth, height: screenHeight - 56 - 49 - 34 - ripWidth))
        //chatScrollView = UIScrollView(frame: CGRect(x: 0, y: 44, width: screenWidth, height: screenHeight - 56 - 49 - ripWidth))
        //chatScrollView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 150)
        chatScrollView.backgroundColor = UIColor.gray
        chatScrollView.contentSize.height = screenHeight
        
        self.backgroundView.addSubview(chatScrollView)
        
        //Rip and Button
        let iconView = UIView(frame:CGRect(x:0,y:self.backgroundView.bounds.height - 56 - 49 - 34 - ripWidth, width:screenWidth, height:ripWidth))
        //let iconView = UIView(frame:CGRect(x:0,y:self.view.bounds.height - 56 - 49 - ripWidth, width:screenWidth, height:ripWidth))
        iconView.backgroundColor = UIColor.white
        self.backgroundView.addSubview(iconView)
        iconBtn = UIButton(frame: CGRect(x: (screenWidth - iconWidth) / 2, y: (200 - iconWidth) / 2, width: iconWidth, height: iconWidth))
        iconBtn.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
        iconBtn.layer.cornerRadius = iconWidth / 2
        //iconBtn.setTitle("test", for: .normal)
        
        //Button图片动画
        let initAnimImage = UIImage.animatedImageNamed("connection", duration: 2.0)
        iconBtn.setImage(initAnimImage, for: .normal)
        
        //设置图片边框
        iconBtn.imageEdgeInsets = UIEdgeInsets(top: 27,left: 30,bottom: 27,right: 30)
        
        iconView.addSubview(iconBtn)
        //RippleDiffuse
        ripView = CVLayerViewRip(frame: CGRect(x:(screenWidth - ripWidth) / 2, y:0, width: ripWidth, height: ripWidth))
        iconView.insertSubview(ripView, belowSubview: iconBtn)
        
        //麦克风button 和 声音button
        micBtn = UIButton(frame: CGRect(x: screenWidth / 4 - 40, y: 100, width: 40, height: 40))
        micBtn.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        micBtn.layer.cornerRadius = 5
        let micImage = UIImage(named: "mic.png")
        micBtn.setImage(micImage, for: .normal)
        //传递触摸对象（即点击的按钮），需要在定义action参数时，方法名称后面带上冒号
        micBtn.addTarget(self, action:#selector(micBtnTapped(_:)), for:.touchUpInside)
        micBtn.isEnabled = false
        iconView.addSubview(micBtn)
        
        speakerBtn = UIButton(frame: CGRect(x: screenWidth * 3 / 4, y: 100, width: 40, height: 40))
        speakerBtn.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        speakerBtn.layer.cornerRadius = 5
        let speakerImage = UIImage(named: "speaker.png")
        speakerBtn.setImage(speakerImage, for: .normal)
        //传递触摸对象（即点击的按钮），需要在定义action参数时，方法名称后面带上冒号
        speakerBtn.addTarget(self, action:#selector(speakerBtnTapped(_:)), for:.touchUpInside)
        speakerBtn.isEnabled = false
        iconView.addSubview(speakerBtn)
    }
    
    @objc func micBtnTapped(_ button:UIButton){
        
        if micEnabled && inRecording {
            self.stopRec()
            self.ripView.stopAnimation()
            self.iconBtn.setImage(UIImage(named: "mic-muted.png"), for: .normal)
        }else{
            if audioStreamPlayer.state != STKAudioPlayerState.playing && !audioPlayer.isPlaying {
                self.startRec()
            }
        }
        let micImage = UIImage(named: "mic.png")
        let micImageDisable = UIImage(named: "mic-muted.png")
        button.setImage(micEnabled ? micImageDisable : micImage, for: .normal)
        micEnabled = !micEnabled
    }
    
    @objc func speakerBtnTapped(_ button:UIButton){
        
        if speakerEnabled {
            if audioPlayer.isPlaying {
                audioPlayer.stop()
                ripView.stopAnimation()
                print("AVAudioplayer 播放被停止")
                
                if micEnabled {
                    //开始录音
                    startRec()
                }
            }
            if audioStreamPlayer.state == STKAudioPlayerState.playing {
                audioStreamPlayer.stop()
                ripView.stopAnimation()
            }
            iconBtn.setImage(UIImage(named: "speaker-muted.png"), for: .normal)
        }else{
            iconBtn.setImage(UIImage(named: "speaker.png"), for: .normal)
        }
        let speakerImage = UIImage(named: "speaker.png")
        let speakerImageDisable = UIImage(named: "speaker-muted.png")
        button.setImage(speakerEnabled ? speakerImageDisable : speakerImage, for: .normal)
        speakerEnabled = !speakerEnabled
    }
    
    //Chat
    func addChatMessageItem(message: MessageItem){
        
        //定义一个画chatUIView的地方
        let chatFrame = CGRect(x: 10, y: scrollViewMoveLenght, width: screenWidth - 10, height: 10)
        
        let messageUIView = MessageUIView(frame: chatFrame, message: message)
        //let chatUIView = ChatUIView(frame: chatFrame, messageUIView: messageUIView)
        //let chatHeight = chatUIView.getChatUIViewHeight()
        let chatHeight  =  max(message.insets.top + message.view.frame.size.height  + message.insets.bottom, 52) + 17
        print("chatHeight:\(chatHeight)")
        //let chatHeight = messageUIView.frame.size.height
        
        //chatScrollView.addSubview(chatUIView)
        chatScrollView.addSubview(messageUIView)
        scrollViewMoveLenght += chatHeight
        print("scrollViewMoveLength: \(scrollViewMoveLenght) -- chatHeight: \(chatHeight)")
        
        let maxHeight = chatScrollView.frame.height
        //NSLog("滚动条的高度\(maxHeight)滚动条的宽度\(chatScrollView.frame.width)")
        
        if((messageHeight + chatHeight) > maxHeight ){
            scrollViewOffLenght += chatHeight
            chatScrollView.contentSize.height += chatHeight
            
            //NSLog("已经超过大小，需要移动了\(scrollViewOffLenght)")
            chatScrollView.setContentOffset(CGPoint(x: 0, y: scrollViewOffLenght), animated: true) //设置位移
        }
        
        messageHeight += chatHeight
        //NSLog("====对话框加载完毕======")
    }
    
    //
    func startRec(){
        
        inRecording = true
        currentSpeechResult = ""
        
        //mic动画
        iconBtn.setImage(micAnimImage, for: .normal)
        
        if (speechResult?.length)!>0 {
            speechResult = ""
        }
        _iflyRecognizerView.startListening()
        recorder?.record()
        timerRec = Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(detectionVoice), userInfo: nil, repeats: true)
    }
    
    func stopRec(){
        _iflyRecognizerView.stopListening()
        inRecording = false
        recorder?.deleteRecording()
        recorder?.stop()
        timerRec?.invalidate()
    }
    
    func finishRecording(success: Bool) {
        recorder?.stop()
    }
    
    @objc func detectionVoice(){
        //micBgview.isHidden = false
        recorder?.updateMeters()
        let ALPHA = 0.05
        let lowPassResults : Double  = pow(10, (ALPHA * Double((recorder?.averagePower(forChannel: 0))!)))
        if(lowPassResults > 0.1){
            //print("detectionVoice: \(lowPassResults)")
            if !ripAnimating {
                ripView.starAnimation()
                ripAnimating = true
            }
        }else{
            if ripAnimating {
                ripView.stopAnimation()
                ripAnimating = false
            }
        }
        
    }
    
    //IFlySpeechSynthesizerDelegate
    func onCompleted(_ error: IFlySpeechError!) {
        print("IFlySpeechError_onCompleted: \(error.description)")
        print("inRecording-onCompleted:\(self.inRecording)")
        if self.inMusicSearching && self.micEnabled {
            self.inMusicSearching = false
            //开始录音
            self.startRec()
        }
    }
    
    //IFlySpeechRecognizerDelegate
    func onResults(_ results: [Any]!, isLast: Bool) {
        let resultString: NSMutableString = ""
        if results != nil {
            let dict = results[0] as! NSDictionary
            for (key,_) in dict {
                resultString.append("\(key)")
            }
            let resultFromJson = ISRDataHelper.string(fromJson: resultString as String!)
            //speechResult = "\(speechResult! as NSString)\(resultFromJson!)" as NSString?
            //speechResult = resultFromJson! as NSString
            print("isLast: \(isLast) - speechResult: \(resultFromJson)")
            if !resultFromJson!.isEmpty {
                currentSpeechResult = currentSpeechResult.appending(resultFromJson!) as NSString
            }
            if isLast {
                //isLast完成语音识别
                print("stopRec?")
                //if !resultFromJson!.isEmpty {
                if currentSpeechResult.length > 0 {
                    stopRec()
                    //解决讯飞识别字符不在ture的状态下
                    //showMessage(showMsg: resultFromJson! as NSString)
                    showMessage(showMsg: currentSpeechResult)
                }
            }
        }
    }
    
    func onVolumeChanged(_ volume: Int32) {
        //if volume > 5 {
        //print("onVolumeChanged: >5 - \(volume)")
        //}
    }
    
    func onError(_ errorCode: IFlySpeechError!) {
        print("IFlySpeechError_onError: \(errorCode)")
        if inRecording && micEnabled {
            //重新开始识别
            startRec()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //AVAudioplayer
    //播放完成后的回调
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        ripView.stopAnimation()
        print("AVAudioplayer 播放完成")
        
        if micEnabled {
            iconBtn.setImage(UIImage(named: "mic.png"), for: .normal)
            //开始录音
            startRec()
        }else{
            iconBtn.setImage(UIImage(named: "mic-muted.png"), for: .normal)
        }
        
    }
    
    //StreamingKit
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
        //
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
        //
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
        //
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject, with stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
        //
        ripView.stopAnimation()
        print("audioStreamPlayer 播放完成")
        
        if micEnabled {
            iconBtn.setImage(UIImage(named: "mic.png"), for: .normal)
            //开始录音
            startRec()
        }else{
            iconBtn.setImage(UIImage(named: "mic-muted.png"), for: .normal)
        }
        
    }
    
    func audioPlayer(_ audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
        //播放在线歌曲出错
        print("StreamingKit-playError:\(errorCode)")
    }
    
}


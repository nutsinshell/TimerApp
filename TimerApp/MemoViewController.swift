import UIKit
import RealmSwift
import SVProgressHUD
import GoogleMobileAds  //ad

class MemoViewController: UIViewController, UITextFieldDelegate,GADBannerViewDelegate{
    
    
    @IBOutlet weak var displayTime: UITextField!
    @IBOutlet weak var displayMemo: UITextView!
    @IBOutlet weak var maxTimeNotification: UILabel!
    
    
    let realm = try! Realm()
    var isNew:Bool = true
    var maxTime:Int = 0
    
    var memoTask:MemoTask!
    var memoTasks = try! Realm().objects(MemoTask.self)
    //    MemoViewControllerでmemoTasksを使うために、Realmからデータをもらい、InputViewControllerから遷移するときにmemoTasksをもらう
    var isSaved:Bool = false
    //    saveされたかどうか判別
    
    let AdMobID = "ca-app-pub-9723884147061848/1352923088"     //ad
    let TEST_ID = "ca-app-pub-9723884147061848/1352923088"      //ad
    let AdMobTest:Bool = false  //ad
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        displayTime.delegate = self
        displayTime.text = "\(memoTask.displayTime)"
        displayMemo.text = memoTask.displayMemo
        
        self.displayTime.keyboardType = UIKeyboardType.numberPad
        
        print(maxTime)
        
        maxTimeNotification.text = "所要時間は" + String(maxTime) + "分です"
        
        //    戻るボタンを消す
        self.navigationItem.hidesBackButton = true
        
        //以下ad用追加
        print("Google Mobile Ads SDK version: \(GADRequest.sdkVersion())")
        
        var admobView = GADBannerView()
        
        admobView = GADBannerView(adSize:kGADAdSizeBanner)
        admobView.frame.origin = CGPoint(x:0, y:self.view.frame.size.height - admobView.frame.height)
        admobView.frame.size = CGSize(width:self.view.frame.width, height:admobView.frame.height)
        
        if AdMobTest {
            admobView.adUnitID = "ca-app-pub-9723884147061848/1352923088"
        }
        else{
            admobView.adUnitID = AdMobID
        }
        
        admobView.rootViewController = self
        admobView.load(GADRequest())
        
        self.view.addSubview(admobView)
        //ad用追加ここまで
        
    }
    
    
    @IBAction func saveButton(_ sender: UIButton) {
        let displayTime = self.displayTime.text!
        let displayMemo = self.displayMemo.text!
        
        if displayTime == "" {
            print("テスト")
            SVProgressHUD.showError(withStatus: "時間を入力して下さい")
            return
        }
        
        for memo in memoTasks {
            if memo.taskId == memoTask.taskId {
                if memo.displayTime == Int(displayTime) && isNew {
                    print("テスト")
                    SVProgressHUD.showError(withStatus: "その時間はすでに登録されています。")
                    return
                }
            }
        }
        
        if Int(displayTime)! > maxTime {
            print("テスト")
            SVProgressHUD.showError(withStatus: "所要時間より先のメモは登録できません。")
            return
        }
        
        try! realm.write {
            self.memoTask.displayTime = Int(displayTime)!
            self.memoTask.displayMemo = displayMemo
            self.realm.add(self.memoTask, update: true)
        }
        SVProgressHUD.showSuccess(withStatus: "保存しました")
        
        if self.presentingViewController != nil  {
            //モーダルの処理
            self.dismiss(animated: true, completion: nil)
        } else {
            //ナビゲーションの処理
            self.navigationController?.popViewController(animated : true)
        }
        
        //        var isSaved = true
        //        self.navigationController?.popViewController(animated : true)
        //        一つ前に戻る（rootに戻るとかインデックスを指定して戻るやり方もある）
        
        
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        
        if  isSaved == false {
            let alert: UIAlertController = UIAlertController(title: "メモは保存されていません", message: "編集内容を破棄しますか？", preferredStyle:  UIAlertControllerStyle.alert)
            
            let defaultAction: UIAlertAction = UIAlertAction(title: "破棄する", style: UIAlertActionStyle.destructive, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                
                if self.presentingViewController != nil  {
                    //モーダルの処理
                    self.dismiss(animated: true, completion: nil)
                } else {
                    //ナビゲーションの処理
                    self.navigationController?.popViewController(animated : true)
                }
                
            })
            // キャンセルボタン
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("Cancel")
                return
            })
            
            // ③ UIAlertControllerにActionを追加
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            
            // ④ Alertを表示
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //    戻るで自動的に保存（チェックなし）
    //    override func viewWillDisappear(_ animated: Bool) {
    //        try! realm.write {
    //            self.memoTask.displayTime = self.displayTime.text!
    //            self.memoTask.displayMemo = self.displayMemo.text
    //            self.realm.add(self.memoTask, update: true)
    //        }
    //
    //        super.viewWillDisappear(animated)
    //
    //    }
    
    //    アドバンスバーション（前半）
    //    func numberDesuka(s: String) -> Bool {
    //        return Int(s) != nil
    //    }
    
    //  ↓textFieldはdelegateすることで使えるようになるので,displayTime.delegate = selfしておかないと無効
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString str: String) -> Bool {
        return Int(str) != nil || str.isEmpty
        
        //        自動的にtrueかfalseか判断して答えを吐き出す
        //        ↓これも同じ意味
        //        if Int(str) == nil {
        //            return false
        //        }
        //
        //        return true
        //
        //
        //         アドバンスバーション（後半）
        //        return numberDesuka(s: str)
    }
    
    func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
}


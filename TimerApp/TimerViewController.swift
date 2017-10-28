
import UIKit
import RealmSwift

class TimerViewController: UIViewController,UITextFieldDelegate {
    
    
    @IBOutlet weak var timerTitle: UILabel!
    @IBOutlet weak var timerTime: UILabel!
    @IBOutlet weak var timerMemo: UITextView!
    @IBOutlet weak var startTimeInput: UITextField!
    @IBOutlet weak var timerLabel: UILabel!
    
    
    
    let realm = try! Realm()
    
    var labelInput = try! Realm().objects(Task.self).sorted(byKeyPath: "id", ascending: false)
    
    //    タイトルと時間を受け取るための変数
    //    var task: Task!
    var taskId = 0
    var titleStr = ""
    var timeStr = 0
    
    
    //    タイマー用の変数やラベルなど
    var count : Float = 0
    //    var myLabel : UILabel!
    var timer: Timer!
    //    メモを呼び出す用
    //    var memoTaskArray : Results<MemoTask>?
    var memoTaskArray = try! Realm().objects(MemoTask.self).sorted(byKeyPath: "memoId")
    //    TaskArrayに一覧をもらう。indexもつけなきゃいけない？
    var memoTime = ""
    //    メモの表示時間
    var index = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timerTitle.text = titleStr
        timerTime.text = "所要時間" + String(timeStr) + "分"
        UIApplication.shared.isIdleTimerDisabled = true
        //       画面がスリープしないようにする
        
        
        if memoTaskArray.count > 0 {
            memoTime = String(memoTaskArray[index].displayTime)
        }
        //初期値の設定 `memoTaskArray` が空じゃないときだけアクセスする
        
        
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        self.startTimeInput.keyboardType = UIKeyboardType.numberPad
        //        キーボードを数字のみにする
        startTimeInput.delegate = self
        //        さらにコピペの入力制限のためdelegate有効化
    }
    
    @IBAction func startTimer(_ sender: Any) {
        dismissKeyboard()
        if (count == 0) {
            if let startTime = Int(startTimeInput.text!) {
                self.count = Float(startTime * 60)  //startTime
                
                self.memoTaskArray = try! Realm().objects(MemoTask.self).sorted(byKeyPath: "memoId").filter("taskId= %ld && displayTime >= %d", taskId, startTime)
                index = 0
                if memoTaskArray.count > 0 {
                    memoTime = String(memoTaskArray[index].displayTime)
                }
            }
            if Int(count) > Int(timeStr * 60) {
                timerLabel.backgroundColor = UIColor(red: 1.0, green: 0.8, blue: 1.0, alpha:1.0)
            }
            //            }else{
            //            timerLabel.backgroundColor = UIColor.white
            //        }
        }
        
        if self.timer == nil{
            // タイマーを作る
            self.timer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(TimerViewController.onUpdate(timer:)),
                userInfo: nil,
                repeats: true
            )
        }
    }
    
    
    
    @IBAction func pauseTimer(_ sender: Any) {
        dismissKeyboard()
        if self.timer != nil {
            // タイマーを破棄
            self.timer.invalidate()      // 現在のタイマーを破棄する
            self.timer = nil        // startTimer() の timer == nil で判断するために、 timer = nil としておく
        }
    }
    
    
    @IBAction func resetTimer(_ sender: Any) {
        dismissKeyboard()
        // リセットボタンを押すと、タイマーの時間を0に＆メモもリセット
        self.count = 0
        self.timerLabel.text = String("00:00:00")
        startTimeInput.text = ""
        self.memoTaskArray = try! Realm().objects(MemoTask.self).sorted(byKeyPath: "memoId").filter("taskId= %ld",taskId)
        
        index = 0
        
        timerMemo.text = " ここにメモが表示されます"
        if memoTaskArray.count > 0 {
            let nextMemoTask = memoTaskArray[index]
            //次の表示時間をセットして上書き
            memoTime = String(nextMemoTask.displayTime)
        }
        if self.timer != nil {
            self.timer.invalidate()
            // 現在のタイマーを破棄する
            self.timer = nil
            // startTimer() の timer == nil で判断するために、 timer = nil としておく
        }
        timerLabel.backgroundColor = UIColor.white
    }
    
    func timerCounter(timer : Timer) {
        let hour = Int(count / 60 / 60)
        // fmod() 余りを計算
//        let minute = Int(count / 60)
        let minute = Int(count) % 3600 / 60
        // currentTime/60 の余り
        let second = Int(count) % 60
        // %02d： ２桁表示、0で埋める
        let totalTimeString = String(format: "%02d:%02d:%02d",hour, minute, second)
        
        timerLabel.text = totalTimeString;
        
        
        let totalCountInMinutes = Int(count / 60) // Int(count)
        
        
        if let memoTimeValue = Int(memoTime), memoTimeValue <= totalCountInMinutes {
            if index < memoTaskArray.count {
                let memoTask = memoTaskArray[index]
                timerMemo.text = memoTask.displayMemo
            }
            index += 1
            if index < memoTaskArray.count {
                let nextMemoTask = memoTaskArray[index]
                //次の表示時間をセットして上書き
                memoTime = String(nextMemoTask.displayTime)
            }
            
            
            //  60秒を超えた時の表示
            
            let newMinute = Int(Int(memoTime)! / 60)
            if (newMinute > 1) &&  (minute == newMinute){
                let newSecond = Int(Int(memoTime)! % 60)
                memoTime = String(newSecond)
            
//            let newHour = Int(Int(memoTime)! / 60)
//            if (newHour > 1) &&  (hour == newHour){
//                let newminute = Int(Int(memoTime)! % 60)
//                memoTime = String(newminute)
            
            }
            
        }
        
    }
    
    // TimerのtimeIntervalで指定された秒数毎に呼び出されるメソッド
    func onUpdate(timer : Timer){
        
        
        timerCounter(timer: timer) // カウントの値が増加されてない状態
        count += 1      // カウントの値1増加
        
        if Int(count) > Int(timeStr * 60) {
            timerLabel.backgroundColor = UIColor(red: 1.0, green: 0.8, blue: 1.0, alpha:1.0)
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString str: String) -> Bool {
        
        return textField === startTimeInput && Int(str) != nil || str.isEmpty
    }   //数字以外のコピペ禁止
    
    
    func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //        画面スリープ停止を解除
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
}


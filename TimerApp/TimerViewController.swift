
import UIKit
import RealmSwift

class TimerViewController: UIViewController {
    
    
    @IBOutlet weak var timerTitle: UILabel!
    @IBOutlet weak var timerTime: UILabel!
    @IBOutlet weak var timerMemo: UITextView!
    
    
    let realm = try! Realm()
    
    var labelInput = try! Realm().objects(Task.self).sorted(byKeyPath: "id", ascending: false)
    
//    タイトルと時間を受け取るための変数
    var task: Task!
    var titleStr = ""
    var timeStr = ""
    
//    タイマー用の変数やラベルなど
    var count : Float = 0
    var myLabel : UILabel!
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
        // ラベルを作る
        myLabel = UILabel(frame: CGRect(x:0,y:0,width:300,height:100))
        // ラベルの色
        myLabel.backgroundColor = UIColor.orange
        // 表示させるテキスト
        myLabel.text = String("00:00:00")
        myLabel.font =  myLabel.font?.withSize(50)
        // テキストの色
        myLabel.textColor = UIColor.white
        // テキストを中央寄せ
        myLabel.textAlignment = NSTextAlignment.center
        // ラベルの位置
        myLabel.layer.position = CGPoint(x: self.view.bounds.width/2,y: 200)
        self.view.addSubview(myLabel)
        
        timerTitle.text = titleStr
        timerTime.text = timeStr
        
        if memoTaskArray.count > 0 {
        memoTime = memoTaskArray[index].displayTime
        }
        //初期値の設定 `memoTaskArray` が空じゃないときだけアクセスする
        
    }
    
    
    @IBAction func startTimer(_ sender: Any) {
        if self.timer == nil {
        // タイマーを作る
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerViewController.onUpdate(timer:)), userInfo: nil, repeats: true)
        // タイマーが開始された日時
        }
    }
    
    @IBAction func pauseTimer(_ sender: Any) {
        if self.timer != nil {
        // タイマーを破棄
        self.timer.invalidate()
        self.timer = nil
        }
    }
        
   
    
    @IBAction func resetTimer(_ sender: Any) {
        // リセットボタンを押すと、タイマーの時間を0に＆メモもリセット
        self.count = 0
        self.myLabel.text = String("00:00:00")
        self.memoTaskArray = try! Realm().objects(MemoTask.self).sorted(byKeyPath: "memoId")
        index = 0
        timerMemo.text = "ここにメモが表示されます"
        let nextMemoTask = memoTaskArray[index]
        //次の表示時間をセットして上書き
        memoTime = nextMemoTask.displayTime

        
        
        if self.timer != nil {
            self.timer.invalidate()
            // 現在のタイマーを破棄する
            self.timer = nil
            // startTimer() の timer == nil で判断するために、 timer = nil としておく
            
            

        }
    }
    
    func timerCounter(timer : Timer) {
        let hour = Int(count / 60 / 60)
        // fmod() 余りを計算
        let minute = Int(count / 60)
        // currentTime/60 の余り
        let second = Int(count) % 60
        // %02d： ２桁表示、0で埋める
        let totalTimeString = String(format: "%02d:%02d:%02d",hour, minute, second)
        myLabel.text = totalTimeString;
                
        
        if let memoTimeValue = Int(memoTime), memoTimeValue <= second {
            if index < memoTaskArray.count {
                let memoTask = memoTaskArray[index]
                timerMemo.text = memoTask.displayMemo
            }
            index += 1
            if index < memoTaskArray.count {
                let nextMemoTask = memoTaskArray[index]
                //次の表示時間をセットして上書き
                memoTime = nextMemoTask.displayTime
            }
        }
    }
    
    
    // TimerのtimeIntervalで指定された秒数毎に呼び出されるメソッド
    func onUpdate(timer : Timer){
        
        // カウントの値1増加
        count += 1
        timerCounter(timer: timer)
    }

    
}



//私の

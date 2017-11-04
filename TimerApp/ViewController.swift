

import UIKit
import RealmSwift
import GoogleMobileAds  //ad

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,GADBannerViewDelegate{
    @IBOutlet weak var listTableView: UITableView!
    // Realmインスタンスを取得する
    let realm = try! Realm()    // DB内のタスクが格納されるリスト。
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "updatedAt", ascending:false)
    
    let AdMobID = "ca-app-pub-9723884147061848/1352923088"     //ad
    let TEST_ID = "ca-app-pub-9723884147061848/1352923088"      //ad
    let AdMobTest:Bool = false  //ad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listTableView.delegate = self
        listTableView.dataSource = self
        
        listTableView.estimatedRowHeight = 30
        listTableView.rowHeight = UITableViewAutomaticDimension
        
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // Cellに値を設定する.
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        cell.detailTextLabel?.text = ("【\(task.time)分】")
        return cell
    }
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            // データベースから削除する  // ←以降追加する
            
            try! realm.write {
                let task = self.taskArray[indexPath.row]
                let memoTaskArray = try! Realm().objects(MemoTask.self).filter("taskId= %ld", task.id)
                
                self.realm.delete(memoTaskArray)
                self.realm.delete(task)
                
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
            }
        }
        
    }
    // segue で画面遷移するに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.listTableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        
        } else {
            let task = Task()
            task.time = 0
            
            if taskArray.count != 0 {
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
        
//        print(inputViewController.task.id)
    }
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listTableView.reloadData()
    }
    
}

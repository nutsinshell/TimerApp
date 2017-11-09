

import UIKit
import Firebase //AdMobのため追加
import GoogleMobileAds

//    最前面のViewを取得
extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
//    取得コードここまで

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()  //AdMobのため追加
        GADMobileAds.configure(withApplicationID:"ca-app-pub-9723884147061848~7947440960")
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // バックグラウンド処理
        // 1. タイマーを止める
        // 2. タイマーの残り時刻を記録
        // 3. バックグランド移行する時の時刻を記録
        
        if let topController = UIApplication.topViewController() as? TimerViewController {
            topController.pause()
        }
        
        //        保存のためのメソッド、set(_:forKey:)で"backgroundTimeInterval"に保存
        
        
        // 4. タイマー終了や途中のお知らせのためのローカル通知登録処理をここで行う
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // フォアグラウンドになる直前の処理
        // 1. まだ実行されていないローカル通知を削除　（ローカル通知なければ不要）r
        // 2. 経過時間を計算する
        
        
        if let topController = UIApplication.topViewController() as? TimerViewController {
            // 行いたい処理
            topController.restart()
        }
        // 3. タイマー残り時刻から、タイマーを再スタートする
    }
    
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // アクティブになった時の処理。今回はapplicationWillEnterForegroundを使うので不要
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}


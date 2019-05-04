import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,URLSessionDataDelegate, URLSessionDelegate {
    
    var tableView1: UITableView!
    var textfield1: UITextField!
    var btnAdd1: UIButton!
    
    var tableView2: UITableView!
    var textfield2: UITextField!
    var btnAdd2: UIButton!
    
    var btnOfflineMode: UIButton!
    var btnOnlineMode: UIButton!
    var textfieldIndex: UITextField!
    
    var strings1: [String] = []
    var strings2: [String] = []
    
    var alertControllerTableEditor: UIAlertController?
    var alertControllerIndexChecker: UIAlertController!
    var alertControllerAnswer: UIAlertController!
    var answer:Int = 0
    
    var editedIndex = -1
    var session: URLSession!
    var data:Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let margin:CGFloat = 5
        textfieldIndex = UITextField(frame: CGRect(x: view.frame.maxX/4, y: view.frame.maxY/16, width:view.frame.maxX/4, height: 30))
        textfieldIndex.placeholder = "Index Of Sorted Array"
        textfieldIndex.borderStyle = .roundedRect
        textfieldIndex.keyboardType = .decimalPad
        view.addSubview(textfieldIndex)
        
        btnOfflineMode = UIButton(type: .system)
        btnOfflineMode.setTitle("Offline Sort", for: .normal)
        btnOfflineMode.addTarget(self, action: #selector(btnOfflineMode(sender:)), for: .touchUpInside)
        btnOfflineMode.frame = CGRect(x:textfieldIndex.frame.maxX + margin, y: textfieldIndex.frame.minY, width: textfieldIndex.frame.width/2, height: textfieldIndex.frame.height)
        view.addSubview(btnOfflineMode)
        
        btnOnlineMode = UIButton(type: .system)
        btnOnlineMode.setTitle("Online Sort", for: .normal)
        btnOnlineMode.addTarget(self, action: #selector(btnOnlineMode(sender:)), for: .touchUpInside)
        btnOnlineMode.frame = CGRect(x:btnOfflineMode.frame.maxX + margin, y: textfieldIndex.frame.minY, width: textfieldIndex.frame.width/2, height: textfieldIndex.frame.height)
        view.addSubview(btnOnlineMode)
        
        tableView1 = UITableView(frame: CGRect(x: margin, y: view.frame.maxY/8, width: view.frame.width/2 - margin*2, height: view.frame.maxY/2 - margin*10), style: .plain)
        tableView1.dataSource = self
        tableView1.delegate = self
        tableView1.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "tableView1")
        
        view.addSubview(tableView1)
        let btnAdd1Width: CGFloat = 100
        textfield1 = UITextField(frame: CGRect(x: margin, y: tableView1.frame.maxY + margin, width: tableView1.frame.maxX - margin*2 - btnAdd1Width - margin, height: 30))
        textfield1.placeholder = "type your number..."
        textfield1.borderStyle = .roundedRect
        textfield1.keyboardType = .decimalPad
        view.addSubview(textfield1)
        
        btnAdd1 = UIButton(type: .system)
        btnAdd1.setTitle("add", for: .normal)
        btnAdd1.addTarget(self, action: #selector(btnAdd1Clicked(sender:)), for: .touchUpInside)
        btnAdd1.frame = CGRect(x: textfield1.frame.maxX + margin, y: textfield1.frame.origin.y, width: btnAdd1Width, height: textfield1.frame.height)
        view.addSubview(btnAdd1)
        
        tableView2 = UITableView(frame: CGRect(x:tableView1.frame.maxX, y: tableView1.frame.minY, width: view.frame.maxX/2 - margin*2, height:tableView1.frame.height), style: .plain)
        tableView2.dataSource = self
        tableView2.delegate = self
        tableView2.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "tableView2")
        view.addSubview(tableView2)
        
        let btnAdd2Width: CGFloat = 100
        textfield2 = UITextField(frame: CGRect(x: tableView1.frame.maxX, y: tableView2.frame.maxY + margin,width: tableView2.frame.width - margin*2 - btnAdd1Width - margin, height: 30))
        textfield2.placeholder = "type your number..."
        textfield2.borderStyle = .roundedRect
        textfield2.keyboardType = .decimalPad
        view.addSubview(textfield2)
        
        btnAdd2 = UIButton(type: .system)
        btnAdd2.setTitle("add", for: .normal)
        btnAdd2.addTarget(self, action: #selector(btnAdd2Clicked(sender:)), for: .touchUpInside)
        btnAdd2.frame = CGRect(x: textfield2.frame.maxX + margin, y: textfield2.frame.origin.y, width: btnAdd2Width, height: textfield2.frame.height)
        view.addSubview(btnAdd2)
        
    }
    func getData(array:[String], string: String)->Data{
        let dictionary: [String:Any] = ["sortThis":array, "indexNumber":string]
        do{
            return try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        }catch{
            fatalError("getData error!")
        }
    }
    
    @objc func btnOnlineMode(sender: UIButton){
        if !(textfieldIndex.text ?? "").isEmpty && (strings1.count + strings2.count >= Int(textfieldIndex.text!)!) {
            //Server http req
            let sortArray :[String] = strings1+strings2
            session = URLSession(configuration: URLSessionConfiguration.default)
            let urlString:String = "http://192.168.1.142:8080/abed_servlet"
            let url = URL(string: urlString)
            var urlRequest = URLRequest(url: url!)
            urlRequest.httpMethod = "POST"
            data = getData(array: sortArray, string:textfieldIndex.text!)
            let task = session.uploadTask(with: urlRequest, from: data) { (data: Data?, response: URLResponse?, error: Error?) in
                if error == nil{
                    if let data = data{
                        let s = String(data: data, encoding: String.Encoding.utf8)
                        self.answer = Int(s!)!
                    }
                }else{
                    print("nil there is an error")
                }
                self.session.finishTasksAndInvalidate()
            }
            task.resume()
            sleep(1)
            alertControllerShowAnswer()
        }
        else{
            errorAlertController()
        }
    }
    @objc func btnOfflineMode(sender: UIButton){
        if !(textfieldIndex.text ?? "").isEmpty && (strings1.count + strings2.count >= Int(textfieldIndex.text!)!){
            var sortArray :[String] = strings1+strings2
            sortArray = mergeSort(sortArray)
            answer = Int(sortArray[Int(textfieldIndex.text!)!-1])!
            alertControllerShowAnswer()
        }
        else{
            errorAlertController()
        }
    }
    @objc func btnAdd1Clicked(sender: UIButton){
        let string = textfield1.text!
        if !string.isEmpty{
            strings1.append(string)
            tableView1.reloadData()
            textfield1.text = ""
            tableView1.scrollToRow(at: IndexPath(row: strings1.count-1, section: 0), at: .bottom, animated: true)
        }
    }
    @objc func btnAdd2Clicked(sender: UIButton){
        let string = textfield2.text!
        if !string.isEmpty{
            strings2.append(string)
            tableView2.reloadData()
            textfield2.text = ""
            tableView2.scrollToRow(at: IndexPath(row: strings2.count-1, section: 0), at: .bottom, animated: true)
        }
    }
    func errorAlertController() -> Void{
        if alertControllerIndexChecker == nil{
            alertControllerIndexChecker = UIAlertController(title:"Error", message: "Number must be between 1 < \(strings1.count + strings2.count)", preferredStyle: .alert)
            let actionOkIGotIt = UIAlertAction(title: "Ok I Got It", style: .default)
            alertControllerIndexChecker!.addAction(actionOkIGotIt)
        }
        else{
            alertControllerIndexChecker.message = "Number must be between 1 < \(strings1.count + strings2.count)"
        }
        textfieldIndex.text = ""
        present(alertControllerIndexChecker!, animated: true, completion: nil)
    }
    func alertControllerShowAnswer() -> Void {
        if alertControllerAnswer == nil{
            alertControllerAnswer = UIAlertController(title:"Answer", message: "Postion: \(Int(textfieldIndex.text!)!) Of Sorted Array Has A Value Of \(answer)", preferredStyle: .alert)
            let actionOkIGotIt = UIAlertAction(title: "Ok Thanks", style: .default)
            alertControllerAnswer!.addAction(actionOkIGotIt)
        }
        else{
            alertControllerAnswer.message = "Number At Postion: \(Int(textfieldIndex.text!)!) Has A Value Of \(answer)"
        }
        textfieldIndex.text = ""
        present(alertControllerAnswer!, animated: true, completion: nil)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView1.isEqual(tableView){
            return strings1.count
        }
        return strings2.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView1.isEqual(tableView){
            let cell = tableView1.dequeueReusableCell(withIdentifier: "tableView1", for: indexPath)
            cell.textLabel!.text = strings1[indexPath.row]
            return cell
        }
        else{
            let cell = tableView2.dequeueReusableCell(withIdentifier: "tableView2", for: indexPath)
            cell.textLabel!.text = strings2[indexPath.row]
            return cell
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView1.isEqual(tableView){
            return "Array 1"
        }
        else {
            return "Array 2"
        }
    }
    func tableView(tableViewTemp tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView1.isEqual(tableView){
            if editingStyle == .delete {
                print("Deleted")
                self.strings1.remove(at: indexPath.row)
                self.tableView1.deleteRows(at: [indexPath], with: .automatic)
                self.tableView1.reloadData()
            }
        }
        else {
            if editingStyle == .delete {
                print("Deleted")
                self.strings2.remove(at: indexPath.row)
                self.tableView2.deleteRows(at: [indexPath], with: .automatic)
                self.tableView2.reloadData()
            }
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView1.isEqual(tableView){
            if alertControllerTableEditor == nil{
                alertControllerTableEditor = UIAlertController(title: "Edit", message: "edit your number:", preferredStyle: .alert)
                alertControllerTableEditor!.addTextField(configurationHandler: nil)
                let actionDone = UIAlertAction(title: "Done", style: .default) { (action: UIAlertAction) in
                    let string = self.alertControllerTableEditor!.textFields![0].text!
                    if !string.isEmpty{
                        self.strings1[self.editedIndex] = string
                        self.tableView1.reloadData()
                    }
                }
                alertControllerTableEditor!.addAction(actionDone)
            }
            editedIndex = indexPath.row
            alertControllerTableEditor!.textFields![0].text = strings1[editedIndex]
            present(alertControllerTableEditor!, animated: true, completion: nil)
        }
        else {
            if alertControllerTableEditor == nil{
                alertControllerTableEditor = UIAlertController(title: "Edit", message: "edit your number:", preferredStyle: .alert)
                alertControllerTableEditor!.addTextField(configurationHandler: nil)
                let actionDone = UIAlertAction(title: "Done", style: .default) { (action: UIAlertAction) in
                    let string = self.alertControllerTableEditor!.textFields![0].text!
                    if !string.isEmpty{
                        self.strings2[self.editedIndex] = string
                        self.tableView2.reloadData()
                    }
                }
                alertControllerTableEditor!.addAction(actionDone)
            }
            editedIndex = indexPath.row
            alertControllerTableEditor!.textFields![0].text = strings2[editedIndex]
            present(alertControllerTableEditor!, animated: true, completion: nil)
        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView1.isEqual(tableView){
            if editingStyle == UITableViewCell.EditingStyle.delete {
                strings1.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            }
        }
        else {
            if editingStyle == UITableViewCell.EditingStyle.delete {
                strings2.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            }
        }
    }
    func mergeSort<T: Comparable>(_ array: [T]) -> [T] {
        guard array.count > 1 else { return array }
        let middleIndex = array.count / 2
        let leftArray = mergeSort(Array(array[0..<middleIndex]))
        let rightArray = mergeSort(Array(array[middleIndex..<array.count]))
        return merge(leftArray, rightArray)
    }
    func merge<T: Comparable>(_ left: [T], _ right: [T]) -> [T] {
        var leftIndex = 0
        var rightIndex = 0
        var orderedArray: [T] = []
        while leftIndex < left.count && rightIndex < right.count {
            let leftElement = left[leftIndex]
            let rightElement = right[rightIndex]
            
            if leftElement < rightElement {
                orderedArray.append(leftElement)
                leftIndex += 1
            } else if leftElement > rightElement {
                orderedArray.append(rightElement)
                rightIndex += 1
            } else {
                orderedArray.append(leftElement)
                leftIndex += 1
                orderedArray.append(rightElement)
                rightIndex += 1
            }
        }
        while leftIndex < left.count {
            orderedArray.append(left[leftIndex])
            leftIndex += 1
        }
        while rightIndex < right.count {
            orderedArray.append(right[rightIndex])
            rightIndex += 1
        }
        return orderedArray
    }
}

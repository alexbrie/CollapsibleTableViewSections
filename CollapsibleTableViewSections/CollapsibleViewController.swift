//: [Previous](@previous)

import UIKit


// MARK: VC
@objc class ControllerDataModel : NSObject {
    var sectionNames: [String]
    var contentsNames : [[String]]
    var filters: [[String: Any]]
    init(filters fil: [[String: Any]]) {
        filters = fil
        sectionNames = filters.flatMap {$0["name"] as? String}
        contentsNames = filters.flatMap {
            ($0["values"] as! [[String:Any]]).flatMap{$0["label"] as? String}
        }
    }
    convenience init(jsonName: String) {
        let valuesList = JSONFileTools.loadJsonByName(jsonName)  as! [String: Any]
        
        self.init(filters: valuesList["filters"] as! [[String: Any]])
    }
}


class CollapsibleViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView : UITableView!
    // CollapsableTableViewSections
    var dataModel: ControllerDataModel? {
        didSet {
            tableView?.reloadData()
        }
    }
    
    var expandedSectionHeader : CollapsibleSectionHeaderView?
    var tableViewHeader : UIView!
    
    func buildTableViewHeader() -> UIView {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 56))
        header.backgroundColor = CommonColors.BackgroundColor
        
        let line = UIView(frame: .zero)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = CommonColors.NeutralGray
        header.addSubview(line)
        
        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: line.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: line.trailingAnchor),
            header.bottomAnchor.constraint(equalTo: line.bottomAnchor),
            line.heightAnchor.constraint(equalToConstant: 1.0),
            ])
        
        let label = UILabel()
        label.font = FontBuilder.font(20)
        label.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(label)
        label.text = "Filters"
        label.textColor = CommonColors.TextDarkest
        
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: label.topAnchor),
            header.leadingAnchor.constraint(equalTo: label.leadingAnchor, constant: -16),
            header.trailingAnchor.constraint(equalTo: label.trailingAnchor),
            header.bottomAnchor.constraint(equalTo: label.bottomAnchor),
            ])
        return header
    }
    
    func buildTableView() {
        tableView = UITableView(frame: .zero)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundView?.backgroundColor = CommonColors.BackgroundColor

        self.tableViewHeader = buildTableViewHeader()
        tableView.tableHeaderView = tableViewHeader

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            self.view.trailingAnchor.constraint(equalTo: self.tableView.trailingAnchor),
            self.view.bottomAnchor.constraint(equalTo: self.tableView.bottomAnchor),
            self.view.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor),
            self.view.topAnchor.constraint(equalTo: self.tableView.topAnchor)
            ])
    }
    
    func loadData() {
        self.dataModel = ControllerDataModel(jsonName: "mock_values")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildTableView()
        
        // load data
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - table view
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let ds = dataModel else {return 0}
        return ds.sectionNames.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let ds = dataModel else {return 0}
        if self.expandedSectionHeader?.section == section {
            return ds.contentsNames[section].count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let ds = dataModel else {return nil}
        var header : CollapsibleSectionHeaderView?
        
        if let hv = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleSectionHeaderView {
            header = hv
        }
        else {
            header = CollapsibleSectionHeaderView.buildHeaderView(width: tableView.bounds.size.width, section: section, reuseIdentifier: "header")
        }
        
        header?.label.text = ds.sectionNames[section]
        header?.section = section
        return header
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        cell = tableView.dequeueReusableCell(withIdentifier: "foo")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value2, reuseIdentifier: "foo")
        }
        guard let ds = dataModel else {return cell!}
        cell!.textLabel?.font = FontBuilder.font(14)
        cell!.textLabel?.text = ds.contentsNames[indexPath.section][indexPath.row]
        
        cell!.detailTextLabel?.font = FontBuilder.font(12)
        cell!.detailTextLabel?.text = ds.contentsNames[indexPath.section][indexPath.row]
        return cell!
    }
    
    static let kHeaderSectionTag = 1000
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: -
class CollapsibleSectionHeaderView : UITableViewHeaderFooterView {
    var section: NSInteger = -1
    var label: UILabel!
    var line: UIView!
    var chevron: UIImageView!
    
    class func buildHeaderView(width: CGFloat, section: Int, reuseIdentifier: String?) -> CollapsibleSectionHeaderView {
        let header = CollapsibleSectionHeaderView(reuseIdentifier: reuseIdentifier)
  
        let bgColorView = UIView(frame: .zero)
        bgColorView.translatesAutoresizingMaskIntoConstraints = false
        bgColorView.backgroundColor = CommonColors.BackgroundColor
        header.addSubview(bgColorView)
        
        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: bgColorView.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: bgColorView.trailingAnchor),
            header.bottomAnchor.constraint(equalTo: bgColorView.bottomAnchor),
            header.topAnchor.constraint(equalTo: bgColorView.topAnchor),
            ])

        header.tag = CollapsibleViewController.kHeaderSectionTag + section
        
        let line = UIView(frame: .zero)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = CommonColors.NeutralGray
        header.addSubview(line)
        header.line = line
        header.line.isHidden = true
        
        NSLayoutConstraint.activate([
            header.leadingAnchor.constraint(equalTo: line.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: line.trailingAnchor),
            header.bottomAnchor.constraint(equalTo: line.bottomAnchor),
            line.heightAnchor.constraint(equalToConstant: 1.0),
            ])
        
        let chevron = UIImageView(frame: CGRect(x: 0, y: 0, width: 12, height: 8))
        chevron.image = UIImage(named: "chevron_down")
        chevron.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(chevron)
        header.chevron = chevron
        
        let label = UILabel()
        label.font = FontBuilder.font(18)
        label.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(label)
        header.label = label
        
        NSLayoutConstraint.activate([
            header.centerYAnchor.constraint(equalTo: chevron.centerYAnchor),
            header.trailingAnchor.constraint(equalTo: chevron.trailingAnchor, constant: 16),
            header.topAnchor.constraint(equalTo: label.topAnchor),
            header.leadingAnchor.constraint(equalTo: label.leadingAnchor, constant: -16),
            header.trailingAnchor.constraint(equalTo: label.trailingAnchor),
            header.bottomAnchor.constraint(equalTo: label.bottomAnchor),
            ])
        return header
    }
    
    func collapse(isLast: Bool) {
        self.animateChevronRotate()
        if !isLast {
            self.line.isHidden = true
        }
    }
    
    func expand(isLast: Bool) {
        self.animateChevronRotate()
        self.line.isHidden = false
    }
    
    private func animateChevronRotate() {
        let animSpeed : TimeInterval = 0.2
        
        UIView.animate(withDuration: animSpeed, animations: {
            self.chevron.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
        })
    }
}

protocol CollapsibleTableViewSections  : class {
    var tableView : UITableView! {get set}
    var dataModel: ControllerDataModel?  {get set}
    var expandedSectionHeader : CollapsibleSectionHeaderView?  {get set}
    
    func tableViewCollapse(_ header: CollapsibleSectionHeaderView?)
    func tableViewExpand(_ header: CollapsibleSectionHeaderView?)
}

extension CollapsibleViewController : CollapsibleTableViewSections {
    @objc func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        prepareCollapsibleHeader(view as? CollapsibleSectionHeaderView, section: section)
    }
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
        handleTapOnHeader(sender.view as? CollapsibleSectionHeaderView)
    }
}

extension CollapsibleTableViewSections where Self: CollapsibleViewController {
    func isLast(section: Int) -> Bool {
        return (section + 1 == dataModel?.sectionNames.count)
    }
    
    func prepareCollapsibleHeader(_ header: CollapsibleSectionHeaderView?, section: Int) {
        guard let header = header else {return}
        header.label.textColor = CommonColors.TextDark
        
        // make headers touchable
        let headerTapGesture = UITapGestureRecognizer()
        headerTapGesture.addTarget(self, action: #selector(CollapsibleViewController.sectionHeaderWasTouched(_:)))
        header.addGestureRecognizer(headerTapGesture)
        if isLast(section: section) {
            header.line.isHidden = false
        }
    }
    
    func handleTapOnHeader(_ header: CollapsibleSectionHeaderView?) {
        guard let header = header else {return}
        
        let previousHeader = self.expandedSectionHeader
        tableViewCollapse(previousHeader)
        
        if (previousHeader != header) {
            tableViewExpand(header)
        }
    }
    
    func tableViewCollapse(_ header: CollapsibleSectionHeaderView?) {
        guard let header = header else {return}
        
        self.expandedSectionHeader = nil
        
        let sectionData = dataModel!.contentsNames[header.section]
        guard sectionData.count > 0 else {return}
        
        let isLastHeader : Bool = isLast(section: header.section)
        header.collapse(isLast: isLastHeader)
        
        var indexesPath = [IndexPath]()
        for i in 0 ..< sectionData.count {
            let index = IndexPath(row: i, section: header.section)
            indexesPath.append(index)
        }
        self.tableView.performBatchUpdates({
            self.tableView!.deleteRows(at: indexesPath, with: .automatic)
        }, completion: nil)
    }
    
    func tableViewExpand(_ header: CollapsibleSectionHeaderView?) {
        guard let header = header else {return}
        let sectionData = dataModel!.contentsNames[header.section]
        guard sectionData.count > 0 else {return}
        
        self.expandedSectionHeader = header
        
        let isLastHeader : Bool = isLast(section: header.section)
        header.expand(isLast: isLastHeader)
        
        var indexesPath = [IndexPath]()
        for i in 0 ..< sectionData.count {
            let index = IndexPath(row: i, section: header.section)
            indexesPath.append(index)
        }
        self.tableView.performBatchUpdates({
            self.tableView!.insertRows(at: indexesPath, with: .automatic)
        }, completion: nil)
    }
}


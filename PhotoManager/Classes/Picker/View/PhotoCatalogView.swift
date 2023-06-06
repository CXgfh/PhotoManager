//
//  PhotoCatalogView.swift
//  PhotoManager
//
//  Created by V on 2023/4/19.
//

import UIKit
import SnapKit
import ContentSizeView

protocol PhotoCatalogDelegate: AnyObject {
    func PhotoCatalogUnselect()
    func PhotoCatalogSelect(at index: Int)
}

class PhotoCatalogView: UIView {
    
    weak var delegate: PhotoCatalogDelegate?
    
    private lazy var tableView: ContentSizeOfTableView = {
        let table = ContentSizeOfTableView(maximumDisplayHeight: 300, style: .plain)
        table.separatorStyle = .singleLine
        table.separatorColor = UIColor(photo: "picker_text_color")
        table.indicatorStyle = .default
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = UIColor(photo: "picker_theme_color")
        table.rowHeight = 44
        table.layer.cornerRadius = 8
        table.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        table.register(PhotoTableViewCell.self)
        return table
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == self {
            delegate?.PhotoCatalogUnselect()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoCatalogView {
    func reloadData() {
        tableView.reloadData()
    }
}

extension PhotoCatalogView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PhotoManager.sharde.albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withCellClass: PhotoTableViewCell.self, for: indexPath)
        cell.title = PhotoManager.sharde.albums[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.PhotoCatalogSelect(at: indexPath.row)
    }
}

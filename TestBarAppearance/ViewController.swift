import UIKit

private struct OptionSection {
    let name: String
    var options: [Option]
}

private struct Option: Hashable {
    let option: _Option
    var enabled: Bool

    mutating func toggle() {
        enabled.toggle()
    }
}

private enum _Option {
    case translucent
    case barTintColor
    case edgeExtended

    var name: String {
        switch self {
        case .translucent:
            return "isTranslucent"
        case .barTintColor:
            return "Custom barTintColor"
        case .edgeExtended:
            return "edgesForExtendedLayout"
        }
    }
}

class ViewController: UIViewController {
    private var optionSections: [OptionSection] = [
        .init(name: "Tabbar VC", options: [
            .init(option: .translucent, enabled: true),
            .init(option: .barTintColor, enabled: false),
        ]),
        .init(name: "Navigation VC", options: [
            .init(option: .translucent, enabled: true),
            .init(option: .barTintColor, enabled: false),
        ]),
        .init(name: "Content VC", options: [
            .init(option: .edgeExtended, enabled: true),
        ])
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Large Title"
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(showCustomVC))

        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    @objc private func showCustomVC() {
        let vc = PresentedViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem = .init(title: "Nav", image: .init(systemName: "gearshape"), tag: 0)
        let tab = UITabBarController()
        tab.viewControllers = [nav, tabPlaceholder(), tabPlaceholder()]
        tab.modalPresentationStyle = .fullScreen

        for option in optionSections[0].options {
            switch option.option {
            case .translucent:
                tab.tabBar.isTranslucent = option.enabled
            case .barTintColor:
                tab.tabBar.barTintColor = option.enabled ? .systemOrange : nil
            case .edgeExtended:
                fatalError()
            }
        }

        for option in optionSections[1].options {
            switch option.option {
            case .translucent:
                nav.navigationBar.isTranslucent = option.enabled
            case .barTintColor:
                nav.navigationBar.barTintColor = option.enabled ? .systemOrange : nil
            case .edgeExtended:
                fatalError()
            }
        }

        for option in optionSections[2].options {
            switch option.option {
            case .translucent:
                fatalError()
            case .barTintColor:
                fatalError()
            case .edgeExtended:
                vc.edgesForExtendedLayout = option.enabled ? [.all] : []
            }
        }

        present(tab, animated: true)
    }

    private func tabPlaceholder() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .systemBackground
        vc.tabBarItem = .init(title: "item", image: .init(systemName: "square"), tag: 0)
        return vc
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return optionSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionSections[section].options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let option = optionSections[indexPath.section].options[indexPath.row]

        cell.textLabel?.text = option.option.name
        cell.accessoryType = option.enabled ? .checkmark : .none

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return optionSections[section].name
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        optionSections[indexPath.section].options[indexPath.item].toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

private class PresentedViewController: UIViewController {
    struct Item: Hashable {
        let name: String
    }

    private var dataSource: UICollectionViewDiffableDataSource<Int, Item>!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        navigationItem.title = "Title"
        navigationItem.leftBarButtonItem = .init(barButtonSystemItem: .close, target: self, action: #selector(dismissSelf))

        let layout = UICollectionViewCompositionalLayout.list(using: .init(appearance: .insetGrouped))
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        let registration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            var content = UIListContentConfiguration.cell()
            content.text = item.name
            cell.contentConfiguration = content
        }

        dataSource = UICollectionViewDiffableDataSource<Int, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }

        var snapshot = dataSource.snapshot()
        snapshot.appendSections([0])
        let items: [Item] = (1...30).map { Item(name: "item \($0)")}
        snapshot.appendItems(items, toSection: 0)
        dataSource.apply(snapshot)
    }

    @objc private func dismissSelf() {
        presentingViewController?.dismiss(animated: true)
    }
}

extension UIImage {
    func tintedImage(with tintColor: UIColor) -> UIImage? {
//        - (UIImage *) tintedImageWithColor:(UIColor *)tintColor {
//            UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
//            [tintColor setFill];
//            CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
//            UIRectFill(bounds);
//            [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
//
//            UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
//
//            return tintedImage;
//        }

        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        tintColor.setFill()
        let bounds = CGRect(origin: .zero, size: self.size)
        UIRectFill(bounds)
        self.draw(in: bounds, blendMode: CGBlendMode.destinationIn, alpha: 1)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return tintedImage
    }
}

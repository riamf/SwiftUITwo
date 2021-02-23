//
//  ContentView.swift
//  SwiftUITwo
//
//  Created by Pawel Kowalczuk on 11/02/2021.
//

import SwiftUI

struct Item: Identifiable {
    let id = UUID().uuidString
    let name: String
    let val: String
    let text: String

    static func generate() -> Item {
        let mx = 32
        let r1 = (10...mx).randomElement()!
        let r2 = (10...mx).randomElement()!
        let r3 = (10...mx).randomElement()!

        return Item(name: (0...r1).reduce("", {$0 + "\($1)"}),
                    val: (0...r2).reduce("", {$0 + "\($1)"}),
                    text: (0...r3).reduce("", {$0 + "\($1)"}))
    }
}

func getItems(forceOne: Bool = false) -> [[Item]] {
    if Env.isIPAD && !forceOne {
        return (0...33).map({ _ in [Item.generate(), Item.generate(), Item.generate()] })

    } else {
        return (0...100).map({ _ in [Item.generate()] })
    }
}

struct ContentView: View {
    @State var items = getItems()
    @State var selected = false
    @State var selectedTable: Int? {
        didSet {
            if self.selectedTable != nil {
                var tmp = [[Item]]()
                for ia in self.items {
                    for i in ia {
                        tmp.append([i])
                    }
                }
                self.items = tmp
                self.detailsWidth = UIScreen.main.bounds.width * 0.75
                self.indexPathToSetVisible = IndexPath(row: selectedTable!, section: 0)
            } else {
                // deselecting
                var tmp = [[Item]]()
                for i in stride(from: 0, to: (self.items.count), by: 3) {
                    let s1 = self.items[i][0]
                    let s2 = self.items[i+1][0]
                    let s3 = self.items[i+2][0]
                    tmp += [[s1, s2, s3]]
                }
                self.items = tmp
                self.detailsWidth = 0.0
            }
        }
    }
    @State var detailsWidth: CGFloat = 0.0
    @State var indexPathToSetVisible: IndexPath?

    var body: some View {
        VStack {
            Text("SELECTED ROW #\(String(describing: selectedTable))")
            HStack {
                List(items.indices, id: \.self) { index in
                    Row(model: items[index], idx: index).background(Button("", action: {
                        if self.selectedTable == index {
                            self.selectedTable = nil
                        } else {
                            self.selectedTable = index
                        }
                    })).animation(.default)
                }.overlay(ScrollManagerView(indexPathToSetVisible: $indexPathToSetVisible).allowsHitTesting(false).frame(width: 0.0, height: 0.0))
                Details()
                    .frame(width: detailsWidth)
                    .animation(.default)
            }
        }
    }

    func customBinding() -> Binding<Int?> {
            let binding = Binding<Int?>(get: {
                self.selectedTable
            }, set: {
                print("Table \(String(describing: $0)) chosen")
                self.selectedTable = $0
            })
            return binding
        }
}

struct ScrollManagerView: UIViewRepresentable {

    @Binding var indexPathToSetVisible: IndexPath?

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
            guard let indexPath = indexPathToSetVisible else { return }
            let superview = uiView.findViewController()?.view

            if let tableView = superview?.subview(of: UITableView.self) {
                if tableView.numberOfSections > indexPath.section &&
                    tableView.numberOfRows(inSection: indexPath.section) > indexPath.row {
                    tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                }
            }

            DispatchQueue.main.async {
                self.indexPathToSetVisible = nil
            }
        }
}

struct Details: View {
    var body: some View {
        Text("DETAILS")
    }
}

struct Row: View {
    let model: [Item]
    let idx: Int
    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            ForEach(model) { m in
                HStack(alignment: .top) {
                    VStack(alignment: .center) {
                        Image("leaf")
                            .resizable()
                            .frame(width: 110, height: 110, alignment: .center)
                            .alignmentGuide(VerticalAlignment.top, computeValue: { d in
                                d[VerticalAlignment.top] - 4
                            })
                        Text("\(idx)")
                    }
                    .border(Color.black)

                    VStack(alignment: .leading) {
                        Text(m.name).padding(4)
                        Spacer()
                        Text(m.val).padding(4)
                    }
                }.border(Color.black)
            }
        }
    }
}


extension UIView {

    func subview<T>(of type: T.Type) -> T? {
        return subviews.compactMap { $0 as? T ?? $0.subview(of: type) }.first
    }

    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

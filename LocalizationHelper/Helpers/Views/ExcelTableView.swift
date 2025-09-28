//
//  ExcelTableView.swift
//  LocalizationHelper
//
//  Created by Home on 31/08/25.
//

import SwiftUI

/// **Warning**
/// if you are using conditions directly inside the cellContent closure make sure to handle the default case
struct ExcelTableView<Content: View, ColumnMenu: View, RowMenu : View>: View {
    let columnHeaders: [String]
    let rowHeaders: [String]
    
    @ViewBuilder let cellContent: (_ row: String, _ column: String) -> Content
    @ViewBuilder let columnMenu: (String) -> ColumnMenu
    @ViewBuilder let rowMenu: (String) -> RowMenu
    
    var body: some View {
        ScrollView([.vertical, .horizontal]) {
            VStack(spacing: 0) {
                // Header row
                HStack(spacing: 0) {
                    // Empty top-left cell
                    Text("")
                        .frame(width: 100, height: 40)
                        .background(Color.gray.opacity(0.2))
                        .border(Color.gray)

                    ForEach(columnHeaders, id: \.self) { column in
                        Text(column)
                            .frame(width: 100, height: 40)
                            .bold()
                            .background(Color.gray.opacity(0.2))
                            .border(Color.gray)
                            .contextMenu { columnMenu(column) }
                    }
                }

                // Data rows
                ForEach(rowHeaders, id: \.self) { row in
                    HStack(spacing: 0) {
                        // Row header
                        Text(row)
                            .frame(width: 100, height: 40)
                            .bold()
                            .background(Color.gray.opacity(0.2))
                            .border(Color.gray)
                            .contextMenu { rowMenu(row) }

                        // Cells
                        ForEach(columnHeaders, id: \.self) { column in
                            cellContent(row, column)
                                .frame(width: 100, height: 40)
                                .border(Color.gray.opacity(0.3))
                        }
                    }
                }
            }
        }
    }
}

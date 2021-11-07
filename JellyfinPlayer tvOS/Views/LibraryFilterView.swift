/* JellyfinPlayer/Swiftfin is subject to the terms of the Mozilla Public
 * License, v2.0. If a copy of the MPL was not distributed with this
 * file, you can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * Copyright 2021 Aiden Vigue & Jellyfin Contributors
 */

import JellyfinAPI
import Stinsen
import SwiftUI

struct LibraryFilterView: View {
    
    @EnvironmentObject var filterRouter: FilterCoordinator.Router
    @Binding var filters: LibraryFilters
    var parentId: String = ""

    @StateObject var viewModel: LibraryFilterViewModel

    init(filters: Binding<LibraryFilters>, enabledFilterType: [FilterType], parentId: String) {
        _filters = filters
        self.parentId = parentId
        _viewModel =
            StateObject(wrappedValue: .init(filters: filters.wrappedValue, enabledFilterType: enabledFilterType, parentId: parentId))
    }

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Form {
                    if viewModel.enabledFilterType.contains(.genre) {
                        MultiSelector(label: R.string.localizable.genres(),
                                      options: viewModel.possibleGenres,
                                      optionToString: { $0.name ?? "" },
                                      selected: $viewModel.modifiedFilters.withGenres)
                    }
                    if viewModel.enabledFilterType.contains(.filter) {
                        MultiSelector(label: R.string.localizable.filters(),
                                      options: viewModel.possibleItemFilters,
                                      optionToString: { $0.localized },
                                      selected: $viewModel.modifiedFilters.filters)
                    }
                    if viewModel.enabledFilterType.contains(.tag) {
                        MultiSelector(label: R.string.localizable.tags(),
                                      options: viewModel.possibleTags,
                                      optionToString: { $0 },
                                      selected: $viewModel.modifiedFilters.tags)
                    }
                    if viewModel.enabledFilterType.contains(.sortBy) {
                        Picker(selection: $viewModel.selectedSortBy, label: R.string.localizable.sortBy.text) {
                            ForEach(viewModel.possibleSortBys, id: \.self) { so in
                                Text(so.localized).tag(so)
                            }
                        }
                    }
                    if viewModel.enabledFilterType.contains(.sortOrder) {
                        Picker(selection: $viewModel.selectedSortOrder, label: R.string.localizable.displayOrder.text) {
                            ForEach(viewModel.possibleSortOrders, id: \.self) { so in
                                Text(so.rawValue).tag(so)
                            }
                        }
                    }
                }
                Button {
                    viewModel.resetFilters()
                    self.filters = viewModel.modifiedFilters
                    filterRouter.dismissCoordinator()
                } label: {
                    R.string.localizable.reset.text
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button {
                    filterRouter.dismissCoordinator()
                } label: {
                    Image(systemName: "xmark")
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    viewModel.updateModifiedFilter()
                    self.filters = viewModel.modifiedFilters
                    filterRouter.dismissCoordinator()
                } label: {
                    R.string.localizable.apply.text
                }
            }
        }
    }
}

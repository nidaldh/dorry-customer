import 'package:dorry/widget/store/store_item_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:dorry/model/gender_model.dart';
import 'package:dorry/model/address/area_model.dart';
import 'package:dorry/providers/store_list_provider.dart';
import 'package:dorry/utils/sizes.dart';
import 'package:dorry/widget/base_scaffold_widget.dart';

class StoreListScreen extends StatefulWidget {
  const StoreListScreen({super.key});

  @override
  State<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final StoreListProvider _storeListProvider = StoreListProvider();
  GenderModel? selectedGender;

  @override
  void initState() {
    super.initState();
    _storeListProvider.fetchStores();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _storeListProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StoreListProvider>.value(
      value: _storeListProvider,
      child: Consumer<StoreListProvider>(
        builder: (context, provider, child) {
          return BaseScaffoldWidget(
            title: null,
            showAppBar: false,
            body: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Sizes.horizontal_16,
                vertical: Sizes.vertical_5,
              ),
              child: Column(
                children: [
                  _buildSearchField(provider),
                  Expanded(
                    child: _buildContent(provider),
                  ),
                ],
              ),
            ),
            floatingActionButton: _buildFloatingActionButton(provider),
          );
        },
      ),
    );
  }

  Widget _buildSearchField(StoreListProvider provider) {
    return TextField(
      controller: _searchController,
      onChanged: provider.filterStores,
      decoration: InputDecoration(
        labelText: 'بحث...',
        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.radius_10),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(StoreListProvider provider) {
    if (provider.isLoading) {
      return _buildLoadingIndicator();
    } else if (provider.hasError) {
      return _buildErrorState(provider);
    } else if (provider.filteredStores.isEmpty) {
      return _buildEmptyState();
    } else {
      return _buildStoreGrid(provider);
    }
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          SizedBox(height: Sizes.height_16),
          const Text('جار تحميل الصالونات...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(StoreListProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red, size: Sizes.iconSize_54),
          SizedBox(height: Sizes.height_16),
          Text(
            'فشل في تحميل الصالونات.',
            style: TextStyle(
              fontSize: Sizes.textSize_18,
              color: Colors.red,
            ),
          ),
          SizedBox(height: Sizes.height_16),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            onPressed: provider.fetchStores,
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store,
            size: Sizes.iconSize_65,
            color: Colors.grey,
          ),
          SizedBox(height: Sizes.height_16),
          Text(
            'لا توجد صالونات متاحة.',
            style: TextStyle(
              fontSize: Sizes.textSize_18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreGrid(StoreListProvider provider) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: Sizes.paddingAll_5,
      crossAxisSpacing: Sizes.paddingAll_5,
      itemCount: provider.filteredStores.length,
      itemBuilder: (context, index) {
        final store = provider.filteredStores[index];
        return StoreItemCard(store: store);
      },
    );
  }

  Widget _buildFloatingActionButton(StoreListProvider provider) {
    return FloatingActionButton(
      onPressed: () async {
        final selectedArea = await showModalBottomSheet<AreaModel>(
          context: context,
          builder: (context) {
            return ListView(
              padding: EdgeInsets.all(Sizes.paddingAll_16),
              children: provider.areas.map((area) {
                return ListTile(
                  title: Text(area.name),
                  trailing: provider.selectedAreaId == area.id
                      ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                      : null,
                  onTap: () => Navigator.pop(context, area),
                );
              }).toList(),
            );
          },
        );
        if (selectedArea != null) {
          provider.filterStoresByArea(selectedArea.id);
        }
      },
      child: const Icon(Icons.filter_list),
    );
  }
}

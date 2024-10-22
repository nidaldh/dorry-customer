import 'package:dorry/model/gender_model.dart';
import 'package:dorry/providers/store_list_provider.dart';
import 'package:dorry/router.dart';
import 'package:dorry/utils/sizes.dart';
import 'package:dorry/widget/base_scaffold_widget.dart';
import 'package:flutter/material.dart';
import 'package:dorry/model/address/area_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

class StoreListScreen extends StatefulWidget {
  const StoreListScreen({super.key});

  @override
  State<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  final TextEditingController _searchController = TextEditingController();
  GenderModel? selectedGender;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoreListProvider(),
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
                  TextField(
                    controller: _searchController,
                    onChanged: provider.filterStores,
                    decoration: InputDecoration(
                      labelText: 'بحث...',
                      labelStyle:
                          TextStyle(color: Theme.of(context).primaryColor),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Sizes.radius_10),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: provider.isLoading
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor),
                                ),
                                SizedBox(height: Sizes.height_16),
                                const Text('جار تحميل الصالونات...'),
                              ],
                            ),
                          )
                        : provider.hasError
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error,
                                        color: Colors.red,
                                        size: Sizes.iconSize_54),
                                    SizedBox(height: Sizes.height_16),
                                    Text(
                                      'فشل في تحميل الصالونات.',
                                      style: TextStyle(
                                          fontSize: Sizes.textSize_18,
                                          color: Colors.red),
                                    ),
                                    SizedBox(height: Sizes.height_16),
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.refresh),
                                      onPressed: provider.fetchStores,
                                      label: const Text('إعادة المحاولة'),
                                    ),
                                  ],
                                ),
                              )
                            : provider.filteredStores.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                  )
                                : MasonryGridView.count(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: Sizes.paddingAll_5,
                                    crossAxisSpacing: Sizes.paddingAll_5,
                                    itemCount: provider.filteredStores.length,
                                    itemBuilder: (context, index) {
                                      final store =
                                          provider.filteredStores[index];
                                      return GestureDetector(
                                        onTap: () {
                                          router.push('/store/${store.id}');
                                        },
                                        child: Card(
                                          elevation: 3,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                Sizes.radius_16),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Store Image with error handling
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                  top: Radius.circular(
                                                    Sizes.radius_16,
                                                  ),
                                                ),
                                                child: Hero(
                                                  tag: 'storeImage-${store.id}',
                                                  child: Image.network(
                                                    store.image ??
                                                        'https://static.vecteezy.com/system/resources/previews/010/071/559/non_2x/barbershop-logo-barber-shop-logo-template-vector.jpg',
                                                    height: Sizes.height_120,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (context,
                                                        child,
                                                        loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        return child;
                                                      } else {
                                                        return Shimmer
                                                            .fromColors(
                                                          baseColor: Colors
                                                              .grey.shade300,
                                                          highlightColor:
                                                              Colors.black,
                                                          child: Container(
                                                            height: Sizes
                                                                .height_120,
                                                            color: Colors
                                                                .grey.shade200,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Container(
                                                      height: Sizes.height_120,
                                                      color:
                                                          Colors.grey.shade200,
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.broken_image,
                                                          size: Sizes
                                                              .iconSize_100,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(
                                                  Sizes.paddingAll_8,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Store Name
                                                    Text(
                                                      store.name,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize:
                                                            Sizes.textSize_14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: Sizes.height_3,
                                                    ),
                                                    // Store Area
                                                    if (store.area != null) ...[
                                                      Text(
                                                        store.area!,
                                                        style: TextStyle(
                                                          fontSize:
                                                              Sizes.textSize_12,
                                                          color: Colors
                                                              .grey.shade600,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                    SizedBox(
                                                      height: Sizes.height_3,
                                                    ),
                                                    // Store Address
                                                    if (store.address !=
                                                        null) ...[
                                                      Text(
                                                        store.address!,
                                                        style: TextStyle(
                                                          fontSize:
                                                              Sizes.textSize_12,
                                                          color: Colors
                                                              .grey.shade600,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            ),

            // Floating Filter Button
            floatingActionButton: FloatingActionButton(
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
                              ? Icon(Icons.check,
                                  color: Theme.of(context).primaryColor)
                              : null,
                          onTap: () => Navigator.pop(context, area),
                        );
                      }).toList(),
                    );
                  },
                );
                provider.filterStoresByArea(selectedArea?.id);
              },
              child: const Icon(Icons.filter_list),
            ),
          );
        },
      ),
    );
  }
}
